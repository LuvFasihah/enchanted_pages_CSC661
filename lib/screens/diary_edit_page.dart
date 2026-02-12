import 'package:flutter/material.dart';
import '../sql_helper.dart';
import '../theme/app_colors.dart';

class DiaryEditPage extends StatefulWidget {
  final Map<String, dynamic> diary;
  final VoidCallback onUpdated;

  const DiaryEditPage({
    super.key,
    required this.diary,
    required this.onUpdated,
  });

  @override
  State<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {
  late TextEditingController _thoughtsController;
  String selectedFeeling = '';
  String selectedActivity = '';
  String selectedPlace = '';
  String selectedWeather = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedFeeling = widget.diary['feeling'] ?? '';
    selectedActivity = widget.diary['activity'] ?? '';
    selectedPlace = widget.diary['place'] ?? '';
    selectedWeather = widget.diary['weather'] ?? '';
    _thoughtsController = TextEditingController(text: widget.diary['thoughts'] ?? '');
  }

  Widget buildChips(String label, List<String> options, String selected, void Function(String) onSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? AppColors.mistWhite : AppColors.deepCharcoal)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => setState(() => onSelected(option)),
              backgroundColor: isDarkMode ? AppColors.astralGray : AppColors.lightCard,
              selectedColor: AppColors.enchantedIndigo,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDarkMode ? AppColors.mistWhite : AppColors.deepCharcoal),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _updateDiary() async {
    final thoughts = _thoughtsController.text.trim();

    if (selectedFeeling.isEmpty || thoughts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await SQLHelper.updateDiary(
      id: widget.diary['id'],            // Must have 'id:'
      title: widget.diary['title'] ?? '', // Added title
      feeling: selectedFeeling,
      thoughts: thoughts,
      activity: selectedActivity,
      place: selectedPlace,
      weather: selectedWeather,
      withWhom: widget.diary['withWhom'] ?? '', // Added withWhom
      createdAt: widget.diary['createdAt'],
    );

    widget.onUpdated();
    if (context.mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _thoughtsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pages'),
        backgroundColor: isDark ? AppColors.enchantedIndigo : AppColors.luminousLavender,
        foregroundColor: isDark ? AppColors.mistWhite : AppColors.deepCharcoal,
      ),
      backgroundColor: isDark ? AppColors.midnightMist : AppColors.lightBackground,
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildChips("Mood 😄", ["😀 Awesome", "😊 Good", "😐 Normal", "😔 Gloomy", "😢 Grieved"], selectedFeeling, (val) => selectedFeeling = val),
                  buildChips("Activity 🧠", ["📚 Study", "🍽️ Eating", "🛍️ Shopping", "✈️ Travel", "🚶 Walk", "🏋️ Exercise", "💼 Work", "👩‍🍳 Cook", "🎵 Music"], selectedActivity, (val) => selectedActivity = val),
                  buildChips("Place 📍", ["🏠 Home", "🏫 School", "🏢 Office", "☕ Cafe", "🍴 Restaurant", "🏬 Mall", "🎬 Movie", "📖 Library", "🏋️‍♀️ Gym"], selectedPlace, (val) => selectedPlace = val),
                  buildChips("Weather ⛅", ["☀️ Sunny", "🌧️ Rainy", "🌬️ Windy", "☁️ Cloudy", "🔥 Warm"], selectedWeather, (val) => selectedWeather = val),

                  Text("Thoughts 📝", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.mistWhite : AppColors.deepCharcoal)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _thoughtsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write your updated diary thoughts...",
                      border: const OutlineInputBorder(),
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateDiary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.enchantedIndigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
