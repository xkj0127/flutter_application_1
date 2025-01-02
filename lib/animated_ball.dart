import 'package:flutter/material.dart';

class AnimatedBall extends StatefulWidget {
  @override
  _AnimatedBallState createState() => _AnimatedBallState();
}

class _AnimatedBallState extends State<AnimatedBall> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // 循环播放呼吸动画
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 呼吸动画效果：改变大小和透明度
        double size = 80 + 20 * _controller.value; // 小球大小从80到100之间变化
        double opacity = 1 - _controller.value * 0.5; // 透明度从1到0.5变化
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 8.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
