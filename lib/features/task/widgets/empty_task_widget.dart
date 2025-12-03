import 'package:flutter/material.dart';

class EmptyTaskWidget extends StatelessWidget {
  const EmptyTaskWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/bro3.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.task_outlined,
                size: 100,
                color: Colors.grey,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            "You don't have any task yet",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
