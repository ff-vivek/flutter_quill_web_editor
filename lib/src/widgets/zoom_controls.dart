import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A widget that displays zoom controls with current zoom level.
///
/// Provides buttons to zoom in, zoom out, and reset to default zoom.
class ZoomControls extends StatelessWidget {
  const ZoomControls({
    super.key,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    this.minZoom = 0.5,
    this.maxZoom = 3.0,
  });

  /// Current zoom level (1.0 = 100%).
  final double zoomLevel;

  /// Callback when zoom in is pressed.
  final VoidCallback onZoomIn;

  /// Callback when zoom out is pressed.
  final VoidCallback onZoomOut;

  /// Callback when zoom level is tapped (resets to default).
  final VoidCallback onReset;

  /// Minimum allowed zoom level.
  final double minZoom;

  /// Maximum allowed zoom level.
  final double maxZoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onPressed: zoomLevel > minZoom ? onZoomOut : null,
            tooltip: 'Zoom Out',
          ),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${(zoomLevel * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onPressed: zoomLevel < maxZoom ? onZoomIn : null,
            tooltip: 'Zoom In',
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      color: onPressed != null ? AppColors.textSecondary : AppColors.textMuted,
    );
  }
}
