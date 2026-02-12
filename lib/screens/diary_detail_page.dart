import 'package:flutter/material.dart';
import 'package:diary/theme/app_colors.dart';
import 'dart:io';

class DiaryDetailPage extends StatelessWidget {
  final Map<String, dynamic> diary;

  const DiaryDetailPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? AppColors.midnightMist : AppColors.lightBackground;
    final Color textColor = isDark ? AppColors.mistWhite : AppColors.deepCharcoal;
    final String photoPath = diary['photoPath'] ?? '';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.enchantedIndigo : AppColors.luminousLavender,
        foregroundColor: isDark ? AppColors.mistWhite : Colors.white,
        title: const Text('Diary Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoPath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(photoPath),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            _buildDetailItem("Date", diary['createdAt'], textColor),
            _buildDetailItem("Mood", diary['feeling'], textColor),
            _buildDetailItem("Thoughts", diary['thoughts'], textColor),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailItem(String title, dynamic value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: color),
          children: [
            TextSpan(
              text: "$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value?.toString() ?? "Not provided",
            ),
          ],
        ),
      ),
    );
  }
}