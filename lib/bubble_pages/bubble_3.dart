// lib/bubble_1.dart
import 'package:flutter/material.dart';

class Bubble3Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('泡泡 3'),
      ),
      body: Center(
        child: Text(
          '这是泡泡 3 的内容',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
