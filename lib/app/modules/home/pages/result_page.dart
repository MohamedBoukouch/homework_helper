import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import '../../../config/database_helper.dart';

// ════════════════════════════════════════════════════════════════════════════
//  RESULT PAGE  — Qwen Vision via OpenRouter + SQLite local storage
// ════════════════════════════════════════════════════════════════════════════
class ResultPage extends StatefulWidget {
  final List<String> images;

  const ResultPage({super.key, required this.images});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  String _status = 'Preparing image…';
  String _result = '';
  bool _isLoading = true;
  bool _hasError = false;
  int? _savedId;

  late AnimationController _dotCtrl;
  late Animation<int> _dotAnim;

  // ── 🔑  Paste your OpenRouter key here (free at openrouter.ai → Keys) ─────
  static const _openRouterKey =
      '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';

  // Free vision models tried in order — first one that works is used.
  // All confirmed available as of March 2026 on OpenRouter free tier.
  static const _models = [
    'qwen/qwen2.5-vl-32b-instruct:free',
    'qwen/qwen2.5-vl-72b-instruct:free',
    'meta-llama/llama-3.2-11b-vision-instruct:free',
    'mistralai/mistral-small-3.1-24b-instruct:free',
  ];
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotAnim = IntTween(begin: 0, end: 3).animate(_dotCtrl);
    _runPipeline();
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    super.dispose();
  }

  // ── Pipeline ──────────────────────────────────────────────────────────────
  Future<void> _runPipeline() async {
    try {
      setState(() => _status = 'Saving scan locally…');
      final record = ScanRecord(
        imagePath: widget.images.isNotEmpty ? widget.images[0] : '',
        result: '',
        status: 'pending',
        createdAt: DateTime.now(),
      );
      _savedId = await DatabaseHelper.instance.insertScan(record);

      setState(() => _status = 'Calling Qwen Vision…');
      final answer = await _callWithFallback(widget.images[0]);

      if (_savedId != null) {
        await DatabaseHelper.instance.updateScan(_savedId!, answer, 'done');
      }

      if (!mounted) return;
      setState(() {
        _result = answer;
        _isLoading = false;
        _status = 'Done';
      });
    } catch (e) {
      debugPrint('Pipeline error: $e');
      if (_savedId != null) {
        await DatabaseHelper.instance.updateScan(
          _savedId!,
          'Error: $e',
          'error',
        );
      }
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
        _status = 'Error';
        _result = 'Something went wrong:\n$e';
      });
    }
  }

  // ── Try each free model in order until one succeeds ───────────────────────
  Future<String> _callWithFallback(String imagePath) async {
    Exception? lastError;
    for (final model in _models) {
      try {
        debugPrint('Trying model: $model');
        if (mounted) setState(() => _status = 'Calling $model…');
        return await _callOpenRouter(imagePath, model);
      } catch (e) {
        debugPrint('Model $model failed: $e');
        lastError = Exception('$model failed: $e');
      }
    }
    throw lastError ?? Exception('All models failed.');
  }

  // ── OpenRouter vision call (OpenAI-compatible format) ─────────────────────
  Future<String> _callOpenRouter(String imagePath, String model) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final ext = imagePath.toLowerCase().split('.').last;
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_openRouterKey',
            'HTTP-Referer': 'https://ai-tutor-app.com',
            'X-Title': 'AI Tutor App',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text':
                        'You are an expert tutor. Look at this image carefully and solve the problem or answer the question shown. Provide a clear, step-by-step explanation formatted in Markdown.',
                  },
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
                  },
                ],
              },
            ],
            'max_tokens': 2048,
            'temperature': 0.3,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception(
        'OpenRouter error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // Check for API-level error inside a 200 response
    if (json.containsKey('error')) {
      throw Exception('API error: ${json['error']}');
    }

    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('No choices returned.');
    }
    final message = choices[0]['message'] as Map<String, dynamic>?;
    if (message == null) throw Exception('Empty message in response.');
    final content = message['content'];
    if (content == null || (content is String && content.trim().isEmpty)) {
      throw Exception('Empty content in response.');
    }
    return content as String;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6BCB77), Color(0xFF4DB6AC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Qwen AI',
              style: TextStyle(
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

        if (_savedId != null && !_hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF6BCB77),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Saved locally (ID: $_savedId)',
                  style: const TextStyle(
                    color: Color(0xFF6BCB77),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: Colors.white70,
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

        if (_hasError)
          GestureDetector(
            onTap: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _result = '';
              });
              _runPipeline();
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

        if (!_hasError && !_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/history'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1.2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'View History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
