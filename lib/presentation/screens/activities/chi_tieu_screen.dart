import 'package:flutter/material.dart';

class ChiTieuScreen extends StatelessWidget {
  const ChiTieuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiêu')),
      body: const Center(child: Text('Màn hình Chi Tiêu')),
    );
  }
}