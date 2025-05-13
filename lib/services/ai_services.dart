import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static String apiKey = dotenv.env['GEMINI_API_KEY']!;
  late final GenerativeModel model;

  AIService() {
    model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  Future<String> getAIResponse(
    String documentContent,
    String userPrompt,
  ) async {
    try {
      //       final content = [
      //         Content.text("""
      // You are a formatting bot. Respond only in raw, valid Quill Delta JSON with rich formatting .

      // Rules:
      // - All strings must escape line breaks as \\n, not raw newlines
      // - All internal quotes must be escaped as \"
      // - No Markdown blocks (no ```json)

      // Example:

      // [
      //   {"insert":"AI Summary\\n", "attributes":{"header":1}},
      //   {"insert":"Gemini is an ", "attributes":{"italic":true}},
      //   {"insert":"AI model", "attributes":{"bold":true}},
      //   {"insert":" from Google.\\n"}
      // ]
      // Document content:\n$documentContent\n\nUser prompt: $userPrompt
      //           """),
      //       ];
      final content = [
        Content.text("""
You are a smart document writer.

Output must be a **pure JSON array**, compatible with Flutter Quill `Delta.fromJson()`.

 No markdown (e.g. no ```json).
 No explanations.
Only return a raw JSON array like this:

🎯 Requirements:
Generate a professional report. The document should include:
1. Title: [Document Title]
2. Introduction (brief overview of the topic).
3. Main Body:
   - Section 1: [Subheading 1]
   - Section 2: [Subheading 2]
   - Section 3: [Subheading 3]
4. Conclusion: [summary of key findings or insights]
5. Use bullet points for lists and add colors to the text make it more modern design and add padding and margin to make the design nice.
6. Don't add images or videos to the document and Don't set text with white color.
7. make the text more readable and more beautiful [make sure that can be done in the quill editor].
8. colors should be modern and beautiful don't add it every where make it look nice and beautiful.
9. make the documnet more than 2 pages.

 Example snippet:
[
  { "insert": "Football: The World's Game\\n", "attributes": { "header": 1 } },
  { "insert": "Football, also known as soccer, is the most popular sport worldwide.\\n\\n" },
  { "insert": "Key Features:\\n", "attributes": { "bold": true } },
  { "insert": "Watch a great moment in football:\\n" }

]

Now generate a full document about $userPrompt in this format.
          """),
      ];
      final response = await model.generateContent(content);
      return response.text!
              .replaceAll(RegExp(r'```json'), '')
              .replaceAll(RegExp(r'```'), '')
              .trim() ??
          '';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
