import 'dart:math';
import 'package:flutter/material.dart';
import './bubble_pages/bubble_1.dart';
import './bubble_pages/bubble_2.dart';
import './bubble_pages/bubble_3.dart';
import './bubble_pages/bubble_4.dart';
import './bubble_pages/bubble_5.dart';
import './bubble_pages/bubble_6.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatHomePage extends StatefulWidget {
  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  bool showOptions = false;
  final int numBubbles = 6;
  final double bubbleSize = 60.0;
  final double radius = 150.0; // 距离中心的半径

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 语音助手'),
      ),
      body: GestureDetector(
        onDoubleTap: () {
          setState(() {
            showOptions = !showOptions;
          });
        },
        child: Stack(
          children: [
            // 替换为小球按钮
            Center(
              child: GestureDetector(
                onTap: () {
                  // 点击小球开始语音识别或跳转至聊天界面
                  print("语音助手启动");
                },
                child: AnimatedBall(), // 语音小球
              ),
            ),
            if (showOptions)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => showOptions = false),
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: AnimatedBubbleRing(
                        numBubbles: numBubbles,
                        bubbleSize: bubbleSize,
                        radius: radius,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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


class AnimatedBubbleRing extends StatefulWidget {
  final int numBubbles;
  final double bubbleSize;
  final double radius;

  AnimatedBubbleRing({required this.numBubbles, required this.bubbleSize, required this.radius});

  @override
  _AnimatedBubbleRingState createState() => _AnimatedBubbleRingState();
}

class _AnimatedBubbleRingState extends State<AnimatedBubbleRing> with SingleTickerProviderStateMixin {
  late List<Offset> offsets;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    offsets = List.generate(widget.numBubbles, (index) => Offset.zero); // 初始化偏移量为0
    _controller = AnimationController(
      duration: Duration(seconds: 5),  // 延长动画周期，减慢浮动速度
      vsync: this,
    )..repeat(); // 动画控制器循环
  }

  // 生成更小的随机浮动偏移量
  Offset _generateRandomOffset() {
    final random = Random();
    final xOffset = random.nextDouble() * 10 ; // 改为随机范围：-5 到 5
    final yOffset = random.nextDouble() * 10 - 50; // 改为随机范围：-5 到 5
    return Offset(xOffset, yOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.numBubbles, (index) {
        double angle = (2 * pi / widget.numBubbles) * index; // 每个泡泡的角度
        double xOffset = widget.radius * cos(angle); // 计算 X 偏移
        double yOffset = widget.radius * sin(angle); // 计算 Y 偏移

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 获取随机浮动偏移量
            final randomOffset = _generateRandomOffset();

            return AnimatedPositioned(
              duration: Duration(milliseconds: 400), // 设置短时动画，快速响应浮动
              left: MediaQuery.of(context).size.width / 2 + xOffset - widget.bubbleSize / 2 + randomOffset.dx,
              top: MediaQuery.of(context).size.height / 2 + yOffset - widget.bubbleSize / 2 + randomOffset.dy,
              child: GestureDetector(
                onTap: () {
                  // 根据 index 跳转到对应的页面
                  dynamic page;
                  switch (index) {
                    case 0:
                      page = Bubble1Page();
                      break;
                    case 1:
                      page = Bubble2Page();
                      break;
                    case 2:
                      page = Bubble3Page();
                      break;
                    case 3:
                      page = Bubble4Page();
                      break;
                    case 4:
                      page = Bubble5Page();
                      break;
                    case 5:
                      page = Bubble6Page();
                      break;
                    default:
                      break;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                },
                child: Hero(
                  tag: 'bubble_$index',
                  child: Container(
                    width: widget.bubbleSize,
                    height: widget.bubbleSize,
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
                      child: Text(
                        '选项 ${index + 1}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 清理动画控制器
    super.dispose();
  }
}


class DetailPage extends StatelessWidget {
  final int index;

  DetailPage({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选项 ${index + 1}'),
      ),
      body: Center(
        child: Hero(
          tag: 'bubble_$index',
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.blueAccent,
            child: Center(
              child: Text(
                '这是选项 ${index + 1} 的详细页面',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
