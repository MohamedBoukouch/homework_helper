import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════════════════════
//  RESULT PAGE  — calls AI (GPT-4o / Gemini) and displays the answer
// ════════════════════════════════════════════════════════════════════════════
class ResultPage extends StatefulWidget {
  final List<String> images;
  final String scanId;

  const ResultPage({super.key, required this.images, required this.scanId});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  String _status = 'Extracting text from image…';
  String _result = '';
  bool _isLoading = true;
  bool _hasError = false;

  late AnimationController _dotCtrl;
  late Animation<int> _dotAnim;

  // ── Replace with your actual keys ────────────────────────────────────────
  static const _openAiKey = 'YOUR_OPENAI_API_KEY';
  static const _geminiKey = 'YOUR_GEMINI_API_KEY';
  // Set to true to use Gemini, false to use GPT-4o
  static const _useGemini = false;
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotAnim = IntTween(begin: 0, end: 3).animate(_dotCtrl);
    _runAIPipeline();
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    super.dispose();
  }

  // ── Main pipeline ─────────────────────────────────────────────────────────
  Future<void> _runAIPipeline() async {
    try {
      // Step 1 – read imageUrl stored by camera page
      setState(() => _status = 'Reading scan data…');
      final doc = await FirebaseFirestore.instance
          .collection('scans')
          .doc(widget.scanId)
          .get();
      final imageUrl = doc.data()?['imageUrl'] as String? ?? '';

      // Step 2 – call AI
      setState(
        () => _status = _useGemini
            ? 'Calling Gemini Vision…'
            : 'Calling GPT-4o Vision…',
      );

      final answer = _useGemini
          ? await _callGemini(imageUrl)
          : await _callGpt4o(imageUrl);

      // Step 3 – persist result to Firestore
      await FirebaseFirestore.instance
          .collection('scans')
          .doc(widget.scanId)
          .update({
            'result': answer,
            'status': 'done',
            'solvedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      setState(() {
        _result = answer;
        _isLoading = false;
        _status = 'Done';
      });
    } catch (e) {
      debugPrint('AI pipeline error: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
        _status = 'Error';
        _result = 'Something went wrong: $e';
      });
    }
  }

  // ── GPT-4o Vision ─────────────────────────────────────────────────────────
  Future<String> _callGpt4o(String imageUrl) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'You are an expert tutor. Look at this image and solve the problem or answer the question shown. Provide a clear, step-by-step explanation.',
              },
              {
                'type': 'image_url',
                'image_url': {'url': imageUrl, 'detail': 'high'},
              },
            ],
          },
        ],
        'max_tokens': 1500,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('GPT-4o error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return json['choices'][0]['message']['content'] as String;
  }

  // ── Gemini 1.5 Pro Vision ─────────────────────────────────────────────────
  Future<String> _callGemini(String imageUrl) async {
    // Download image bytes to send as inline_data
    final imgBytes = (await http.get(Uri.parse(imageUrl))).bodyBytes;
    final base64Img = base64Encode(imgBytes);

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$_geminiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are an expert tutor. Look at this image and solve the problem or answer the question shown. Provide a clear, step-by-step explanation.',
              },
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Img},
              },
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': 1500},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return json['candidates'][0]['content']['parts'][0]['text'] as String;
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(child: _isLoading ? _buildLoading() : _buildResult()),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Solution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // AI badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6BCB77), Color(0xFF4DB6AC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _useGemini ? 'Gemini' : 'GPT-4o',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated scanner icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6BCB77), Color(0xFF4DB6AC)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6BCB77).withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 28),
        AnimatedBuilder(
          animation: _dotAnim,
          builder: (_, __) {
            final dots = '.' * (_dotAnim.value + 1);
            return Text(
              '$_status$dots',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            );
          },
        ),
        const SizedBox(height: 12),
        const SizedBox(
          width: 180,
          child: LinearProgressIndicator(
            backgroundColor: Colors.white12,
            color: Color(0xFF6BCB77),
            minHeight: 3,
          ),
        ),
      ],
    ),
  );

  Widget _buildResult() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        if (widget.images.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(widget.images[0]),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 20),

        // Result card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hasError
                  ? Colors.redAccent.withOpacity(0.5)
                  : const Color(0xFF6BCB77).withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: _hasError
              ? Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _result,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              : MarkdownBody(
                  data: _result,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.white38,
                      fontSize: 15,
                      height: 1.6,
                    ),
                    h1: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    h3: const TextStyle(
                      color: Color(0xFF6BCB77),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    code: const TextStyle(
                      color: Color(0xFFFFD93D),
                      backgroundColor: Color(0xFF1E1E1E),
                      fontSize: 13,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    listBullet: const TextStyle(color: Color(0xFF6BCB77)),
                  ),
                ),
        ),

        const SizedBox(height: 24),

        // Try again button
        if (_hasError)
          GestureDetector(
            onTap: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _result = '';
              });
              _runAIPipeline();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6BCB77), Color(0xFF4DB6AC)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
