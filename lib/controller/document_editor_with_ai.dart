// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../services/ai_services.dart';

class DocumentEditorWithAI {
  final QuillController _controller;
  final AIService _aiService = AIService();
  String userPrompt;
  final PDFPageFormat pageFormat = PDFPageFormat.all(
    width: 600,
    height: 900,
    margin: 28,
  );

  DocumentEditorWithAI(this._controller, {this.userPrompt = ''});

  Future<void> sendToAI(String userPrompt, bool mounted) async {
    final currentDoc = _controller.document.toPlainText();

    // Get AI response
    final aiResponse = await _aiService.getAIResponse(currentDoc, userPrompt);
    log(aiResponse);
    final decodedJson = jsonDecode(aiResponse);
    final delta = Delta.fromJson(decodedJson);
    final quillDocument = Document.fromDelta(delta);
    _controller.document = quillDocument;
  }

  void onDocumentUpdatedOrThrow() {
    final deltaJson = _controller.document.toDelta().toJson();
    String _html = '';

    final QuillDeltaToHtmlConverter converter;

    converter = QuillDeltaToHtmlConverter(
      List.castFrom(deltaJson),
      ConverterOptions.forEmail(),
    );

    _html = converter.convert();

    // Force HTML to layout in a maximum width of 800px.
    _html = '<div style="max-width: 800px;">\n$_html\n</div>';
    final bytes = utf8.encode(_html);
    final blob = html.Blob([bytes], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', "htmlfile.html")
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> generatePdfFromQuill(
    QuillController controller,
    String userPrompt,
  ) async {
    final pdf = Document();

    // Convert the document to PDF widgets
    final pdfWidgets = PDFConverter(
      document: controller.document.toDelta(),
      isWeb: true,
      fallbacks: [],
      pageFormat: pageFormat,
    );

    final doc = await pdfWidgets.createDocument();

    // Save PDF to bytes
    Uint8List pdfBytes = await doc!.save();

    // Download or share based on platform (see below)
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute("download", "$userPrompt.pdf")
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
