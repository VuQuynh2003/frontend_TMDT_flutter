import 'package:flutter/material.dart';

class DebitList extends StatelessWidget {
  const DebitList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 30),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today, Dec 29",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/debit_history');
                },
                child: const Row(
                  children: [
                    Text(
                      "All debit history",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const ListTile(
          leading: CircleAvatar(
            backgroundColor: Color.fromARGB(255, 239, 243, 245),
            child: Icon(Icons.check_circle, color: Colors.purpleAccent),
          ),
          title: Text("Gym Membership"),
          subtitle: Text("Monthly subscription"),
          trailing: Text("\$50.00"),
        ),

        const ListTile(
          leading: CircleAvatar(
            backgroundColor: Color.fromARGB(255, 239, 243, 245),
            child: Icon(Icons.timelapse, color: Colors.purpleAccent),
          ),
          title: Text("Gym Membership"),
          subtitle: Text("Monthly subscription"),
          trailing: Text("\$50.00"),
        ),

        const ListTile(
          leading: CircleAvatar(
            backgroundColor: Color.fromARGB(255, 239, 243, 245),
            child: Icon(Icons.cancel, color: Colors.purpleAccent),
          ),
          title: Text("Gym Membership"),
          subtitle: Text("Monthly subscription"),
          trailing: Text("\$50.00"),
        ),
      ],
    );
  }
}
