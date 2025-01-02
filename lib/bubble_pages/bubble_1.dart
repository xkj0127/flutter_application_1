// lib/bubble_1.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;


class Bubble1Page extends StatefulWidget {
  @override
  _Bubble1PageState createState() => _Bubble1PageState();
}

class _Bubble1PageState extends State<Bubble1Page> {
  String? _filePath;
  String? _selectedOption;
  final TextEditingController _textController = TextEditingController();
  final List<String> _options = ['选项 1', '选项 2', '选项 3'];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_filePath == null) {
      // 提示用户选择文件
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("请先选择文件")));
      return;
    }

    var uri = Uri.parse('http://192.168.3.9:8000/upload'); // 替换为你的后端地址
    var request = http.MultipartRequest('POST', uri);

    // 将选择的文件加入请求中
    request.files.add(await http.MultipartFile.fromPath(
      'file', // 后端接收字段名称
      _filePath!,
    ));

    // 传递额外的字段，如文本和选项
    request.fields['option'] = _selectedOption ?? '未选择';
    request.fields['text'] = _textController.text;

    // 发送请求
    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("文件上传成功")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("文件上传失败")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('泡泡 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('选择文件'),
            ),
            if (_filePath != null) ...[
              SizedBox(height: 10),
              Text('选择的文件: $_filePath'),
            ],
            
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedOption,
              hint: Text('选择一个选项'),
              items: _options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOption = value;
                });
              },
            ),

            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: '输入文本',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile, // 上传文件
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}
