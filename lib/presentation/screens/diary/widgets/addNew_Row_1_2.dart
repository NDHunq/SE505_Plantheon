import 'package:flutter/material.dart';

/// Widget tái sử dụng cho form row với label và child
class AddNewRow extends StatelessWidget {
  final String label;
  final Widget child;

  const AddNewRow({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                flex: 3,
                child: Align(alignment: Alignment.centerRight, child: child),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
