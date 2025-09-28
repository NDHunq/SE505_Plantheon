import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/presentation/screens/home/diseaseDescription.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DiseaseProvider(
      baseUrl: ApiConstants.diseaseApiUrl,
      child: MaterialApp(
        title: 'Plantheon Disease Description Demo',
        theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
        home: const DiseaseDescriptionScreen(
          diseaseId: 'Corn_Blight_1146',
        ), // Pass disease ID
      ),
    );
  }
}
