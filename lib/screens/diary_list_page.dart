import 'package:flutter/material.dart';
import 'dart:io';
import '../sql_helper.dart';
import 'diary_detail_page.dart';
import 'diary_edit_page.dart';

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Map<String, dynamic>> _diaries = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshDiaries();
  }

  Future<void> _refreshDiaries() async {
    final data = await SQLHelper.getDiaries();
    setState(() {
      _diaries = data;
      _isLoading = false;
    });
  }

  void _deleteDiary(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this diary entry?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SQLHelper.deleteDiary(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diary deleted')),
        );
        _refreshDiaries();
      }
    }
  }

  void _editDiary(Map<String, dynamic> diary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryEditPage(
          diary: diary,
          onUpdated: _refreshDiaries,
        ),
      ),
    );
  }

  String _getFeelingEmoji(String feeling) {
  switch (feeling.toLowerCase()) {
    case 'awesome':
      return '😄';
    case 'good':
      return '😊';
    case 'normal':
      return '😐';
    case 'gloomy':
      return '😔';
    case 'grieved':
      return '😢';
    default:
      return '✨';
  }
}

String _getWeatherEmoji(String weather) {
  switch (weather.toLowerCase()) {
    case 'sunny':
      return '☀️';
    case 'rainy':
      return '🌧️';
    case 'cloudy':
      return '☁️';
    case 'windy':
      return '🌬️';
    case 'warm':
      return '🔥';
    default:
      return '🌈';
  }
}

String _getActivityEmoji(String activity) {
  switch (activity.toLowerCase()) {
    case 'study':
      return '📚';
    case 'eating':
      return '🍽️';
    case 'shopping':
      return '🛍️';
    case 'travel':
      return '✈️';
    case 'walk':
      return '🚶';
    case 'exercise':
      return '💪';
    case 'work':
      return '💼';
    case 'cook':
      return '🍳';
    case 'music':
      return '🎵';
    default:
      return '🎉';
  }
}

String _getPlaceEmoji(String place) {
  switch (place.toLowerCase()) {
    case 'home':
      return '🏠';
    case 'school':
      return '🏫';
    case 'office':
      return '🏢';
    case 'cafe':
      return '☕';
    case 'restaurant':
      return '🍴';
    case 'mall':
      return '🏬';
    case 'movie':
      return '🎬';
    case 'library':
      return '📖';
    case 'gym':
      return '🏋️';
    default:
      return '📍';
  }
}

String _getWithEmoji(String withWho) {
  switch (withWho.toLowerCase()) {
    case 'alone':
      return '🙍‍♀️';
    case 'family':
      return '👨‍👩‍👧‍👦';
    case 'friends':
      return '👯';
    default:
      return '❤️';
  }
}

String _getDayOfWeek(String date) {
  try {
    final parsedDate = DateTime.parse(date);
    final weekday = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekday[parsedDate.weekday - 1];
  } catch (_) {
    return '';
  }
}


  @override
  Widget build(BuildContext context) {
    return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _diaries.isEmpty
              ? const Center(child: Text('No entries yet.'))
              : RefreshIndicator(
                  onRefresh: () async => _refreshDiaries(),
                  
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _diaries.length,
                    itemBuilder: (context, index) {
                      final diary = _diaries[index];

                      final feeling = diary['feeling'] ?? '';
                      final thoughts = diary['thoughts'] ?? 'No thoughts';
                      final weather = diary['weather'] ?? '';
                      final place = diary['place'] ?? '';
                      final activity = diary['activity'] ?? '';
                      final withWho = diary['withWho'] ?? '';
                      final createdAt = diary['createdAt'] != null
                          ? diary['createdAt'].toString().split(' ').first
                          : 'No date';
                      final photoPath = diary['photoPath'] ?? '';

                      return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DiaryDetailPage(diary: diary),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 📸 Photo thumbnail if available
                                  if (photoPath.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(photoPath),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (photoPath.isNotEmpty) const SizedBox(width: 12),
                                  // 📝 Left side: text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${_getFeelingEmoji(feeling)} ${feeling.isNotEmpty ? feeling : 'No feeling'}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          thoughts,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${_getWeatherEmoji(weather)}  "
                                          "${_getPlaceEmoji(place)}  "
                                          "${_getActivityEmoji(activity)}  "
                                          "${_getWithEmoji(withWho)}",
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // 🎯 Right side: date + buttons
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${_getDayOfWeek(createdAt)}, $createdAt",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _editDiary(diary),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteDiary(diary['id']),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              );
  }
}