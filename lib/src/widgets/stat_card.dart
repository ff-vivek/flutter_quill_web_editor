import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A card that displays a single statistic with a label.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  /// The label describing what the statistic represents.
  final String label;

  /// The value to display.
  final String value;

  /// Optional icon to display above the value.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of stat cards for displaying multiple statistics.
class StatCardRow extends StatelessWidget {
  const StatCardRow({
    super.key,
    required this.stats,
    this.spacing = 16.0,
  });

  /// List of statistics to display.
  final List<({String label, String value, IconData? icon})> stats;

  /// Spacing between cards.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: stats.indexOf(stat) < stats.length - 1 ? spacing : 0,
            ),
            child: StatCard(
              label: stat.label,
              value: stat.value,
              icon: stat.icon,
            ),
          ),
        );
      }).toList(),
    );
  }
}
