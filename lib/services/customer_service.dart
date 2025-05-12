import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'auth_service.dart';

class CustomerService {
  static final Logger _log = Logger('CustomerService');
  final String baseUrl = 'https://cpaas.interits.com:9088/api/admin/v1';
  final AuthService _authService = AuthService();

  // Dữ liệu mẫu để test
  final List<Map<String, dynamic>> _mockCustomers = [
    {
      'id': '1',
      'name': 'Nguyễn Văn An',
      'address': 'Hà Nội',
      'phone': '0912345678',
    },
    {
      'id': '2',
      'name': 'Trần Thị Bình',
      'address': 'Hồ Chí Minh',
      'phone': '0923456789',
    },
    {
      'id': '3',
      'name': 'Lê Văn Cường',
      'address': 'Đà Nẵng',
      'phone': '0934567890',
    },
    {
      'id': '4',
      'name': 'Phạm Thị Dung',
      'address': 'Cần Thơ',
      'phone': '0945678901',
    },
    {
      'id': '5',
      'name': 'Hoàng Văn Em',
      'address': 'Hải Phòng',
      'phone': '0956789012',
    },
  ];

  // Phương thức lấy danh sách khách hàng
  Future<Map<String, dynamic>> getCustomers({int page = 0}) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/get-customers?page=$page'),
        headers: headers,
      );

      _log.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null || decoded is! Map) {
          throw Exception('Invalid response format: expected Map');
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
        final List<dynamic>? customersData = data['data'] as List<dynamic>?;
        final int? totalPages = data['totalPages'] as int?;
        final int? currentPage = data['currentPage'] as int?;
        final int? totalItems = data['totalItems'] as int?;

        if (customersData == null) {
          throw Exception('Invalid response format: missing data field');
        }

        final List<Map<String, dynamic>> customers =
            customersData.where((item) => item is Map<String, dynamic>).map((
              item,
            ) {
              final customer = Map<String, dynamic>.from(
                item as Map<String, dynamic>,
              );
              return <String, dynamic>{
                'id': customer['id']?.toString() ?? '',
                'name': customer['name']?.toString() ?? '',
                'address': customer['address']?.toString() ?? '',
                'phone': customer['phone']?.toString() ?? '',
              };
            }).toList();

        return {
          'customers': customers,
          'totalPages': totalPages ?? 0,
          'currentPage': currentPage ?? 0,
          'totalItems': totalItems ?? 0,
        };
      } else {
        _log.severe(
          'Failed to load customers. Status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to load customers. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.severe('Error getting customers: $e');
      throw Exception('Error getting customers: $e');
    }
  }

  // Phương thức thêm khách hàng mới
  Future<Map<String, dynamic>> addCustomer(
    String name,
    String address,
    String phone,
  ) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/add-customer'),
        headers: headers,
        body: jsonEncode({
          'name': name.trim(),
          'address': address.trim(),
          'phone': phone.trim(),
        }),
      );

      _log.info('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded == null || decoded is! Map) {
          throw Exception('Invalid response format: expected Map');
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
        return <String, dynamic>{
          'id': data['id']?.toString() ?? '',
          'name': data['name']?.toString() ?? name,
          'address': data['address']?.toString() ?? address,
          'phone': data['phone']?.toString() ?? phone,
        };
      } else {
        _log.severe(
          'Failed to add customer. Status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to add customer. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.severe('Error adding customer: $e');
      throw Exception('Error adding customer: $e');
    }
  }

  // Phương thức cập nhật khách hàng
  Future<Map<String, dynamic>> updateCustomer(
    Map<String, dynamic> customer,
  ) async {
    try {
      final String id = customer['id']?.toString() ?? '';
      final String name = customer['name']?.toString() ?? '';
      final String address = customer['address']?.toString() ?? '';
      final String phone = customer['phone']?.toString() ?? '';

      if (id.isEmpty) {
        throw Exception('Customer ID is required for update');
      }

      final headers = await _authService.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/update-customer'),
        headers: headers,
        body: jsonEncode({
          'id': id,
          'name': name.trim(),
          'address': address.trim(),
          'phone': phone.trim(),
        }),
      );

      _log.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null || decoded is! Map) {
          throw Exception('Invalid response format: expected Map');
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
        return <String, dynamic>{
          'id': data['id']?.toString() ?? id,
          'name': data['name']?.toString() ?? name,
          'address': data['address']?.toString() ?? address,
          'phone': data['phone']?.toString() ?? phone,
        };
      } else {
        _log.severe(
          'Failed to update customer. Status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to update customer. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.severe('Error updating customer: $e');
      throw Exception('Error updating customer: $e');
    }
  }

  // Phương thức xoá nhiều khách hàng
  Future<void> deleteMultipleCustomers(List<String> customerIds) async {
    try {
      if (customerIds.isEmpty) {
        throw Exception('No customer IDs provided for deletion');
      }

      final validIds = customerIds.where((id) => id.isNotEmpty).toList();
      if (validIds.isEmpty) {
        throw Exception('No valid customer IDs found');
      }

      final headers = await _authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/delete-customer'),
        headers: headers,
        body: jsonEncode({'ids': validIds}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        _log.severe(
          'Failed to delete customers. Status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to delete customers. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.severe('Error deleting customers: $e');
      throw Exception('Error deleting customers: $e');
    }
  }

  // Phương thức lấy chi tiết khách hàng theo ID
  Future<Map<String, dynamic>> getCustomerById(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('Customer ID is required');
      }

      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/get-detail-customer/$id'),
        headers: headers,
      );

      _log.info('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded == null || decoded is! Map) {
          throw Exception('Invalid response format: expected Map');
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
        final String responseId = data['id']?.toString() ?? id;
        final String name = data['name']?.toString() ?? '';
        final String address = data['address']?.toString() ?? '';
        final String phone = data['phone']?.toString() ?? '';
        final List<dynamic>? historyData = data['history'] as List<dynamic>?;

        final List<Map<String, dynamic>> history =
            (historyData ?? [])
                .where((item) => item is Map<String, dynamic>)
                .map((item) {
                  final historyItem = Map<String, dynamic>.from(
                    item as Map<String, dynamic>,
                  );
                  return <String, dynamic>{
                    'date': historyItem['date']?.toString() ?? '',
                    'type': historyItem['type']?.toString() ?? '',
                    'item': historyItem['item']?.toString() ?? '',
                    'amount': historyItem['amount']?.toString() ?? '0',
                    'amount_paid':
                        historyItem['amount_paid']?.toString() ?? '0',
                    'remaining_debt':
                        historyItem['remaining_debt']?.toString() ?? '0',
                  };
                })
                .toList();

        return {
          'id': responseId,
          'name': name,
          'address': address,
          'phone': phone,
          'history': history,
        };
      } else {
        _log.severe(
          'Failed to get customer details. Status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to get customer details. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.severe('Error getting customer details: $e');
      throw Exception('Error getting customer details: $e');
    }
  }
}
