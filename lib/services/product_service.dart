import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class ProductService {
  static final Logger _log = Logger('ProductService');
  final String baseUrl = 'https://cpaa.inte.com:9088/api/admin/v1';
  
  // Dữ liệu mẫu để test
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'name': 'Laptop Dell XPS 13',
      'description': 'Laptop cao cấp với màn hình 13 inch',
      'price': 25000000,
    },
    {
      'id': '2',
      'name': 'iPhone 14 Pro',
      'description': 'Điện thoại Apple mới nhất với camera 48MP',
      'price': 30000000,
    },
    {
      'id': '3',
      'name': 'Samsung Galaxy S23',
      'description': 'Điện thoại Android cao cấp với Snapdragon 8 Gen 2',
      'price': 22000000,
    },
    {
      'id': '4',
      'name': 'iPad Pro M2',
      'description': 'Máy tính bảng mạnh mẽ với chip M2',
      'price': 28000000,
    },
    {
      'id': '5',
      'name': 'Tai nghe Sony WH-1000XM5',
      'description': 'Tai nghe chống ồn cao cấp',
      'price': 8500000,
    },
  ];

  // Phương thức lấy danh sách sản phẩm (sử dụng dữ liệu mẫu)
  Future<List<Map<String, dynamic>>> getProducts() async {
    // Giả lập độ trễ của API
    await Future.delayed(const Duration(seconds: 1));
    
    // Trả về dữ liệu mẫu
    return List.from(_mockProducts);
  }

  // Phương thức thêm sản phẩm mới (sử dụng dữ liệu mẫu)
  Future<Map<String, dynamic>> addProduct(String name, String description, double price) async {
    // Giả lập độ trễ của API
    await Future.delayed(const Duration(seconds: 1));
    
    // Tạo sản phẩm mới với ID ngẫu nhiên
    final newProduct = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'description': description,
      'price': price,
    };
    
    // Thêm vào danh sách mẫu
    _mockProducts.add(newProduct);
    
    return newProduct;
  }

  // Phương thức cập nhật sản phẩm (sử dụng dữ liệu mẫu)
  Future<Map<String, dynamic>> updateProduct(Map<String, dynamic> product) async {
    // Giả lập độ trễ của API
    await Future.delayed(const Duration(seconds: 1));
    
    // Tìm index của sản phẩm cần cập nhật
    final index = _mockProducts.indexWhere((p) => p['id'] == product['id']);
    
    if (index != -1) {
      // Cập nhật sản phẩm
      _mockProducts[index] = product;
      return product;
    } else {
      throw Exception('Product not found');
    }
  }

  // Phương thức xoá nhiều sản phẩm (sử dụng dữ liệu mẫu)
  Future<void> deleteMultipleProducts(List<String> productIds) async {
    // Giả lập độ trễ của API
    await Future.delayed(const Duration(seconds: 1));
    
    // Xoá các sản phẩm có ID trong danh sách
    _mockProducts.removeWhere((product) => productIds.contains(product['id']));
  }
  
  // Giữ lại các phương thức API thật để sau này sử dụng
  Future<List<Map<String, dynamic>>> _getProductsFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        _log.severe('Failed to load products. Status code: ${response.statusCode}');
        throw Exception('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _log.severe('Error getting products: $e');
      throw Exception('Error getting products: $e');
    }
  }

  Future<Map<String, dynamic>> _addProductToApi(String name, String description, double price) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'description': description,
          'price': price,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        _log.severe('Failed to add product. Status code: ${response.statusCode}');
        throw Exception('Failed to add product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _log.severe('Error adding product: $e');
      throw Exception('Error adding product: $e');
    }
  }

  Future<Map<String, dynamic>> _updateProductInApi(Map<String, dynamic> product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': product['id'],
          'name': product['name'],
          'description': product['description'],
          'price': product['price'],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _log.severe('Failed to update product. Status code: ${response.statusCode}');
        throw Exception('Failed to update product. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _log.severe('Error updating product: $e');
      throw Exception('Error updating product: $e');
    }
  }

  Future<void> _deleteMultipleProductsFromApi(List<String> productIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete-product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'ids': productIds,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        _log.severe('Failed to delete products. Status code: ${response.statusCode}');
        throw Exception('Failed to delete products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _log.severe('Error deleting products: $e');
      throw Exception('Error deleting products: $e');
    }
  }
}
