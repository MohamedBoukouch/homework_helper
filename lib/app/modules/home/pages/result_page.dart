import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

// ════════════════════════════════════════════════════════════════════════════
//  DATA MODELS
// ════════════════════════════════════════════════════════════════════════════
enum _Role { user, ai }

class _Message {
  final _Role role;
  final String text;
  final List<String> images; // only for user messages
  final bool isLoading;

  const _Message({
    required this.role,
    this.text = '',
    this.images = const [],
    this.isLoading = false,
  });

  _Message copyWith({String? text, bool? isLoading}) => _Message(
    role: role,
    text: text ?? this.text,
    images: images,
    isLoading: isLoading ?? this.isLoading,
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  RESULT PAGE
// ════════════════════════════════════════════════════════════════════════════
class ResultPage extends StatefulWidget {
  final List<String> images;

  const ResultPage({super.key, required this.images});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late List<_Message> _messages;
  bool _isTyping = false;

  // Images attached to the next user message
  List<String> _pendingImages = [];

  // Typing indicator dots animation
  late AnimationController _dotCtrl;

  // ─── Mock AI answer ────────────────────────────────────────────────────────
  static const String _mockAnswer = '''
**Solution**

Looking at your question, here's a complete step-by-step explanation:

**Step 1 — Identify the problem**
From the image, this appears to be a quadratic equation:

> x² + 5x + 6 = 0

**Step 2 — Factor the expression**
We need two numbers that multiply to **6** and add to **5**:

→ (x + 2)(x + 3) = 0

**Step 3 — Solve for x**
Setting each factor to zero:
- x + 2 = 0  →  **x = −2**
- x + 3 = 0  →  **x = −3**

**Answer:** x = −2 or x = −3 ✅

---
Feel free to ask if you need further clarification or want me to verify using the quadratic formula.
''';

  @override
  void initState() {
    super.initState();

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Initial user message with the images
    _messages = [
      _Message(role: _Role.user, images: widget.images, text: 'Solve this'),
      const _Message(role: _Role.ai, isLoading: true),
    ];

    // Simulate AI response delay
    Future.delayed(const Duration(milliseconds: 1800), _deliverAnswer);
  }

  void _deliverAnswer() {
    if (!mounted) return;
    setState(() {
      _messages[_messages.length - 1] = const _Message(
        role: _Role.ai,
        text: _mockAnswer,
      );
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    final text = _inputCtrl.text.trim();
    final imgs = List<String>.from(_pendingImages);
    if (text.isEmpty && imgs.isEmpty) return;

    _inputCtrl.clear();
    setState(() {
      _pendingImages = [];
      _messages.add(_Message(role: _Role.user, text: text, images: imgs));
      _messages.add(const _Message(role: _Role.ai, isLoading: true));
    });
    _scrollToBottom();

    // Simulate AI reply
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _messages[_messages.length - 1] = _Message(
        role: _Role.ai,
        text:
            'Great follow-up! Based on your question "$text", here is the detailed explanation:\n\n'
            '**Analysis:** The concept you\'re asking about builds directly on the previous solution. '
            'Let me walk you through it step by step...\n\n'
            '> The key insight is to apply the same factoring technique.\n\n'
            '**Result:** The answer follows naturally from the prior working. ✅',
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickMoreImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _pendingImages.addAll(picked.map((f) => f.path)));
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    _focusNode.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: Row(
          children: [
            // Back
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6BCB77), Color(0xFF4DB6AC)],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Solver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6BCB77),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Add more images
            GestureDetector(
              onTap: _pickMoreImages,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Message list ───────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        return msg.role == _Role.user
            ? _UserBubble(msg: msg)
            : _AiBubble(msg: msg, dotCtrl: _dotCtrl);
      },
    );
  }

  // ── Input area ─────────────────────────────────────────────────────────────
  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pending image thumbnails
            if (_pendingImages.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  itemCount: _pendingImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == _pendingImages.length) {
                      return GestureDetector(
                        onTap: _pickMoreImages,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white54,
                            size: 22,
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_pendingImages[i]),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _pendingImages.removeAt(i)),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // Text field row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Image attach button
                  GestureDetector(
                    onTap: _pickMoreImages,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Text input
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        focusNode: _focusNode,
                        maxLines: null,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Ask a follow-up question…',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6BCB77), Color(0xFF4DB6AC)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  USER BUBBLE
// ════════════════════════════════════════════════════════════════════════════
class _UserBubble extends StatelessWidget {
  final _Message msg;
  const _UserBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Images grid
                if (msg.images.isNotEmpty) ...[
                  _ImageGrid(images: msg.images),
                  const SizedBox(height: 6),
                ],

                // Text bubble
                if (msg.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4D96FF), Color(0xFF845EF7)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Avatar
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white54,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  AI BUBBLE
// ════════════════════════════════════════════════════════════════════════════
class _AiBubble extends StatelessWidget {
  final _Message msg;
  final AnimationController dotCtrl;
  const _AiBubble({required this.msg, required this.dotCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6BCB77), Color(0xFF4DB6AC)],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Solver',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),

                // Loading or response
                msg.isLoading
                    ? _TypingIndicator(ctrl: dotCtrl)
                    : _AiResponseCard(text: msg.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  AI RESPONSE CARD  — renders markdown-lite styled text
// ════════════════════════════════════════════════════════════════════════════
class _AiResponseCard extends StatefulWidget {
  final String text;
  const _AiResponseCard({required this.text});

  @override
  State<_AiResponseCard> createState() => _AiResponseCardState();
}

class _AiResponseCardState extends State<_AiResponseCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    Future.delayed(
      const Duration(seconds: 2),
      () => mounted ? setState(() => _copied = false) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render simple markdown-lite
          _MarkdownText(text: widget.text),

          const SizedBox(height: 12),

          // Action row
          Row(
            children: [
              _ActionChip(
                icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                label: _copied ? 'Copied' : 'Copy',
                onTap: _copy,
                active: _copied,
              ),
              const SizedBox(width: 8),
              _ActionChip(
                icon: Icons.thumb_up_outlined,
                label: 'Helpful',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionChip(
                icon: Icons.refresh_rounded,
                label: 'Retry',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  MARKDOWN-LITE TEXT RENDERER
// ════════════════════════════════════════════════════════════════════════════
class _MarkdownText extends StatelessWidget {
  final String text;
  const _MarkdownText({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _renderLine(line)).toList(),
    );
  }

  Widget _renderLine(String line) {
    // Horizontal rule
    if (line.trim() == '---') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: Colors.white.withOpacity(0.12), height: 1),
      );
    }

    // Heading **text**
    if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
      final content = line.substring(2, line.length - 2);
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 2),
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    // Blockquote > text
    if (line.startsWith('> ')) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: const Border(
            left: BorderSide(color: Color(0xFF6BCB77), width: 3),
          ),
          color: Colors.white.withOpacity(0.04),
        ),
        child: Text(
          line.substring(2),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Bullet  - text or → text
    if (line.startsWith('- ') || line.startsWith('→ ')) {
      final content = line.substring(2);
      return Padding(
        padding: const EdgeInsets.only(top: 2, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• ',
              style: TextStyle(color: Color(0xFF6BCB77), fontSize: 14),
            ),
            Expanded(child: _inlineText(content)),
          ],
        ),
      );
    }

    // Empty line → small vertical gap
    if (line.trim().isEmpty) return const SizedBox(height: 4);

    // Normal line with inline **bold**
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: _inlineText(line),
    );
  }

  Widget _inlineText(String raw) {
    final spans = <TextSpan>[];
    final parts = raw.split('**');
    for (var i = 0; i < parts.length; i++) {
      final isBold = i.isOdd;
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            color: isBold ? Colors.white : Colors.white70,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            fontSize: 13.5,
            height: 1.55,
          ),
        ),
      );
    }
    return RichText(text: TextSpan(children: spans));
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ACTION CHIP
// ════════════════════════════════════════════════════════════════════════════
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF6BCB77).withOpacity(0.15)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? const Color(0xFF6BCB77).withOpacity(0.5)
              : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: active ? const Color(0xFF6BCB77) : Colors.white38,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? const Color(0xFF6BCB77) : Colors.white38,
            ),
          ),
        ],
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  TYPING INDICATOR (animated dots)
// ════════════════════════════════════════════════════════════════════════════
class _TypingIndicator extends StatelessWidget {
  final AnimationController ctrl;
  const _TypingIndicator({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          return AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) {
              final t = ((ctrl.value - delay) % 1.0 + 1.0) % 1.0;
              final opacity = (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2))
                  .clamp(0.0, 1.0);
              return Container(
                width: 7,
                height: 7,
                margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(opacity),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  IMAGE GRID (shows 1–4 images in a compact grid)
// ════════════════════════════════════════════════════════════════════════════
class _ImageGrid extends StatelessWidget {
  final List<String> images;
  const _ImageGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    final count = images.length.clamp(1, 4);
    final shown = images.take(count).toList();
    final extra = images.length - 4;

    if (shown.length == 1) {
      return _thumb(shown[0], 220, 160);
    }

    return SizedBox(
      width: 220,
      height: shown.length > 2 ? 160 : 90,
      child: GridView.count(
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: 1,
        children: List.generate(count, (i) {
          final isLast = i == count - 1 && extra > 0;
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(shown[i]), fit: BoxFit.cover),
              ),
              if (isLast)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+$extra',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _thumb(String path, double w, double h) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.file(File(path), width: w, height: h, fit: BoxFit.cover),
  );
}
