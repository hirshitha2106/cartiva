import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/product_model.dart';

class Interactive3DViewer extends StatefulWidget {
  final Product product;
  final double height;

  const Interactive3DViewer({
    super.key,
    required this.product,
    this.height = 360,
  });

  @override
  State<Interactive3DViewer> createState() => _Interactive3DViewerState();
}

class _Interactive3DViewerState extends State<Interactive3DViewer>
    with SingleTickerProviderStateMixin {
  double _yaw = 0.0; // horizontal rotation in radians
  double _pitch = 0.0; // vertical tilt in radians
  double _scale = 1.0;
  double _baseScale = 1.0;

  bool _isAutoSpinning = false;
  late AnimationController _spinController;

  // Selected hotspot index
  int? _activeHotspotIndex;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
        if (_isAutoSpinning) {
          setState(() {
            _yaw += 0.015;
            if (_yaw > math.pi * 2) {
              _yaw -= math.pi * 2;
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _toggleAutoSpin() {
    setState(() {
      _isAutoSpinning = !_isAutoSpinning;
      if (_isAutoSpinning) {
        _spinController.repeat();
      } else {
        _spinController.stop();
      }
    });
  }

  void _resetView() {
    setState(() {
      _yaw = 0.0;
      _pitch = 0.0;
      _scale = 1.0;
      _isAutoSpinning = false;
      _spinController.stop();
      _activeHotspotIndex = null;
    });
  }

  int _getCurrentImageIndex() {
    final images = widget.product.images;
    if (images.length <= 1) return 0;

    // Map normalized yaw to image angle
    double normalizedYaw = _yaw % (math.pi * 2);
    if (normalizedYaw < 0) normalizedYaw += math.pi * 2;

    final step = (math.pi * 2) / images.length;
    int index = (normalizedYaw / step).floor() % images.length;
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageIndex = _getCurrentImageIndex();
    final currentImage = widget.product.images[imageIndex];

    // Compute 3D perspective matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0018) // perspective depth
      ..rotateX(_pitch)
      ..rotateY(_yaw)
      ..scaleByDouble(_scale, _scale, _scale, 1.0);

    // Compute dynamic light reflection coordinates
    final lightX = 0.5 + (math.sin(_yaw) * 0.4);
    final lightY = 0.5 - (math.sin(_pitch) * 0.4);

    final degreeYaw = ((_yaw * 180 / math.pi) % 360).round();

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1523) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle concentric radar/grid rings
          CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _RadarBackgroundPainter(
              color: isDark
                  ? AppColors.primary.withAlpha(20)
                  : AppColors.primary.withAlpha(15),
            ),
          ),

          // Main 3D Gesture Target & Object
          GestureDetector(
            onScaleStart: (details) {
              _baseScale = _scale;
              if (_isAutoSpinning) {
                setState(() {
                  _isAutoSpinning = false;
                  _spinController.stop();
                });
              }
            },
            onScaleUpdate: (details) {
              setState(() {
                // Update 3D rotation from pan delta
                _yaw += details.focalPointDelta.dx * 0.012;
                _pitch -= details.focalPointDelta.dy * 0.012;
                // Clamp pitch so object doesn't flip completely upside down
                _pitch = _pitch.clamp(-math.pi / 4, math.pi / 4);

                // Update zoom
                if (details.scale != 1.0) {
                  _scale = (_baseScale * details.scale).clamp(0.8, 2.0);
                }
              });
            },
            onDoubleTap: _resetView,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: matrix,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Product High-Res Image with soft shadow
                      Container(
                        constraints: const BoxConstraints(maxHeight: 250, maxWidth: 280),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 120 : 50),
                              blurRadius: 36,
                              spreadRadius: 2,
                              offset: Offset(
                                math.sin(_yaw) * 16,
                                20 + math.sin(_pitch) * 10,
                              ),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            currentImage,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image, size: 48)),
                          ),
                        ),
                      ),

                      // Dynamic Shifting Light Glare
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: RadialGradient(
                                center: Alignment(
                                  (lightX - 0.5) * 2,
                                  (lightY - 0.5) * 2,
                                ),
                                radius: 0.8,
                                colors: [
                                  Colors.white.withAlpha(isDark ? 35 : 55),
                                  Colors.white.withAlpha(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Interactive Hotspots
                      ..._buildHotspots(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3D Angle & Status Badge (Top-Left)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withAlpha(160)
                    : Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAutoSpinning ? AppColors.accentEmerald : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '3D INTERACTIVE • $degreeYaw°',
                    style: AppTypography.badgeText.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drag / Hint Pill (Bottom-Center)
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withAlpha(140)
                    : Colors.white.withAlpha(210),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 14,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Drag to rotate 360° • Pinch to zoom',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating 3D Tools Toolbar (Top-Right)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildToolButton(
                  icon: _isAutoSpinning ? Icons.pause_rounded : Icons.sync_rounded,
                  tooltip: _isAutoSpinning ? 'Pause Orbit' : 'Auto 360° Orbit',
                  isActive: _isAutoSpinning,
                  isDark: isDark,
                  onTap: _toggleAutoSpin,
                ),
                const SizedBox(height: 8),
                _buildToolButton(
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Reset Camera',
                  isActive: false,
                  isDark: isDark,
                  onTap: _resetView,
                ),
                const SizedBox(height: 8),
                _buildToolButton(
                  icon: Icons.zoom_in_rounded,
                  tooltip: 'Zoom In',
                  isActive: false,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      _scale = (_scale + 0.2).clamp(0.8, 2.0);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHotspots() {
    final specs = widget.product.specifications.entries.take(2).toList();
    if (specs.isEmpty) return [];

    return [
      // Hotspot 1 (Top-Left of product)
      Positioned(
        top: 60,
        left: 40,
        child: _HotspotPin(
          title: specs[0].key,
          subtitle: specs[0].value,
          isOpen: _activeHotspotIndex == 0,
          onTap: () {
            setState(() {
              _activeHotspotIndex = _activeHotspotIndex == 0 ? null : 0;
            });
          },
        ),
      ),
      // Hotspot 2 (Bottom-Right of product)
      if (specs.length > 1)
        Positioned(
          bottom: 60,
          right: 40,
          child: _HotspotPin(
            title: specs[1].key,
            subtitle: specs[1].value,
            isOpen: _activeHotspotIndex == 1,
            onTap: () {
              setState(() {
                _activeHotspotIndex = _activeHotspotIndex == 1 ? null : 1;
              });
            },
          ),
        ),
    ];
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : (isDark ? Colors.black.withAlpha(160) : Colors.white.withAlpha(220)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? AppColors.primaryLight
                    : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive
                  ? Colors.white
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _HotspotPin extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isOpen;
  final VoidCallback onTap;

  const _HotspotPin({
    required this.title,
    required this.subtitle,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(120),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ),
        if (isOpen) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(220),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.badgeText.copyWith(color: AppColors.accentCyan),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RadarBackgroundPainter extends CustomPainter {
  final Color color;

  _RadarBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw concentric circles
    canvas.drawCircle(center, 60, paint);
    canvas.drawCircle(center, 120, paint);
    canvas.drawCircle(center, 180, paint);
  }

  @override
  bool shouldRepaint(covariant _RadarBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}
