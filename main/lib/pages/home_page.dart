import 'package:flutter/material.dart';
import 'package:main/widget/page_widget.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Lista de Tarefas'),
      ),
      body: ListView(
        children: [
          PageWidget(),
        ],
      )
    );
  }
}
