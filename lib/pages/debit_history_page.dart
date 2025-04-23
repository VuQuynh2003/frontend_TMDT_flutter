import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DebitHistoryPage extends StatefulWidget {
  const DebitHistoryPage({super.key});

  @override
  State<DebitHistoryPage> createState() => _DebitHistoryPageState();
}

class _DebitHistoryPageState extends State<DebitHistoryPage> {
  // Dữ liệu mẫu cho giao diện
  late final List<Map<String, dynamic>> debits;

  @override
  void initState() {
    super.initState();
    debits = [
      {
        'name': 'Alice Johnson',
        'keyword': 'Con ông A',
        'amount': 5000000,
        'status': 'fully_paid',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'name': 'Bob Smith',
        'keyword': 'Bà B',
        'amount': 3000000,
        'status': 'partially_paid',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'name': 'Charlie Brown',
        'keyword': 'Anh C',
        'amount': 10000000,
        'status': 'never_paid',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'name': 'David Wilson',
        'keyword': 'Chị D',
        'amount': 2000000,
        'status': 'fully_paid',
        'timestamp': DateTime.now().subtract(const Duration(days: 4)),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Sắp xếp theo thời gian (mới nhất trước)
    final sortedDebits = List.from(debits)
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    // Nhóm các khoản nợ theo ngày
    final Map<String, List<Map<String, dynamic>>> groupedDebits = {};
    for (var debit in sortedDebits) {
      final date = DateFormat('EEEE, dd/MM/yyyy').format(debit['timestamp']);
      if (!groupedDebits.containsKey(date)) {
        groupedDebits[date] = [];
      }
      groupedDebits[date]!.add(debit);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 19, 29),
        title: const Text(
          'Debit History',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'All Debits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: groupedDebits.length,
                  itemBuilder: (context, index) {
                    final date = groupedDebits.keys.elementAt(index);
                    final debitsForDate = groupedDebits[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 16, 80, 98),
                            ),
                          ),
                        ),
                        ...debitsForDate
                            .map(
                              (debit) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(debit['status']),
                                        color: _getStatusColor(debit['status']),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              debit['name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Keyword: ${debit['keyword']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Amount: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(debit['amount'])}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Time: ${DateFormat('HH:mm').format(debit['timestamp'])}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
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
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'fully_paid':
        return Icons.check_circle;
      case 'partially_paid':
        return Icons.timelapse;
      case 'never_paid':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'fully_paid':
        return Colors.purpleAccent;
      case 'partially_paid':
        return Colors.purpleAccent;
      case 'never_paid':
        return Colors.purpleAccent;
      default:
        return Colors.purpleAccent;
    }
  }
}
