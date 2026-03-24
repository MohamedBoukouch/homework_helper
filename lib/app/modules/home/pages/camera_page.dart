import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'result_page.dart';

// ════════════════════════════════════════════════════════════════════════════
//  CAMERA PAGE
// ════════════════════════════════════════════════════════════════════════════
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isCameraReady = false;
  FlashMode _flashMode = FlashMode.off;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      final back = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      _controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
      if (mounted) setState(() => _isCameraReady = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isCameraReady) return;
    final next = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller!.setFlashMode(next);
    setState(() => _flashMode = next);
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) _openPreview(picked.path);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_isCameraReady) return;
    if (_controller!.value.isTakingPicture) return;
    try {
      final file = await _controller!.takePicture();
      if (mounted) _openPreview(file.path);
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  void _openPreview(String path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ImagePreviewPage(imagePath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildVignette(),
          _buildTopBar(),
          _buildScanFrame(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _controller == null) {
      return Container(
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.previewSize!.height,
          height: _controller!.value.previewSize!.width,
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildVignette() => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
      ),
    ),
  );

  Widget _buildTopBar() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
          Spacer(),
          Text(
            'Scan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          Spacer(),
          Text('👑', style: TextStyle(fontSize: 26)),
        ],
      ),
    ),
  );

  Widget _buildScanFrame() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Place your question\nat the center of the frame.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
            shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 280,
          height: 160,
          child: CustomPaint(
            painter: _ScanFramePainter(),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white54, size: 22),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildBottomControls() => Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'General',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _GalleryButton(onTap: _pickFromGallery),
                _CaptureButton(pulseAnim: _pulseAnim, onTap: _takePicture),
                _FlashButton(flashMode: _flashMode, onTap: _toggleFlash),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _BottomNavBar(),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  IMAGE PREVIEW PAGE  — resizable vital crop border + scanner effect
// ════════════════════════════════════════════════════════════════════════════
class ImagePreviewPage extends StatefulWidget {
  final String imagePath;
  final List<String> extraImages;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    this.extraImages = const [],
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage>
    with TickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();
  double _sliderValue = 0.0;

  // Crop rect (normalised 0–1 relative to image container)
  Rect _crop = const Rect.fromLTWH(0.08, 0.08, 0.84, 0.84);

  static const double _minScale = 1.0;
  static const double _maxScale = 3.5;
  static const double _handleSize = 16.0;

  late List<String> _images;

  // Scanner animation
  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;
  bool _isScanning = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _images = [widget.imagePath, ...widget.extraImages];

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scanAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut));
    _scanCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scanCtrl.repeat(reverse: true);
      }
    });
  }

  void _onSliderChanged(double v) {
    setState(() => _sliderValue = v);
    final scale = _minScale + (_maxScale - _minScale) * v;
    _transformCtrl.value = Matrix4.identity()..scale(scale);
  }

  Future<void> _addMoreImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked.map((f) => f.path)));
    }
  }

  /// Upload image to Firebase Storage, save metadata to Firestore,
  /// then navigate to ResultPage.
  Future<void> _goToResult() async {
    if (_isUploading) return;

    setState(() {
      _isScanning = true;
      _isUploading = true;
    });
    _scanCtrl.forward();

    try {
      // 1. Upload image to Firebase Storage
      final scanId = const Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child(
        'scans/$scanId/image.jpg',
      );

      final uploadTask = await storageRef.putFile(File(_images[0]));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 2. Save scan record to Firestore (status = pending, AI will fill result)
      await FirebaseFirestore.instance.collection('scans').doc(scanId).set({
        'id': scanId,
        'imageUrl': downloadUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Keep scanner running a bit longer for UX polish
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      _scanCtrl.stop();

      // 4. Navigate to ResultPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultPage(images: _images, scanId: scanId),
        ),
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      _scanCtrl.stop();
      setState(() {
        _isScanning = false;
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Image + resizable crop overlay ──────────────────────────────
          Positioned.fill(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final W = constraints.maxWidth;
                final H = constraints.maxHeight;
                return Stack(
                  children: [
                    // Pinch-zoom image
                    Positioned.fill(
                      child: InteractiveViewer(
                        transformationController: _transformCtrl,
                        minScale: _minScale,
                        maxScale: _maxScale,
                        child: Image.file(
                          File(_images[0]),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Dark mask outside crop rect
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: _CropMaskPainter(_crop)),
                      ),
                    ),

                    // Scanner line (animated, only while scanning)
                    if (_isScanning)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _scanAnim,
                            builder: (_, __) => CustomPaint(
                              painter: _ScanLinePainter(
                                crop: _crop,
                                progress: _scanAnim.value,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Draggable crop overlay with resize handles
                    if (!_isScanning)
                      _DraggableCropOverlay(
                        containerSize: Size(W, H),
                        crop: _crop,
                        handleSize: _handleSize,
                        onCropChanged: (r) => setState(() => _crop = r),
                      ),
                  ],
                );
              },
            ),
          ),

          // ── Top bar ──────────────────────────────────────────────────────
          if (!_isScanning)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _iconBtn(
                        Icons.close_rounded,
                        () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Preview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _iconBtn(
                        Icons.add_photo_alternate_rounded,
                        _addMoreImages,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Scanning overlay label ────────────────────────────────────────
          if (_isScanning)
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(bottom: 120),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6BCB77),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Scanning & Solving…',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Thumbnail strip (if multiple images) ──────────────────────────
          if (_images.length > 1 && !_isScanning)
            Positioned(
              left: 0,
              right: 0,
              bottom: 220,
              child: SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => setState(() {
                      final tmp = _images[0];
                      _images[0] = _images[i];
                      _images[i] = tmp;
                    }),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: i == 0
                              ? const Color(0xFF6BCB77)
                              : Colors.white30,
                          width: i == 0 ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.file(File(_images[i]), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom panel ──────────────────────────────────────────────────
          if (!_isScanning)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.96),
                        Colors.black.withOpacity(0.75),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom slider
                      Row(
                        children: [
                          const Icon(
                            Icons.photo_size_select_small_rounded,
                            color: Colors.white54,
                            size: 18,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                                overlayColor: Colors.white12,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 9,
                                ),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: _sliderValue,
                                min: 0,
                                max: 1,
                                onChanged: _onSliderChanged,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.photo_size_select_large_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Return | Solve
                      Row(
                        children: [
                          // RETURN
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Return',
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
                          const SizedBox(width: 12),
                          // SOLVE
                          Expanded(
                            child: GestureDetector(
                              onTap: _goToResult,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6BCB77),
                                      Color(0xFF4DB6AC),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6BCB77,
                                      ).withOpacity(0.45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_fix_high_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Solve',
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
                          ),
                        ],
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

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  SCAN LINE PAINTER  — animated green scanner beam inside crop area
// ════════════════════════════════════════════════════════════════════════════
class _ScanLinePainter extends CustomPainter {
  final Rect crop; // normalised 0–1
  final double progress; // 0–1

  const _ScanLinePainter({required this.crop, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      crop.left * size.width,
      crop.top * size.height,
      crop.width * size.width,
      crop.height * size.height,
    );

    // Clip to crop rect so scanner stays inside
    canvas.save();
    canvas.clipRect(rect);

    final y = rect.top + rect.height * progress;

    // Glow gradient beam
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF6BCB77).withOpacity(0.6),
          const Color(0xFF6BCB77).withOpacity(0.9),
          const Color(0xFF6BCB77).withOpacity(0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(rect.left, y - 20, rect.width, 40));

    canvas.drawRect(
      Rect.fromLTWH(rect.left, y - 20, rect.width, 40),
      beamPaint,
    );

    // Bright center line
    final linePaint = Paint()
      ..color = const Color(0xFF6BCB77)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) => old.progress != progress;
}

// ════════════════════════════════════════════════════════════════════════════
//  CROP MASK PAINTER  — dims outside crop, draws vital border + handles
// ════════════════════════════════════════════════════════════════════════════
class _CropMaskPainter extends CustomPainter {
  final Rect crop; // normalised 0–1
  const _CropMaskPainter(this.crop);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      crop.left * size.width,
      crop.top * size.height,
      crop.width * size.width,
      crop.height * size.height,
    );

    // Dark mask outside crop
    final mask = Paint()..color = Colors.black.withOpacity(0.52);
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(full)
      ..addRect(rect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, mask);

    // White outer border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);

    // Corner accent handles
    _drawCorners(canvas, rect);

    // Mid-edge handles (visual only, drag logic in overlay)
    _drawMidHandles(canvas, rect);
  }

  void _drawCorners(Canvas canvas, Rect r) {
    const len = 22.0;
    const w = 3.5;
    final p = Paint()
      ..color = const Color(0xFF6BCB77)
      ..strokeWidth = w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // TL
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(len, 0), p);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, len), p);
    // TR
    canvas.drawLine(r.topRight, r.topRight + const Offset(-len, 0), p);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, len), p);
    // BL
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(len, 0), p);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(0, -len), p);
    // BR
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(-len, 0), p);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(0, -len), p);
  }

  void _drawMidHandles(Canvas canvas, Rect r) {
    const sz = 10.0;
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = const Color(0xFF6BCB77)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centers = [
      Offset(r.center.dx, r.top), // top
      Offset(r.center.dx, r.bottom), // bottom
      Offset(r.left, r.center.dy), // left
      Offset(r.right, r.center.dy), // right
    ];

    for (final c in centers) {
      final hRect = Rect.fromCenter(center: c, width: sz * 1.8, height: sz);
      final rrect = RRect.fromRectAndRadius(hRect, const Radius.circular(4));
      canvas.drawRRect(rrect, p);
      canvas.drawRRect(rrect, border);
    }
  }

  @override
  bool shouldRepaint(_CropMaskPainter old) => old.crop != crop;
}

// ════════════════════════════════════════════════════════════════════════════
//  DRAGGABLE CROP OVERLAY  — drag corners / edges / interior
// ════════════════════════════════════════════════════════════════════════════
class _DraggableCropOverlay extends StatefulWidget {
  final Size containerSize;
  final Rect crop;
  final double handleSize;
  final ValueChanged<Rect> onCropChanged;

  const _DraggableCropOverlay({
    required this.containerSize,
    required this.crop,
    required this.handleSize,
    required this.onCropChanged,
  });

  @override
  State<_DraggableCropOverlay> createState() => _DraggableCropOverlayState();
}

enum _DragHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
  interior,
  none,
}

class _DraggableCropOverlayState extends State<_DraggableCropOverlay> {
  _DragHandle _handle = _DragHandle.none;
  Offset _startLocal = Offset.zero;
  Rect _startCrop = Rect.zero;

  static const double _minSize = 0.08;

  Rect get _px => Rect.fromLTWH(
    widget.crop.left * widget.containerSize.width,
    widget.crop.top * widget.containerSize.height,
    widget.crop.width * widget.containerSize.width,
    widget.crop.height * widget.containerSize.height,
  );

  _DragHandle _hitTest(Offset local) {
    final r = _px;
    final h = widget.handleSize * 2.0;
    bool near(double a, double b) => (a - b).abs() < h;

    if (near(local.dx, r.left) && near(local.dy, r.top))
      return _DragHandle.topLeft;
    if (near(local.dx, r.right) && near(local.dy, r.top))
      return _DragHandle.topRight;
    if (near(local.dx, r.left) && near(local.dy, r.bottom))
      return _DragHandle.bottomLeft;
    if (near(local.dx, r.right) && near(local.dy, r.bottom))
      return _DragHandle.bottomRight;
    if (near(local.dy, r.top) && local.dx > r.left && local.dx < r.right)
      return _DragHandle.top;
    if (near(local.dy, r.bottom) && local.dx > r.left && local.dx < r.right)
      return _DragHandle.bottom;
    if (near(local.dx, r.left) && local.dy > r.top && local.dy < r.bottom)
      return _DragHandle.left;
    if (near(local.dx, r.right) && local.dy > r.top && local.dy < r.bottom)
      return _DragHandle.right;
    if (r.contains(local)) return _DragHandle.interior;
    return _DragHandle.none;
  }

  void _onPanStart(DragStartDetails d) {
    _handle = _hitTest(d.localPosition);
    _startLocal = d.localPosition;
    _startCrop = widget.crop;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_handle == _DragHandle.none) return;
    final W = widget.containerSize.width;
    final H = widget.containerSize.height;
    final dx = (d.localPosition.dx - _startLocal.dx) / W;
    final dy = (d.localPosition.dy - _startLocal.dy) / H;
    Rect c = _startCrop;

    double cl = c.left, ct = c.top, cr = c.right, cb = c.bottom;

    switch (_handle) {
      case _DragHandle.topLeft:
        cl = (cl + dx).clamp(0.0, cr - _minSize);
        ct = (ct + dy).clamp(0.0, cb - _minSize);
        break;
      case _DragHandle.topRight:
        cr = (cr + dx).clamp(cl + _minSize, 1.0);
        ct = (ct + dy).clamp(0.0, cb - _minSize);
        break;
      case _DragHandle.bottomLeft:
        cl = (cl + dx).clamp(0.0, cr - _minSize);
        cb = (cb + dy).clamp(ct + _minSize, 1.0);
        break;
      case _DragHandle.bottomRight:
        cr = (cr + dx).clamp(cl + _minSize, 1.0);
        cb = (cb + dy).clamp(ct + _minSize, 1.0);
        break;
      case _DragHandle.top:
        ct = (ct + dy).clamp(0.0, cb - _minSize);
        break;
      case _DragHandle.bottom:
        cb = (cb + dy).clamp(ct + _minSize, 1.0);
        break;
      case _DragHandle.left:
        cl = (cl + dx).clamp(0.0, cr - _minSize);
        break;
      case _DragHandle.right:
        cr = (cr + dx).clamp(cl + _minSize, 1.0);
        break;
      case _DragHandle.interior:
        final w = cr - cl, h = cb - ct;
        cl = (cl + dx).clamp(0.0, 1.0 - w);
        ct = (ct + dy).clamp(0.0, 1.0 - h);
        cr = cl + w;
        cb = ct + h;
        break;
      default:
        break;
    }

    widget.onCropChanged(Rect.fromLTRB(cl, ct, cr, cb));
  }

  void _onPanEnd(DragEndDetails _) => _handle = _DragHandle.none;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.translucent,
      child: const SizedBox.expand(),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  SCAN FRAME PAINTER (camera viewfinder corners)
// ════════════════════════════════════════════════════════════════════════════
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cl = 28.0;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(0, cl)
        ..lineTo(0, 0)
        ..lineTo(cl, 0),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - cl, 0)
        ..lineTo(w, 0)
        ..lineTo(w, cl),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h - cl)
        ..lineTo(0, h)
        ..lineTo(cl, h),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - cl, h)
        ..lineTo(w, h)
        ..lineTo(w, h - cl),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ════════════════════════════════════════════════════════════════════════════
//  REUSABLE BUTTONS
// ════════════════════════════════════════════════════════════════════════════
class _GalleryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.45),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: const Center(
        child: Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
      ),
    ),
  );
}

class _CaptureButton extends StatelessWidget {
  final Animation<double> pulseAnim;
  final VoidCallback onTap;
  const _CaptureButton({required this.pulseAnim, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFFD93D),
              Color(0xFF6BCB77),
              Color(0xFF4D96FF),
              Color(0xFFB983FF),
              Color(0xFFFF6B6B),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.25 * pulseAnim.value),
              blurRadius: 20 * pulseAnim.value,
              spreadRadius: 4 * pulseAnim.value,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 30,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _FlashButton extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onTap;
  const _FlashButton({required this.flashMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = flashMode == FlashMode.torch;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn
              ? Colors.amber.withOpacity(0.25)
              : Colors.black.withOpacity(0.45),
          border: Border.all(
            color: isOn ? Colors.amber : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            color: isOn ? Colors.amber : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  BOTTOM NAV BAR
// ════════════════════════════════════════════════════════════════════════════
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _NavItem(
          icon: Icons.home_outlined,
          label: 'Home',
          onTap: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        _NavItem(
          icon: Icons.school_outlined,
          label: 'AI Tutor',
          onTap: () => Navigator.pushReplacementNamed(context, '/ai-tutor'),
        ),
        const SizedBox(width: 64),
        _NavItem(
          icon: Icons.history_rounded,
          label: 'History',
          onTap: () => Navigator.pushReplacementNamed(context, '/history'),
        ),
        _NavItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
        ),
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white60, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
