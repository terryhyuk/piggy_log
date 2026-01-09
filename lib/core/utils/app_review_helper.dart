import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:piggy_log/core/widget/dialogs/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppReviewHelper {
  static final InAppReview _inAppReview = InAppReview.instance;
  static const String _alreadyRatedKey = 'already_rated';
  static const String _lastCancelKey = 'last_cancel_date';

  static Future<void> checkAndShowRating(BuildContext context, int totalCount) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if already rated
    if (prefs.getBool(_alreadyRatedKey) ?? false) return;

    // Check 7-day cooldown after cancel
    final lastCancelStr = prefs.getString(_lastCancelKey);
    if (lastCancelStr != null) {
      final lastCancelDate = DateTime.parse(lastCancelStr);
      final diff = DateTime.now().difference(lastCancelDate).inDays;
      if (diff < 7) return; 
    }

    // Show dialog if record count is 5 or more
    if (totalCount >= 5) {
      showRatingDialog(context);
    }
  }

  static Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_alreadyRatedKey, true);
    }
  }
}