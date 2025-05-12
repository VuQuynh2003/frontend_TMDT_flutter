import 'package:flutter/material.dart';
import 'widgets/auth_wrapper.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/items_list_page.dart';
import 'pages/customer_list_page.dart';
import 'pages/debit_form_page.dart';
import 'pages/debit_history_page.dart';
import 'pages/customer_detail_page.dart';
import 'pages/item_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý tài chính',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 16, 80, 98),
        ),
        useMaterial3: true,
      ),
      home: AuthWrapper(child: const HomePage()),
      routes: {
        '/home': (context) => const HomePage(),
        '/items': (context) => const ItemsListPage(),
        '/customers': (context) => const CustomerListPage(),
        '/debit_form': (context) => const DebitFormPage(),
        '/debit_history': (context) => const DebitHistoryPage(),
        '/customer_detail': (context) => const CustomerDetailPage(),
        '/item_detail': (context) => const ItemDetailPage(),
      },
    );
  }
}
