import 'package:flutter/material.dart';
import 'fuhrpark_page.dart';

class FahrschulePage extends StatelessWidget {
  const FahrschulePage({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fahrschule'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FuhrparkPage(),
              ),
            );
          },
          child: const Text('Fuhrpark'),
        ),
      ),
    );
  }
}