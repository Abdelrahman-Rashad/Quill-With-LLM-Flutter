import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import '../controller/document_editor_with_ai.dart';
import '../widgets/chat_interface.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late QuillController _quillController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  late final DocumentEditorWithAI _editorWithAI;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _editorWithAI = DocumentEditorWithAI(_quillController);
  }

  @override
  void dispose() {
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // Left side - Quill Editor
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QuillSimpleToolbar(
                            controller: _quillController,
                            config: QuillSimpleToolbarConfig(
                              showDirection: true,
                              showAlignmentButtons: !isMobile,

                              customButtons: [
                                QuillToolbarCustomButtonOptions(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  onPressed: () {
                                    _editorWithAI.generatePdfFromQuill(
                                      _quillController,
                                      _editorWithAI.userPrompt,
                                    );
                                  },
                                ),
                              ],
                              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                            ),
                          ),
                          SizedBox(height: isMobile ? 15 : 30),
                          Expanded(
                            child: QuillEditor.basic(
                              controller: _quillController,
                              focusNode: _focusNode,
                              scrollController: _scrollController,
                              config: QuillEditorConfig(
                                expands: true,
                                minHeight:
                                    MediaQuery.of(context).size.height *
                                    (2 / 3),

                                padding: EdgeInsets.symmetric(horizontal: 30),
                                readOnlyMouseCursor: SystemMouseCursors.text,
                                embedBuilders:
                                    kIsWeb
                                        ? FlutterQuillEmbeds.editorWebBuilders()
                                        : FlutterQuillEmbeds.editorBuilders(),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 15 : 30),
                        ],
                      ),
                    ),
                  ),

                  // Right side - Chat Interface
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: isMobile ? 5 : 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ChatInterface(editorWithAI: _editorWithAI),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
