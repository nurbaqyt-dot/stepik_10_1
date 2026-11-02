import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local File Read/Write Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ReadWriteFileExample(),
    );
  }
}
class ReadWriteFileExample extends StatefulWidget {
  const ReadWriteFileExample({super.key});
  @override
  State<ReadWriteFileExample> createState() =>
      _ReadWriteFileExampleState();
}
class _ReadWriteFileExampleState extends State<ReadWriteFileExample> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  static const String kLocalFileName = 'demo_localfile.txt';
  String _localFileContent = '';
  String _localFilePath = kLocalFileName;
  @override
  void initState() {
    super.initState();
    _initializeFile();
  }
  Future<void> _initializeFile() async {
    final file = await _getLocalFile();
    if (!mounted) return;
    setState(() {
      _localFilePath = file.path;
    });
    await _readTextFromLocalFile();
  }
  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local File Read/Write Demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Write to local file:',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          TextField(
            focusNode: _textFieldFocusNode,
            controller: _textController,
            maxLines: null,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your text...',
            ),
          ),
          const SizedBox(height: 10),
          ButtonBar(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _readTextFromLocalFile();
                  _textController.text = _localFileContent;
                  FocusScope.of(context).requestFocus(
                    _textFieldFocusNode,
                  );
                  log('Text successfully loaded');
                },
                child: const Text('Load'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _writeTextToLocalFile(
                    _textController.text,
                  );
                  await _readTextFromLocalFile();
                  log('Text successfully saved');
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const Divider(height: 30),
          Text(
            'Local file path:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          SelectableText(_localFilePath),
          const Divider(height: 30),
          Text(
            'Local file content:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(_localFileContent),
        ],
      ),
    );
  }
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> _getLocalFile() async {
    final path = await _getLocalPath();
    return File('$path/$kLocalFileName');
  }
  Future<File> _writeTextToLocalFile(String text) async {
    final file = await _getLocalFile();
    return file.writeAsString(text);
  }
  Future<void> _readTextFromLocalFile() async {
    String content;
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        content = await file.readAsString();
      } else {
        content = 'File does not exist yet.';
      }
    } catch (e) {
      content = 'Error loading local file: $e';
    }
    if (!mounted) return;
    setState(() {
      _localFileContent = content;
    });
  }
}