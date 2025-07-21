import 'package:flutter/material.dart';
import 'package:main/pages/home_page.dart';
import 'package:main/services/service_locator.dart';

void main() {
  setupGetIt();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
     theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 33, 46, 52)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 89, 32, 32),
    ),
      home: const HomePage(),
    );
  }
}
