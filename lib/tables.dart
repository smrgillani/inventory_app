import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  TableScreenState createState() => TableScreenState();
}

class TableScreenState extends State<TableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView();
            }
        )
    );
  }
}