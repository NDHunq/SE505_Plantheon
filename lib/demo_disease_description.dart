import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/home/diseaseDescription.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantheon Disease Description Demo',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const DiseaseDescriptionScreen(),
    );
  }
}
