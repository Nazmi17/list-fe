import 'package:flutter/material.dart';

class DashboardStatWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final String badge;

  const DashboardStatWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8BE4A9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Badge
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 60,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.black),
          ),
          const SizedBox(height: 16),
          // Label
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 8),

          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
