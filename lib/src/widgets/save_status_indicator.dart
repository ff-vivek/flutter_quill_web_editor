import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Status of the document save state.
enum SaveStatus {
  /// Document has been modified but not saved.
  unsaved,

  /// Document is currently being saved.
  saving,

  /// Document has been saved successfully.
  saved,
}

/// A widget that displays the current save status of a document.
///
/// Shows different icons and colors based on the [status]:
/// - Unsaved: Orange edit icon
/// - Saving: Gray spinner
/// - Saved: Green checkmark
class SaveStatusIndicator extends StatelessWidget {
  const SaveStatusIndicator({
    super.key,
    required this.status,
    this.unsavedLabel = 'Unsaved',
    this.savingLabel = 'Saving...',
    this.savedLabel = 'Saved',
  });

  /// Current save status.
  final SaveStatus status;

  /// Label for unsaved state.
  final String unsavedLabel;

  /// Label for saving state.
  final String savingLabel;

  /// Label for saved state.
  final String savedLabel;

  @override
  Widget build(BuildContext context) {
    final (icon, color, text) = switch (status) {
      SaveStatus.unsaved => (
          Icons.edit_outlined,
          AppColors.warning,
          unsavedLabel,
        ),
      SaveStatus.saving => (
          Icons.sync,
          AppColors.textSecondary,
          savingLabel,
        ),
      SaveStatus.saved => (
          Icons.check_circle_outline,
          AppColors.success,
          savedLabel,
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == SaveStatus.saving)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

