// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';

import '../controller/document_editor_with_ai.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatInterface extends StatefulWidget {
  const ChatInterface({Key? key, required this.editorWithAI}) : super(key: key);
  final DocumentEditorWithAI editorWithAI;

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _textController = TextEditingController();
  bool isLoading = false;

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      isLoading = true;
    });

    // AI response
    if (text.isNotEmpty) {
      widget.editorWithAI.userPrompt = text;
      await widget.editorWithAI.sendToAI(text, mounted);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        // Input area
        Container(
          padding: EdgeInsets.all(isMobile ? 4 : 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.centerLeft,

                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Enter the topic you want to write about...',
                      border: InputBorder.none,
                      helperMaxLines: 3,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: isLoading ? null : _handleSubmitted,
                  ),
                ),
              ),
              IconButton(
                icon:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                onPressed:
                    () =>
                        isLoading
                            ? null
                            : _handleSubmitted(_textController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
