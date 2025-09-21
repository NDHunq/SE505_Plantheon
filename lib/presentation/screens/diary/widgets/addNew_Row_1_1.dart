import 'package:flutter/material.dart';

/// Widget với text ở một row và text field ở một row riêng biệt
class AddNewRowVertical extends StatelessWidget {
  final String label;
  final Widget child;

  const AddNewRowVertical({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row cho label
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            children: [Text(label, style: const TextStyle(fontSize: 16))],
          ),
        ),
        // Row cho child (text field)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [Expanded(child: child)]),
        ),
      ],
    );
  }
}
