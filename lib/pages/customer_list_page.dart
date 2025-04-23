import 'package:flutter/material.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> customers = [
    {
      'name': 'Alice Johnson',
      'address': '123 Đường Láng, Hà Nội',
      'keyword': 'Con ông A',
    },
    {'name': 'Bob Smith', 'address': '456 Cầu Giấy, Hà Nội', 'keyword': 'Bà B'},
    {
      'name': 'Charlie Brown',
      'address': '789 Tây Hồ, Hà Nội',
      'keyword': 'Anh C',
    },
    {
      'name': 'David Wilson',
      'address': '101 Hoàn Kiếm, Hà Nội',
      'keyword': 'Chị D',
    },
  ];
  List<Map<String, dynamic>> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    customers.sort((a, b) => a['name'].compareTo(b['name']));
    filteredCustomers = customers;
    _searchController.addListener(_filterCustomers);
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCustomers =
          customers
              .where(
                (customer) => customer['name'].toLowerCase().contains(query),
              )
              .toList();
    });
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
          'Customer List',
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
                      hintText: 'Search by name',
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
                    child: ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/customer_detail',
                              arguments: customer,
                            );
                          },
                          child: Padding(
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
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      16,
                                      80,
                                      98,
                                    ),
                                    child: Text(
                                      customer['name'][0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      customer['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add new customer')),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 14, 19, 29),
                child: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Add Customer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
