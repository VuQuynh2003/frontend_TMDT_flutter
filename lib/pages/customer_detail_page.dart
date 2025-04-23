import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Nhận dữ liệu khách hàng từ arguments
    final customer =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Dữ liệu mẫu lịch sử vay và trả nợ
    final List<Map<String, dynamic>> history = [
      {
        'type': 'borrow',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'amount': 5000000,
        'item': 'Laptop',
      },
      {
        'type': 'repay',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'amount_paid': 2000000,
        'remaining_debt': 3000000,
      },
      {
        'type': 'borrow',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'amount': 3000000,
        'item': 'Phone',
      },
    ];

    // Sắp xếp theo thời gian (mới nhất trước)
    final sortedHistory = List.from(history)
      ..sort((a, b) => b['date'].compareTo(a['date']));

    // Nhóm các giao dịch theo ngày
    final Map<String, List<Map<String, dynamic>>> groupedHistory = {};
    for (var record in sortedHistory) {
      final date = DateFormat('EEEE, dd/MM/yyyy').format(record['date']);
      if (!groupedHistory.containsKey(date)) {
        groupedHistory[date] = [];
      }
      groupedHistory[date]!.add(record);
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
      body: SafeArea(
        child: Column(
          children: [
            // Header với thông tin khách hàng
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 14, 19, 29),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
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
                              customer['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customer['address'],
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
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Keyword: ${customer['keyword']}',
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
            // Phần lịch sử và nút thêm
            Expanded(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Debit History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child:
                              history.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'No debit history available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    itemCount: groupedHistory.length,
                                    itemBuilder: (context, index) {
                                      final date = groupedHistory.keys
                                          .elementAt(index);
                                      final recordsForDate =
                                          groupedHistory[date]!;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              16,
                                              16,
                                              8,
                                            ),
                                            child: Text(
                                              date,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ...recordsForDate
                                              .map(
                                                (record) => Container(
                                                  margin: const EdgeInsets.only(
                                                    bottom: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                record['type'] ==
                                                                        'borrow'
                                                                    ? Colors.red
                                                                        .withOpacity(
                                                                          0.1,
                                                                        )
                                                                    : Colors
                                                                        .green
                                                                        .withOpacity(
                                                                          0.1,
                                                                        ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            record['type'] ==
                                                                    'borrow'
                                                                ? Icons
                                                                    .remove_circle
                                                                : Icons
                                                                    .add_circle,
                                                            color:
                                                                record['type'] ==
                                                                        'borrow'
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green,
                                                            size: 24,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                record['type'] ==
                                                                        'borrow'
                                                                    ? 'Borrowed: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(record['amount'])}'
                                                                    : 'Paid: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(record['amount_paid'])}',
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              if (record['type'] ==
                                                                  'borrow')
                                                                Text(
                                                                  'Item: ${record['item']}',
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                              if (record['type'] ==
                                                                  'repay')
                                                                Text(
                                                                  'Remaining: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(record['remaining_debt'])}',
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'Time: ${DateFormat('HH:mm').format(record['date'])}',
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ],
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Nút thêm item cố định ở cuối trang
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        // TODO: Xử lý khi nhấn nút thêm
                      },
                      backgroundColor: const Color.fromARGB(255, 14, 19, 29),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
