import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'auth_service.dart';

class CustomerSearchService {
  static final Logger _log = Logger('CustomerSearchService');
  final String baseUrl = 'https://cpaas.interits.com:9088/api/admin/v1';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> searchCustomers({
    required String keyword,
    int page = 0,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/get-customers?search=$keyword&page=$page'),
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
          'Failed to search customers. Status code: ${response.statusCode}',
        );
        throw Exception(
          'Failed to search customers. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _log.severe('Error searching customers: $e');
      throw Exception('Error searching customers: $e');
    }
  }
}
