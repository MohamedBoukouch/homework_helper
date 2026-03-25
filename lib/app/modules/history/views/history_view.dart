import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../../config/database_helper.dart';

// ════════════════════════════════════════════════════════════════════════════
//  HISTORY PAGE  — reads all scans from local SQLite
// ════════════════════════════════════════════════════════════════════════════
class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<ScanRecord> _scans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    setState(() => _loading = true);
    final scans = await DatabaseHelper.instance.getAllScans();
    if (mounted)
      setState(() {
        _scans = scans;
        _loading = false;
      });
  }

  Future<void> _deleteScan(int id) async {
    await DatabaseHelper.instance.deleteScan(id);
    _loadScans();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Clear history?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'All saved scans will be deleted permanently.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete all',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteAll();
      _loadScans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6BCB77)),
                  )
                : _scans.isEmpty
                ? _buildEmpty()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() => SafeArea(
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
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_scans.isNotEmpty)
            GestureDetector(
              onTap: _clearAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Clear all',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.history_rounded, color: Colors.white12, size: 72),
        const SizedBox(height: 16),
        const Text(
          'No scans yet',
          style: TextStyle(color: Colors.white38, fontSize: 16),
        ),
      ],
    ),
  );

  Widget _buildList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
    itemCount: _scans.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, i) =>
        _ScanCard(scan: _scans[i], onDelete: () => _deleteScan(_scans[i].id!)),
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  SCAN CARD
// ════════════════════════════════════════════════════════════════════════════
class _ScanCard extends StatefulWidget {
  final ScanRecord scan;
  final VoidCallback onDelete;

  const _ScanCard({required this.scan, required this.onDelete});

  @override
  State<_ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<_ScanCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y  HH:mm').format(widget.scan.createdAt);
    final isDone = widget.scan.status == 'done';
    final isError = widget.scan.status == 'error';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError
              ? Colors.redAccent.withOpacity(0.3)
              : const Color(0xFF6BCB77).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: File(widget.scan.imagePath).existsSync()
                      ? Image.file(
                          File(widget.scan.imagePath),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: Colors.white10,
                          child: const Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.white30,
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isError
                                  ? Colors.redAccent.withOpacity(0.15)
                                  : isDone
                                  ? const Color(0xFF6BCB77).withOpacity(0.15)
                                  : Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.scan.status.toUpperCase(),
                              style: TextStyle(
                                color: isError
                                    ? Colors.redAccent
                                    : isDone
                                    ? const Color(0xFF6BCB77)
                                    : Colors.amber,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Expand / Delete
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: Colors.white54,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Expanded result ──────────────────────────────────────────────
          if (_expanded && widget.scan.result.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MarkdownBody(
                  data: widget.scan.result,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    h1: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    h3: const TextStyle(
                      color: Color(0xFF6BCB77),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    code: const TextStyle(
                      color: Color(0xFFFFD93D),
                      backgroundColor: Color(0xFF1E1E1E),
                      fontSize: 12,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    listBullet: const TextStyle(color: Color(0xFF6BCB77)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
