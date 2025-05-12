import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/customer_service.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final CustomerService _customerService = CustomerService();
  bool isLoading = true;
  Map<String, dynamic>? customer;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    try {
      final customerData = ModalRoute.of(context)?.settings.arguments;
      if (customerData == null || customerData is! Map<String, dynamic>) {
        throw Exception('Invalid customer data');
      }

      final String? customerId = customerData['id']?.toString();
      if (customerId == null || customerId.isEmpty) {
        throw Exception('Customer ID is required');
      }

      final customerDetails = await _customerService.getCustomerById(
        customerId,
      );

      if (!mounted) return;
      setState(() {
        customer = customerDetails;
        final List<dynamic>? historyData =
            customerDetails['history'] as List<dynamic>?;
        history =
            (historyData ?? []).whereType<Map>().map((dynamic item) {
              if (item is! Map) {
                return {
                  'date': '',
                  'type': '',
                  'item': '',
                  'amount': '0',
                  'amount_paid': '0',
                  'remaining_debt': '0',
                };
              }

              final Map<String, dynamic> historyItem =
                  Map<String, dynamic>.from(item);
              return {
                'date': historyItem['date']?.toString() ?? '',
                'type': historyItem['type']?.toString() ?? '',
                'item': historyItem['item']?.toString() ?? '',
                'amount': historyItem['amount']?.toString() ?? '0',
                'amount_paid': historyItem['amount_paid']?.toString() ?? '0',
                'remaining_debt':
                    historyItem['remaining_debt']?.toString() ?? '0',
              };
            }).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải thông tin khách hàng: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 16, 80, 98),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (customer == null) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 16, 80, 98),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 14, 19, 29),
          title: const Text(
            'Customer Details',
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
        body: const Center(
          child: Text(
            'Customer not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Sắp xếp theo thời gian (mới nhất trước)
    final sortedHistory = List.from(history)..sort((a, b) {
      final String dateA = a['date']?.toString() ?? '';
      final String dateB = b['date']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });

    // Nhóm các giao dịch theo ngày
    final Map<String, List<Map<String, dynamic>>> groupedHistory = {};
    for (var record in sortedHistory) {
      final String? dateStr = record['date']?.toString();
      if (dateStr == null || dateStr.isEmpty) continue;

      try {
        final date = DateFormat(
          'EEEE, dd/MM/yyyy',
        ).format(DateTime.parse(dateStr));
        if (!groupedHistory.containsKey(date)) {
          groupedHistory[date] = [];
        }
        groupedHistory[date]!.add(record);
      } catch (e) {
        print('Error parsing date: $dateStr');
        continue;
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 19, 29),
        title: const Text(
          'Customer Details',
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color.fromARGB(51, 255, 255, 255),
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer!['name']?.toString() ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customer!['address']?.toString() ?? 'No address',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(25, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Phone: ${customer!['phone']?.toString() ?? 'No phone'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child:
                  history.isEmpty
                      ? const Center(
                        child: Text(
                          'No transaction history',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        itemCount: groupedHistory.length,
                        itemBuilder: (context, index) {
                          final date = groupedHistory.keys.elementAt(index);
                          final records = groupedHistory[date]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              ...records.map((record) {
                                final String type =
                                    record['type']?.toString() ?? '';
                                final String item =
                                    record['item']?.toString() ?? '';
                                final String amount =
                                    record['amount']?.toString() ?? '0';
                                final String amountPaid =
                                    record['amount_paid']?.toString() ?? '0';
                                final String remainingDebt =
                                    record['remaining_debt']?.toString() ?? '0';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                            51,
                                            128,
                                            128,
                                            128,
                                          ),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color:
                                                type == 'borrow'
                                                    ? const Color.fromARGB(
                                                      25,
                                                      255,
                                                      0,
                                                      0,
                                                    )
                                                    : const Color.fromARGB(
                                                      25,
                                                      0,
                                                      255,
                                                      0,
                                                    ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            type == 'borrow'
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            color:
                                                type == 'borrow'
                                                    ? Colors.red
                                                    : Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                type == 'borrow'
                                                    ? 'Borrowed: $item'
                                                    : 'Repayment',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                type == 'borrow'
                                                    ? 'Amount: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(double.tryParse(amount) ?? 0)}'
                                                    : 'Paid: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(double.tryParse(amountPaid) ?? 0)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      type == 'borrow'
                                                          ? Colors.red
                                                          : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (type == 'repay')
                                                Text(
                                                  'Remaining: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(double.tryParse(remainingDebt) ?? 0)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
