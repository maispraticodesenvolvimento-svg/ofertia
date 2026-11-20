import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;

import '../theme/app_theme.dart';

/// Crop dialog Flutter-nativo para banners web (10:3) e mobile (16:9).
/// Funciona em web, Android e iOS sem dependências JS.
class BannerCropDialog extends StatefulWidget {
  const BannerCropDialog({
    super.key,
    required this.sourceBytes,
    this.mobile = false,
  });

  final Uint8List sourceBytes;
  final bool mobile;

  /// Exibe o dialog e retorna os bytes recortados, ou null se cancelado.
  static Future<Uint8List?> show(
    BuildContext context,
    Uint8List bytes, {
    bool mobile = false,
  }) =>
      showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BannerCropDialog(sourceBytes: bytes, mobile: mobile),
      );

  @override
  State<BannerCropDialog> createState() => _BannerCropDialogState();
}

class _BannerCropDialogState extends State<BannerCropDialog> {
  // Web: 10:3 → 1800×540 px. Mobile: 16:9 → 1600×900 px.
  double get _ratio => widget.mobile ? 16.0 / 9.0 : 10.0 / 3.0;
  int get _outW => widget.mobile ? 1600 : 1800;
  int get _outH => widget.mobile ? 900 : 540;

  img.Image? _decoded;
  bool _loading = true;
  bool _cropping = false;

  // Pan (pixels no espaço da área de crop)
  Offset _pan = Offset.zero;
  Offset _dragStart = Offset.zero;
  Offset _panAtDragStart = Offset.zero;

  // Zoom: 1.0 = imagem preenche largura da área de crop
  double _zoom = 1.0;
  double _minZoom = 1.0;

  // Dimensões da área de crop, preenchidas pelo LayoutBuilder
  Size _cropBox = Size.zero;

  @override
  void initState() {
    super.initState();
    // Renderiza o dialog (spinner) antes de decodificar a imagem
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadImage());
  }

  Future<void> _loadImage() async {
    // Cede o frame para que o popup/spinner apareça antes da decodificação pesada
    await Future.delayed(const Duration(milliseconds: 50));
    final decoded = img.decodeImage(widget.sourceBytes);
    if (!mounted) return;
    setState(() {
      _decoded = decoded;
      _loading = false;
      if (decoded != null) {
        final imgAspect = decoded.width / decoded.height;
        // minZoom: imagem deve cobrir toda a área de crop
        // Largura: zoom=1 já cobre. Altura: depende do aspect
        _minZoom = math.max(1.0, imgAspect / _ratio);
        _zoom = _minZoom;
        _pan = Offset.zero;
      }
    });
  }

  /// Tamanho da imagem em pixels de display para o zoom atual
  Size _imgDisplaySize() {
    if (_decoded == null || _cropBox == Size.zero) return Size.zero;
    final w = _cropBox.width * _zoom;
    final h = w / (_decoded!.width / _decoded!.height);
    return Size(w, h);
  }

  /// Mantém o pan dentro dos limites (imagem sempre cobre a área de crop)
  void _clampPan() {
    final s = _imgDisplaySize();
    final maxDx = math.max(0.0, (s.width - _cropBox.width) / 2);
    final maxDy = math.max(0.0, (s.height - _cropBox.height) / 2);
    _pan = Offset(
      _pan.dx.clamp(-maxDx, maxDx),
      _pan.dy.clamp(-maxDy, maxDy),
    );
  }

  Future<void> _confirmCrop() async {
    final src = _decoded;
    if (src == null) return;

    setState(() => _cropping = true);

    // Cede um frame para o spinner aparecer antes do processamento bloqueante
    await Future.delayed(const Duration(milliseconds: 60));

    try {
      final imgSize = _imgDisplaySize();

      // Canto superior-esquerdo da imagem em coords da área de crop
      final imgLeft = (_cropBox.width - imgSize.width) / 2 + _pan.dx;
      final imgTop = (_cropBox.height - imgSize.height) / 2 + _pan.dy;

      // Área visível em pixels de imagem
      final scaleX = src.width / imgSize.width;
      final scaleY = src.height / imgSize.height;

      final x = (-imgLeft * scaleX).round().clamp(0, src.width - 1);
      final y = (-imgTop * scaleY).round().clamp(0, src.height - 1);
      final w = (_cropBox.width * scaleX).round().clamp(1, src.width - x);
      final h = (_cropBox.height * scaleY).round().clamp(1, src.height - y);

      // Recorte + redimensionamento para a resolução da variante selecionada.
      final cropped = img.copyCrop(src, x: x, y: y, width: w, height: h);
      final resized = img.copyResize(
        cropped,
        width: _outW,
        height: _outH,
        interpolation: img.Interpolation.cubic,
      );
      final bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 92));

      if (mounted) Navigator.of(context).pop(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar: $e'), backgroundColor: AppColors.error),
        );
        Navigator.of(context).pop(null);
      }
    } finally {
      if (mounted) setState(() => _cropping = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cabeçalho ─────────────────────────────────────────────
              Row(children: [
                const Icon(Icons.crop_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Recortar Banner',
                      style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                _Badge(widget.mobile ? '16:9 · 1600×900 px' : '10:3 · 1800×540 px'),
              ]),
              const SizedBox(height: 14),

              // ── Área de crop ──────────────────────────────────────────
              if (_loading)
                const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _buildCropBox(),

              const SizedBox(height: 6),

              // ── Zoom slider ───────────────────────────────────────────
              if (!_loading && _decoded != null)
                Row(children: [
                  const Icon(Icons.zoom_out_rounded, size: 20, color: AppColors.grey400),
                  Expanded(
                    child: Slider(
                      value: _zoom.clamp(_minZoom, _minZoom * 4),
                      min: _minZoom,
                      max: _minZoom * 4,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() {
                        _zoom = v;
                        _clampPan();
                      }),
                    ),
                  ),
                  const Icon(Icons.zoom_in_rounded, size: 20, color: AppColors.grey400),
                ]),

              const SizedBox(height: 10),

              // ── Botões ────────────────────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: _cropping ? null : () => Navigator.of(context).pop(null),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: (_cropping || _loading) ? null : _confirmCrop,
                  icon: _cropping
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_cropping ? 'Processando…' : 'Recortar e Enviar'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropBox() {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = w / _ratio;
      _cropBox = Size(w, h);

      final imgSize = _imgDisplaySize();

      return GestureDetector(
        onPanStart: (d) {
          _dragStart = d.globalPosition;
          _panAtDragStart = _pan;
        },
        onPanUpdate: (d) {
          setState(() {
            _pan = _panAtDragStart + (d.globalPosition - _dragStart);
            _clampPan();
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: w,
            height: h,
            color: Colors.black87,
            child: Stack(
              children: [
                // ── Imagem ─────────────────────────────────────────────
                Positioned(
                  left: (w - imgSize.width) / 2 + _pan.dx,
                  top: (h - imgSize.height) / 2 + _pan.dy,
                  child: Image.memory(
                    widget.sourceBytes,
                    width: imgSize.width,
                    height: imgSize.height,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                ),

                // ── Grid terços (sutil) ────────────────────────────────
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _GridPainter()),
                  ),
                ),

                // ── Alças dos cantos ──────────────────────────────────
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _CornerHandlesPainter()),
                  ),
                ),

                // ── Borda azul ────────────────────────────────────────
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary, width: 2.5),
                      ),
                    ),
                  ),
                ),

                // ── Dica de arrasto ──────────────────────────────────
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.open_with_rounded, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text('Arraste para reposicionar',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBorder),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
      );
}

// ── Painters ───────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;

    // 2 linhas verticais (terços)
    for (int i = 1; i <= 2; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    // 1 linha horizontal (meia altura)
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}

class _CornerHandlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 22.0;

    _corner(canvas, p, Offset.zero, 1, 1, len);
    _corner(canvas, p, Offset(size.width, 0), -1, 1, len);
    _corner(canvas, p, Offset(0, size.height), 1, -1, len);
    _corner(canvas, p, Offset(size.width, size.height), -1, -1, len);
  }

  void _corner(Canvas c, Paint p, Offset o, double dx, double dy, double l) {
    c.drawLine(o, o + Offset(dx * l, 0), p);
    c.drawLine(o, o + Offset(0, dy * l), p);
  }

  @override
  bool shouldRepaint(_CornerHandlesPainter _) => false;
}

