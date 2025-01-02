// lib/bubble_5.dart
import 'package:flutter/material.dart';

class Bubble5Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('泡泡 5'),
      ),
      body: Center(
        child: Text(
          '这是泡泡 5 的内容',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
