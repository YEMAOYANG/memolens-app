import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/services/ocr_service.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});
  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String _ocrPreview = '';
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
    _controller = controller;
    await controller.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  Future<void> _capture() async {
    if (_isCapturing || _controller == null) return;
    setState(() => _isCapturing = true);
    try {
      final file = await _controller!.takePicture();
      // 本地 OCR
      final ocrText = await OcrService.recognize(file.path);
      if (!mounted) return;
      context.go('/camera/result', extra: {'imagePath': file.path, 'ocrText': ocrText});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('拍照失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _toggleFlash() {
    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.auto : FlashMode.off;
    });
    _controller?.setFlashMode(_flashMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // 相机预览
        if (_isInitialized && _controller != null)
          Positioned.fill(child: CameraPreview(_controller!))
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        // 扫描框动效
        Positioned.fill(child: _ScanOverlay()),

        // 顶部工具栏
        SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            _CircleButton(icon: Icons.close_rounded, onTap: () => context.go('/home')),
            const Spacer(),
            _CircleButton(
              icon: _flashMode == FlashMode.off ? Icons.flash_off_rounded : Icons.flash_auto_rounded,
              onTap: _toggleFlash,
            ),
          ]),
        )),

        // OCR 预览
        if (_ocrPreview.isNotEmpty)
          Positioned(
            left: 20, right: 20, bottom: 160,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_ocrPreview, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ),

        // 底部控制
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 24),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.center, children: [
                // 图库
                _CircleButton(icon: Icons.photo_library_rounded, onTap: () {}),
                // 快门
                GestureDetector(
                  onTap: _capture,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _isCapturing ? 68 : 72,
                    height: _isCapturing ? 68 : 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primary,
                      boxShadow: const [BoxShadow(color: Color(0x605B5FEF), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: _isCapturing
                      ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
                  ),
                ),
                // 翻转
                _CircleButton(icon: Icons.flip_camera_ios_rounded, onTap: () {}),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.4)),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}

class _ScanOverlay extends StatefulWidget {
  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}
class _ScanOverlayState extends State<_ScanOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _anim = Tween(begin: 0.1, end: 0.9).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _anim, builder: (_, __) {
      return CustomPaint(painter: _ScanPainter(progress: _anim.value));
    });
  }
}

class _ScanPainter extends CustomPainter {
  final double progress;
  _ScanPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(40, size.height * 0.2, size.width - 80, size.height * 0.45);
    // 半透明遮罩
    final maskPaint = Paint()..color = Colors.black.withOpacity(0.4);
    canvas.drawRect(Rect.fromLTWH(0,0,size.width,rect.top), maskPaint);
    canvas.drawRect(Rect.fromLTWH(0,rect.bottom,size.width,size.height-rect.bottom), maskPaint);
    canvas.drawRect(Rect.fromLTWH(0,rect.top,rect.left,rect.height), maskPaint);
    canvas.drawRect(Rect.fromLTWH(rect.right,rect.top,size.width-rect.right,rect.height), maskPaint);
    // 扫描线
    final linePaint = Paint()
      ..shader = LinearGradient(colors: [Colors.transparent, const Color(0xFF5B5FEF), Colors.transparent]).createShader(rect)
      ..strokeWidth = 2;
    final lineY = rect.top + rect.height * progress;
    canvas.drawLine(Offset(rect.left, lineY), Offset(rect.right, lineY), linePaint);
    // 四角
    final cornerPaint = Paint()..color = const Color(0xFF5B5FEF)..strokeWidth = 3..style = PaintingStyle.stroke;
    const r = 20.0; const l = 24.0;
    for (final (x, y, dx, dy) in [(rect.left,rect.top,1.0,1.0),(rect.right,rect.top,-1.0,1.0),(rect.left,rect.bottom,1.0,-1.0),(rect.right,rect.bottom,-1.0,-1.0)]) {
      canvas.drawLine(Offset(x,y+dy*r), Offset(x,y+dy*(r-l)), cornerPaint);
      canvas.drawLine(Offset(x+dx*r,y), Offset(x+dx*(r-l),y), cornerPaint);
    }
  }
  @override bool shouldRepaint(_ScanPainter o) => o.progress != progress;
}
