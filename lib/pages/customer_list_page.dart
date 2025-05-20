import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import '../widgets/action_buttons.dart';
import '../widgets/form_dialog.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  final CustomerService _customerService = CustomerService();
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  bool isLoading = true;
  bool _isSelectionMode = false;
  final Set<int> _selectedCustomers = {};
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalItems = 0;
  late ScaffoldMessengerState _scaffoldMessenger;

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

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  Future<void> _loadCustomers({int page = 0}) async {
    try {
      setState(() {
        isLoading = true;
        _errorMessage = null;
      });

      final data = await _customerService.getCustomers(page: page);

      if (!mounted) return;

      setState(() {
        customers = (data['customers'] as List<Map<String, dynamic>>);
        filteredCustomers = List.from(customers);
        _currentPage = data['currentPage'] as int;
        _totalPages = data['totalPages'] as int;
        _totalItems = data['totalItems'] as int;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _errorMessage = 'Không thể tải danh sách khách hàng: ${e.toString()}';
      });
      _showSnackBar(_errorMessage ?? 'Lỗi không xác định');
    }
  }

  void _filterCustomers() {
    if (!mounted) return;

    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customers);
      } else {
        filteredCustomers =
            customers.where((customer) {
              final String name =
                  customer['name']?.toString().toLowerCase() ?? '';
              final String phone =
                  customer['phone']?.toString().toLowerCase() ?? '';
              final String address =
                  customer['address']?.toString().toLowerCase() ?? '';

              return name.contains(query) ||
                  phone.contains(query) ||
                  address.contains(query);
            }).toList();
      }
    });
  }

  Future<void> _deleteSelectedCustomers() async {
    if (_selectedCustomers.isEmpty) {
      if (!mounted) return;
      _showSnackBar('Vui lòng chọn khách hàng cần xóa');
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 14, 19, 29),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa ${_selectedCustomers.length} khách hàng đã chọn?',
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color.fromARGB(255, 16, 80, 98)),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  if (!mounted) return;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 16, 80, 98),
                        ),
                      );
                    },
                  );

                  final List<String> customerIds =
                      _selectedCustomers
                          .map(
                            (index) => customers[index]['id']?.toString() ?? '',
                          )
                          .where((id) => id.isNotEmpty)
                          .toList();

                  if (customerIds.isEmpty) {
                    throw Exception('Không tìm thấy ID khách hàng hợp lệ');
                  }

                  await _customerService.deleteMultipleCustomers(customerIds);

                  if (!mounted) return;
                  Navigator.pop(context);

                  setState(() {
                    final List<int> sortedIndices =
                        _selectedCustomers.toList()
                          ..sort((a, b) => b.compareTo(a));

                    for (final index in sortedIndices) {
                      if (index >= 0 && index < customers.length) {
                        customers.removeAt(index);
                      }
                    }
                    _selectedCustomers.clear();
                    _isSelectionMode = false;
                    _filterCustomers();
                  });

                  if (!mounted) return;
                  _showSnackBar('Xóa khách hàng thành công');
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  _showSnackBar('Lỗi: ${e.toString()}');
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomerDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return FormDialog(
          title: 'Thêm khách hàng mới',
          submitButtonText: 'Thêm',
          fields: [
            const CustomFormField(
              name: 'name',
              label: 'Tên khách hàng',
              hint: 'Nhập tên khách hàng',
              icon: Icons.person,
            ),
            const CustomFormField(
              name: 'phone',
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const CustomFormField(
              name: 'address',
              label: 'Địa chỉ',
              hint: 'Nhập địa chỉ',
              icon: Icons.location_on,
            ),
          ],
          onCancel: () => Navigator.pop(context),
          onSubmit: (values) async {
            if (values == null) {
              if (!mounted) return;
              _showSnackBar('Dữ liệu không hợp lệ');
              return;
            }

            try {
              Navigator.pop(context);
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 16, 80, 98),
                    ),
                  );
                },
              );

              final String name = values['name']?.toString().trim() ?? '';
              final String address = values['address']?.toString().trim() ?? '';
              final String phone = values['phone']?.toString().trim() ?? '';

              if (name.isEmpty) {
                throw Exception('Vui lòng nhập tên khách hàng');
              }

              final newCustomer = await _customerService.addCustomer(
                name,
                address,
                phone,
              );

              if (!mounted) return;
              Navigator.pop(context);
              _showSnackBar('Thêm khách hàng thành công');

              setState(() {
                customers.add(newCustomer);
                _filterCustomers();
              });
            } catch (e) {
              if (!mounted) return;
              Navigator.pop(context);
              _showSnackBar('Lỗi: ${e.toString()}');
            }
          },
        );
      },
    );
  }

  void _showEditCustomerDialog(Map<String, dynamic> customer, int index) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return FormDialog(
          title: 'Sửa thông tin khách hàng',
          submitButtonText: 'Lưu',
          initialValues: {
            'name': customer['name']?.toString() ?? '',
            'phone': customer['phone']?.toString() ?? '',
            'address': customer['address']?.toString() ?? '',
          },
          fields: [
            const CustomFormField(
              name: 'name',
              label: 'Tên khách hàng',
              hint: 'Nhập tên khách hàng',
              icon: Icons.person,
            ),
            const CustomFormField(
              name: 'phone',
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const CustomFormField(
              name: 'address',
              label: 'Địa chỉ',
              hint: 'Nhập địa chỉ',
              icon: Icons.location_on,
            ),
          ],
          onCancel: () => Navigator.pop(context),
          onSubmit: (values) async {
            if (values == null) {
              if (!mounted) return;
              _showSnackBar('Dữ liệu không hợp lệ');
              return;
            }

            try {
              Navigator.pop(context);
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 16, 80, 98),
                    ),
                  );
                },
              );

              final String name = values['name']?.toString().trim() ?? '';
              final String address = values['address']?.toString().trim() ?? '';
              final String phone = values['phone']?.toString().trim() ?? '';

              if (name.isEmpty) {
                throw Exception('Vui lòng nhập tên khách hàng');
              }

              final updatedCustomer = {
                ...customer,
                'name': name,
                'phone': phone,
                'address': address,
              };

              await _customerService.updateCustomer(updatedCustomer);

              if (!mounted) return;
              Navigator.pop(context);
              _showSnackBar('Cập nhật thông tin thành công');

              setState(() {
                customers[index] = updatedCustomer;
                _filterCustomers();
              });
            } catch (e) {
              if (!mounted) return;
              Navigator.pop(context);
              _showSnackBar('Lỗi: ${e.toString()}');
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 19, 29),
        title: const Text(
          'Danh sách khách hàng',
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Tìm kiếm theo tên, số điện thoại hoặc địa chỉ',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(child: _buildCustomerList()),
                        _buildPagination(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ActionButtons(
              isSelectionMode: _isSelectionMode,
              onDeleteSelected: _deleteSelectedCustomers,
              onAdd: _showAddCustomerDialog,
              onToggleSelection: () {
                setState(() {
                  if (_isSelectionMode) {
                    _isSelectionMode = false;
                    _selectedCustomers.clear();
                  } else {
                    _isSelectionMode = true;
                  }
                });
              },
              rightBtnTag: "customerRightBtn",
              leftBtnTag: "customerLeftBtn",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 16, 80, 98),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCustomers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (filteredCustomers.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy khách hàng nào',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        final originalIndex = customers.indexWhere(
          (c) => c['id']?.toString() == customer['id']?.toString(),
        );

        if (originalIndex == -1) return const SizedBox.shrink();

        return InkWell(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (_selectedCustomers.contains(originalIndex)) {
                  _selectedCustomers.remove(originalIndex);
                } else {
                  _selectedCustomers.add(originalIndex);
                }
              });
            } else {
              Navigator.pushNamed(
                context,
                '/customer_detail',
                arguments: customer,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color:
                    _selectedCustomers.contains(originalIndex)
                        ? const Color.fromARGB(25, 0, 0, 255)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(51, 128, 128, 128),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                border:
                    _selectedCustomers.contains(originalIndex)
                        ? Border.all(color: Colors.blue)
                        : null,
              ),
              child: Row(
                children: [
                  if (_isSelectionMode)
                    Checkbox(
                      value: _selectedCustomers.contains(originalIndex),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCustomers.add(originalIndex);
                          } else {
                            _selectedCustomers.remove(originalIndex);
                          }
                        });
                      },
                      activeColor: const Color.fromARGB(255, 16, 80, 98),
                    ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color.fromARGB(255, 16, 80, 98),
                    child: Text(
                      _getInitials(customer['name']?.toString() ?? ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name']?.toString() ?? 'Chưa có tên',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (customer['phone']?.toString().isNotEmpty ?? false)
                          Text(
                            'SĐT: ${customer['phone']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        if (customer['address']?.toString().isNotEmpty ?? false)
                          Text(
                            'Địa chỉ: ${customer['address']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!_isSelectionMode)
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 16, 80, 98),
                        size: 20,
                      ),
                      onPressed:
                          () =>
                              _showEditCustomerDialog(customer, originalIndex),
                      tooltip: 'Sửa thông tin',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.isEmpty || nameParts.first.isEmpty) return '?';
    return nameParts.first[0].toUpperCase();
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                _currentPage > 0
                    ? () => _loadCustomers(page: _currentPage - 1)
                    : null,
            color:
                _currentPage > 0
                    ? const Color.fromARGB(255, 16, 80, 98)
                    : Colors.grey,
          ),
          const SizedBox(width: 8),
          ...List.generate(_totalPages, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => _loadCustomers(page: index),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? const Color.fromARGB(255, 16, 80, 98)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color.fromARGB(255, 16, 80, 98),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color:
                            _currentPage == index
                                ? Colors.white
                                : const Color.fromARGB(255, 16, 80, 98),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _currentPage < _totalPages - 1
                    ? () => _loadCustomers(page: _currentPage + 1)
                    : null,
            color:
                _currentPage < _totalPages - 1
                    ? const Color.fromARGB(255, 16, 80, 98)
                    : Colors.grey,
          ),
        ],
      ),
    );
  }
}
