import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/customer_search_service.dart';
import '../services/customer_service.dart';

class DebitFormPage extends StatefulWidget {
  const DebitFormPage({super.key});

  @override
  State<DebitFormPage> createState() => _DebitFormPageState();
}

class _DebitFormPageState extends State<DebitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _keywordController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _searchController = TextEditingController();
  final _customerSearchService = CustomerSearchService();
  bool _isFromCustomerList = false;
  bool _isEditingTotal = false;
  String? _selectedUserId;
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Timer? _debounce;
  BuildContext? _dialogContext;
  late ScaffoldMessengerState _scaffoldMessenger;
  int _currentPage = 0;
  int _totalPages = 0;
  String _currentSearchKeyword = '';
  bool _showSearchResults = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Dữ liệu mẫu cho danh sách mặt hàng
  final List<Map<String, dynamic>> _items = [
    {'name': 'Laptop Dell XPS 13', 'price': 25000000, 'quantity': 1},
    {'name': 'iPhone 14 Pro', 'price': 30000000, 'quantity': 2},
  ];

  double get _calculatedTotalAmount {
    return _items.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      _scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchCustomers(value);
    });
  }

  Future<void> _searchCustomers(String keyword, {bool loadMore = false}) async {
    if (keyword.isEmpty) {
      setState(() {
        _customers = [];
        _currentPage = 0;
        _totalPages = 0;
        _showSearchResults = false;
      });
      _removeOverlay();
      return;
    }

    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _currentSearchKeyword = keyword;
        _showSearchResults = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final data = await _customerSearchService.searchCustomers(
        keyword: keyword,
        page: loadMore ? _currentPage + 1 : 0,
      );

      if (!mounted) return;

      setState(() {
        if (loadMore) {
          _customers.addAll(List<Map<String, dynamic>>.from(data['customers']));
          _currentPage = data['currentPage'] as int;
        } else {
          _customers = List<Map<String, dynamic>>.from(data['customers']);
          _currentPage = data['currentPage'] as int;
        }
        _totalPages = data['totalPages'] as int;
        _isLoading = false;
        _isLoadingMore = false;
      });

      _showOverlay();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      _showSnackBar('Lỗi tìm kiếm: ${e.toString()}');
    }
  }

  void _selectCustomer(Map<String, dynamic> customer) {
    setState(() {
      _selectedUserId = customer['id'].toString();
      _nameController.text = customer['name'] ?? '';
      _addressController.text = customer['address'] ?? '';
      _keywordController.text = customer['phone'] ?? '';
      _isFromCustomerList = true;
      _showSearchResults = false;
    });
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 50),
              child: Material(
                elevation: 4,
                child: Container(
                  constraints: BoxConstraints(maxHeight: size.height * 0.4),
                  color: Colors.white,
                  child: _buildSearchResults(),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_customers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Không tìm thấy khách hàng',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            _currentPage < _totalPages - 1) {
          _searchCustomers(_currentSearchKeyword, loadMore: true);
        }
        return true;
      },
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _customers.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _customers.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final customer = _customers[index];
          return ListTile(
            title: Text(customer['name'] ?? ''),
            subtitle: Text(customer['phone'] ?? ''),
            onTap: () => _selectCustomer(customer),
          );
        },
      ),
    );
  }

  void _showItemsList() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Select Items',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 14, 19, 29),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5, // Số lượng mặt hàng mẫu
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item ${index + 1}'),
                  subtitle: Text(
                    '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format((index + 1) * 1000000)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _items.add({
                          'name': 'Item ${index + 1}',
                          'price': (index + 1) * 1000000,
                          'quantity': 1,
                        });
                        _totalAmountController.text =
                            _calculatedTotalAmount.toString();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _keywordController.dispose();
    _paidAmountController.dispose();
    _totalAmountController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _dialogContext = null;
    _removeOverlay();
    super.dispose();
  }

  void _showCustomerSearchDialog() {
    final searchController = TextEditingController();
    final layerLink = LayerLink();
    OverlayEntry? overlayEntry;
    bool isLoading = false;
    List<Map<String, dynamic>> customers = [];
    int currentPage = 0;
    int totalPages = 0;
    String currentSearchKeyword = '';
    Timer? debounce;

    void showOverlay(BuildContext context) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;

      overlayEntry = OverlayEntry(
        builder:
            (context) => Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 50),
                child: Material(
                  elevation: 4,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: size.height * 0.4),
                    color: Colors.white,
                    child:
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : customers.isEmpty
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Không tìm thấy khách hàng',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final customer = customers[index];
                                return ListTile(
                                  title: Text(customer['name'] ?? ''),
                                  subtitle: Text(customer['phone'] ?? ''),
                                  onTap: () {
                                    setState(() {
                                      _selectedUserId =
                                          customer['id'].toString();
                                      _nameController.text =
                                          customer['name'] ?? '';
                                      _addressController.text =
                                          customer['address'] ?? '';
                                      _keywordController.text =
                                          customer['phone'] ?? '';
                                    });
                                    overlayEntry?.remove();
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                  ),
                ),
              ),
            ),
      );

      Overlay.of(context).insert(overlayEntry!);
    }

    void onSearchChanged(String value) {
      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(const Duration(milliseconds: 500), () async {
        if (value.isEmpty) {
          overlayEntry?.remove();
          return;
        }

        try {
          final data = await _customerSearchService.searchCustomers(
            keyword: value,
            page: 0,
          );

          customers = List<Map<String, dynamic>>.from(data['customers']);
          currentPage = data['currentPage'] as int;
          totalPages = data['totalPages'] as int;
          currentSearchKeyword = value;

          if (overlayEntry != null) {
            overlayEntry!.remove();
          }
          showOverlay(context);
        } catch (e) {
          _showSnackBar('Lỗi tìm kiếm: ${e.toString()}');
        }
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Tìm kiếm khách hàng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 14, 19, 29),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CompositedTransformTarget(
                  link: layerLink,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: 'Nhập tên hoặc số điện thoại',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      debounce?.cancel();
      overlayEntry?.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 19, 29),
        title: const Text(
          'Tạo hóa đơn mới',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần thông tin khách hàng
                Row(
                  children: [
                    const Text(
                      'Thông tin khách hàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showCustomerSearchDialog,
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        'Thêm khách hàng',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Trường nhập tên
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Tên khách hàng',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên khách hàng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Trường nhập địa chỉ
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Địa chỉ',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Trường nhập số điện thoại
                TextFormField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Số điện thoại',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Danh sách mặt hàng
                Row(
                  children: [
                    const Text(
                      'Items List',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showItemsList,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Item',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantity: ${item['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Price: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(item['price'])}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Tổng tiền và số tiền đã thanh toán
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 150,
                                child: TextFormField(
                                  controller: _totalAmountController,
                                  enabled: _isEditingTotal,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        _isEditingTotal
                                            ? Colors.white
                                            : Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        // Cập nhật giá trị tổng tiền
                                      });
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditingTotal ? Icons.check : Icons.edit,
                                  color: const Color.fromARGB(255, 16, 80, 98),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditingTotal = !_isEditingTotal;
                                    if (!_isEditingTotal) {
                                      // Khi kết thúc chỉnh sửa, cập nhật lại giá trị
                                      _totalAmountController.text =
                                          _calculatedTotalAmount.toString();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _paidAmountController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          hintText: 'Paid Amount',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter paid amount';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Nút xác nhận
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 14, 19, 29),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Nếu chưa có userId, tạo khách hàng mới và lấy ID
        if (_selectedUserId == null) {
          final customerService = CustomerService();
          // Tạo khách hàng mới
          await customerService.addCustomer(
            _nameController.text,
            _addressController.text,
            _keywordController.text,
          );

          // Tìm kiếm khách hàng vừa tạo để lấy ID
          final searchResult = await _customerSearchService.searchCustomers(
            keyword: _keywordController.text,
            page: 0,
          );

          final customers = List<Map<String, dynamic>>.from(
            searchResult['customers'],
          );
          if (customers.isNotEmpty) {
            // Lấy khách hàng đầu tiên tìm thấy (vì số điện thoại là unique)
            _selectedUserId = customers[0]['id'].toString();
          } else {
            throw Exception('Không tìm thấy thông tin khách hàng sau khi tạo');
          }
        }

        // Tạo dữ liệu để gửi lên server
        final formData = {
          'userId': _selectedUserId,
          'name': _nameController.text,
          'address': _addressController.text,
          'phone': _keywordController.text,
          'items': _items,
          'totalAmount': _totalAmountController.text,
          'paidAmount': _paidAmountController.text,
        };

        // TODO: Gửi dữ liệu lên server
        print('Form data: $formData');

        // Chuyển về trang lịch sử nợ
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/debit_history');
          _showSnackBar('Thêm hóa đơn thành công');
        }
      } catch (e) {
        _showSnackBar('Lỗi: ${e.toString()}');
      }
    }
  }
}
