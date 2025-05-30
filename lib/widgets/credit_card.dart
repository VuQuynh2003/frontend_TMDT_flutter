import 'package:flutter/material.dart';

class CreditCard extends StatelessWidget {
  const CreditCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: const Color.fromARGB(255, 14, 19, 29),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Image.asset(
                        "assets/credit-card.png",
                        height: 40,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 70,
                      child: Image.asset(
                        "assets/wifi.png",
                        height: 55,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: const Text(
                        "**** **** **** 7296",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: const Color.fromARGB(255, 245, 245, 245),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '\$10.000.000',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 14, 19, 29),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: const Color.fromARGB(
                              255,
                              14,
                              19,
                              29,
                            ).withOpacity(0.8),
                          ),
                          Transform.translate(
                            offset: const Offset(-10, 0),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: const Color.fromARGB(
                                255,
                                14,
                                19,
                                29,
                              ).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
