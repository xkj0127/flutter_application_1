import 'dart:math';
import 'package:flutter/material.dart';
import './bubble_pages/bubble_1.dart';
import './bubble_pages/bubble_2.dart';
import './bubble_pages/bubble_3.dart';
import './bubble_pages/bubble_4.dart';
import './bubble_pages/bubble_5.dart';
import './bubble_pages/bubble_6.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(MyApp());
  _requestMicrophonePermission(); // 请求麦克风权限
}

Future<void> _requestMicrophonePermission() async {
  PermissionStatus status = await Permission.microphone.request();
  if (status.isGranted) {
    print("麦克风权限已获取");
  } else {
    print("麦克风权限被拒绝");
  }
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
  final double radius = 150.0;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? _recordedFilePath;  // 保存录音的文件路径
  String recognizedText = '';  // 新增变量，用于存储识别的文本

  List<String> messages = [];  // 用于存储所有消息
  bool showHistory = false;  // 控制是否显示历史消息
  double _messageHeight = 0.0;  // 当前消息的高度
  

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  // 初始化录音机
  Future<void> _initRecorder() async {
    await _recorder.openRecorder(); // 直接使用 openRecorder() 初始化
  }

  Future<String> _getFilePath() async {
    final directory = await getTemporaryDirectory(); // 获取临时目录
    final filePath = '${directory.path}/audio.wav'; // 拼接文件路径
    return filePath;
  }

  Future<void> _startRecording() async {
    String filePath = await _getFilePath();  // 获取正确的文件路径
    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
      sampleRate: 44100,
      numChannels: 1
    );  // 开始录音
    setState(() {
      isRecording = true;
      _recordedFilePath = filePath;  // 保存文件路径
    });
  }

  // 停止录音
  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });
    // 发送录音文件给后端处理
    if (_recordedFilePath != null) {
      _sendAudioToBackend(_recordedFilePath!);
    }
  }

  Future<void> _sendAudioToBackend(String filePath) async {
    var uri = Uri.parse('http://192.168.3.9:8000/upload-audio/'); // 后端地址
    var request = http.MultipartRequest('POST', uri);

    // 打开音频文件并确保路径存在
    var audioFile = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(audioFile);

    // 发送请求
    var response = await request.send();

    if (response.statusCode == 200) {
      // 使用 then 处理响应
      response.stream.bytesToString().then((responseData) {
        print('Response data: $responseData');
        print('Response data type: ${responseData.runtimeType}');
        // 有坑，他喵的
        responseData = responseData.replaceAll(RegExp(r'^"|"$'), '');  // 去掉首尾的双引号
        // 打印日志确认是否进入了这个条件
        if (responseData.contains("打开菜单")) {
          print('显示泡泡');
          setState(() {
            showOptions = true;
            recognizedText = "测试："+responseData;
          });
        } else {
          print('未显示泡泡');
          setState(() {
            showOptions = false;
            recognizedText = "测试："+responseData;
          });
        }
      }).catchError((error) {
        // 错误处理
        print("Error occurred while processing response: $error");
      });
    } else {
      print('Failed to upload audio. Status code: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder(); // 清理资源
    super.dispose();
  }

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
            // 中心的小球按钮
            Center(
              child: GestureDetector(
                onTap: () {
                  if (isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
                child: AnimatedBall(isRecording: isRecording),
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
              Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recognizedText.isEmpty ? '等待语音识别...' : recognizedText,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              )
              )
          ],
        ),
      ),
    );
  }
}

class AnimatedBall extends StatelessWidget {
  final bool isRecording;

  AnimatedBall({required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return AnimatedBallInner(isRecording: isRecording);
  }
}

class AnimatedBallInner extends StatefulWidget {
  final bool isRecording;

  AnimatedBallInner({required this.isRecording});

  @override
  _AnimatedBallInnerState createState() => _AnimatedBallInnerState();
}

class _AnimatedBallInnerState extends State<AnimatedBallInner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double size = 80 + 20 * _controller.value;
        double opacity = 1 - _controller.value * 0.5;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: widget.isRecording ? Colors.red : Colors.blueAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.isRecording ? Colors.red.withOpacity(0.4) : Colors.blue.withOpacity(0.4),
                blurRadius: 8.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Icon(
                widget.isRecording ? Icons.stop : Icons.mic,
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
    offsets = List.generate(widget.numBubbles, (index) => Offset.zero);
    _controller = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  Offset _generateRandomOffset() {
    final random = Random();
    final xOffset = random.nextDouble() * 10;
    final yOffset = random.nextDouble() * 10 - 50;
    return Offset(xOffset, yOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.numBubbles, (index) {
        double angle = (2 * pi / widget.numBubbles) * index;
        double xOffset = widget.radius * cos(angle);
        double yOffset = widget.radius * sin(angle);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final randomOffset = _generateRandomOffset();

            return AnimatedPositioned(
              duration: Duration(milliseconds: 400),
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
    _controller.dispose();
    super.dispose();
  }
}
