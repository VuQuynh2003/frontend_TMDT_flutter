import 'package:flutter/material.dart';
import '../widgets/credit_card.dart';
import '../widgets/debit_history_list.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back!",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Quynh Vu!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications clicked'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications),
                        color: Colors.white,
                        tooltip: 'Notifications',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout),
                        color: Colors.white,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const CreditCard(),
                // Thanh ngang chứa 4 icon
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickActionIcon(
                        icon: Icons.list_alt,
                        label: 'Items',
                        onPressed: () {
                          Navigator.pushNamed(context, '/items');
                        },
                      ),
                      _QuickActionIcon(
                        icon: Icons.group,
                        label: 'Customers',
                        onPressed: () {
                          Navigator.pushNamed(context, '/customers');
                        },
                      ),
                      _QuickActionIcon(
                        icon: Icons.add_circle,
                        label: 'Add Debit',
                        onPressed: () {
                          Navigator.pushNamed(context, '/debit_form');
                        },
                      ),
                      _QuickActionIcon(
                        icon: Icons.history,
                        label: 'Debit History',
                        onPressed: () {
                          Navigator.pushNamed(context, '/debit_history');
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: const DebitList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Home clicked')));
              },
              icon: const Icon(Icons.home),
              color: Colors.black,
              tooltip: 'Home',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/customers');
              },
              icon: const Icon(Icons.group),
              color: Colors.black,
              tooltip: 'Customers',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/debit_form');
              },
              icon: const Icon(
                Icons.add_circle,
                color: Color.fromARGB(255, 16, 80, 98),
                size: 40,
              ),
              tooltip: 'Add Debit',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/items');
              },
              icon: const Icon(Icons.list_alt),
              color: Colors.black,
              tooltip: 'Items List',
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile clicked')),
                );
              },
              icon: const Icon(Icons.person),
              color: Colors.black,
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget cho icon truy cập nhanh
class _QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionIcon({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: const Color.fromARGB(255, 14, 19, 29),
            size: 30,
          ),
          tooltip: label,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 14, 19, 29),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
