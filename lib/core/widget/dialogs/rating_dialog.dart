import 'package:flutter/material.dart';
import 'package:piggy_log/core/utils/app_review_helper.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showRatingDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  // Split the title by '?' to style "Knock knock...?" separately
  final titleParts = l10n.ratingTitle.split('?');
  final knockKnock = "${titleParts[0]}?";
  final restOfTitle = titleParts.length > 1 ? titleParts[1].trim() : "";

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/pig_worried.png', width: 120),
            const SizedBox(height: 20),
            Text(
              knockKnock,
              style: const TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: Colors.pinkAccent
              ),
            ),
            const SizedBox(height: 8),
            Text(
              restOfTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ratingSubTitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
      actions: [
        TextButton(
          onPressed: () async {
            // Save current date to trigger 7-day cooldown
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_cancel_date', DateTime.now().toIso8601String());
            
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.ratingCancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            AppReviewHelper.requestReview();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(l10n.ratingConfirm),
        ),
      ],
    ),
  );
}