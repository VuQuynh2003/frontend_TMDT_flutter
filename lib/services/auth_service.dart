import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'storage_service.dart';

class User {
  final String? id;
  final String? email;
  final String? name;
  final String? address;
  final String? birthday;
  final String? gender;
  final String? agencyId;
  final String? agencyName;
  final String? avatarUrl;
  final String? phone;

  User({
    this.id,
    this.email,
    this.name,
    this.address,
    this.birthday,
    this.gender,
    this.agencyId,
    this.agencyName,
    this.avatarUrl,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final avatar = json['avatar'] as Map<String, dynamic>?;
    return User(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      address: json['address']?.toString(),
      birthday: json['birthday']?.toString(),
      gender: json['gender']?.toString(),
      agencyId: json['agencyId']?.toString(),
      agencyName: json['agencyName']?.toString(),
      avatarUrl: avatar?['originUrl']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'address': address,
      'birthday': birthday,
      'gender': gender,
      'agencyId': agencyId,
      'agencyName': agencyName,
      'avatar': {'originUrl': avatarUrl},
      'phone': phone,
    };
  }
}

class AuthService {
  static final Logger _log = Logger('AuthService');
  final String baseUrl = 'https://cpaas.interits.com:9088/api/admin/v1/auth';
  final StorageService _storage = StorageService();
  String? _token;
  User? _currentUser;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _log.info('Attempting login for email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password.trim()}),
      );

      _log.info('Login response status: ${response.statusCode}');
      _log.info('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        _log.info('Decoded response data: $decoded');

        // Kiểm tra cấu trúc response
        if (decoded == null || decoded is! Map) {
          _log.severe('Invalid response format: expected Map');
          throw Exception('Invalid response format: expected Map');
        }

        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(decoded);

        // Truy cập vào trường 'data'
        final dynamic innerData = jsonMap['data'];
        if (innerData == null || innerData is! Map) {
          _log.severe('Missing or invalid "data" field');
          throw Exception('Invalid response: missing data');
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(innerData);

        // Lấy accessToken từ data
        final dynamic tokenData = data['accessToken'];
        _log.info('Token data from response: $tokenData');

        if (tokenData == null) {
          _log.severe('No accessToken field in response');
          throw Exception('No accessToken field in response');
        }

        final String token = tokenData.toString();
        if (token.isEmpty) {
          _log.severe('Empty token received');
          throw Exception('Empty token received');
        }

        // Lưu token
        _token = token;
        await _storage.saveToken(token);
        _log.info('Token saved successfully: ${token.substring(0, 10)}...');

        // Lưu thông tin user
        try {
          _currentUser = User.fromJson(data);
          await _storage.saveUserData(_currentUser!.toJson());
          _log.info('User data saved successfully');
        } catch (e) {
          _log.warning('Error parsing user data: $e');
        }

        return data;
      } else {
        _log.severe('Login failed with status: ${response.statusCode}');
        _log.severe('Response body: ${response.body}');
        throw Exception('Đăng nhập thất bại: ${response.body}');
      }
    } catch (e) {
      _log.severe('Login error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        _log.info('No token found');
        await logout();
        return false;
      }

      // Kiểm tra token với server
      final response = await http.get(
        Uri.parse('$baseUrl/validate-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        _log.warning('Token validation failed: ${response.statusCode}');
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      _log.severe('Error validating token: $e');
      await logout();
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final isValid = await validateToken();
      _log.info('isLoggedIn check: $isValid');
      return isValid;
    } catch (e) {
      _log.severe('Error checking login status: $e');
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _token = null;
      _currentUser = null;
      await _storage.clearToken();
      await _storage.clearUserData();
      _log.info('Logout successful');
    } catch (e) {
      _log.severe('Logout error: $e');
      throw Exception('Lỗi đăng xuất: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      if (_token == null) {
        _token = await _storage.getToken();
        _log.info('Retrieved token from storage: $_token');
      }
      return _token;
    } catch (e) {
      _log.severe('Error getting token: $e');
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      if (_currentUser == null) {
        final userData = await _storage.getUserData();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
      }
      return _currentUser;
    } catch (e) {
      _log.severe('Error getting current user: $e');
      return null;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    try {
      if (_token == null) {
        _token = await _storage.getToken();
        _log.info('Retrieved token from storage: $_token');
      }

      if (_token == null || _token!.isEmpty) {
        _log.severe('No valid authentication token found');
        throw Exception('No valid authentication token found');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

      _log.info('Generated auth headers: $headers');
      return headers;
    } catch (e) {
      _log.severe('Error getting auth headers: $e');
      throw Exception('Error getting auth headers: $e');
    }
  }
}
