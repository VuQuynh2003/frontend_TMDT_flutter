import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  bool _isFromCustomerList = false;
  bool _isEditingTotal = false;

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
  void initState() {
    super.initState();
    _totalAmountController.text = _calculatedTotalAmount.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _keywordController.dispose();
    _paidAmountController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Chuyển về trang lịch sử nợ
      Navigator.pushReplacementNamed(context, '/debit_history');
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice added successfully')),
      );
    }
  }

  void _showCustomerList() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Select Customer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 14, 19, 29),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 3, // Số lượng khách hàng mẫu
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Customer ${index + 1}'),
                  subtitle: Text('Address ${index + 1}'),
                  onTap: () {
                    setState(() {
                      _nameController.text = 'Customer ${index + 1}';
                      _addressController.text = 'Address ${index + 1}';
                      _isFromCustomerList = true;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 19, 29),
        title: const Text(
          'New Invoice',
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
                      'Customer Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showCustomerList,
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        'Select from list',
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
                    hintText: 'Customer Name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
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
                    hintText: 'Address',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Trường nhập từ khóa gợi nhớ
                TextFormField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Keyword (e.g., Con ông A bà B)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a keyword';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
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
}
