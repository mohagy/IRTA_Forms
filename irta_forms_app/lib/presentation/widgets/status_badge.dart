import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = _getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  (Color, Color) _getStatusColors(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return (AppColors.statusCompletedBg, AppColors.statusCompletedText);
      case AppConstants.statusSubmitted:
        return (AppColors.statusSubmittedBg, AppColors.statusSubmittedText);
      case AppConstants.statusDraft:
        return (AppColors.statusDraftBg, AppColors.statusDraftText);
      case AppConstants.statusRejected:
        return (AppColors.statusRejectedBg, AppColors.statusRejectedText);
      case AppConstants.statusReceptionReview:
      case AppConstants.statusVerification:
      case AppConstants.statusIssuingDecision:
        return (AppColors.statusSubmittedBg, AppColors.statusSubmittedText);
      default:
        return (AppColors.statusDraftBg, AppColors.statusDraftText);
    }
  }
}

