import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../sql_helper.dart';

class DiaryEntryPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryEntryPage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _thoughtsController = TextEditingController();

  String selectedFeeling = '';
  String selectedWith = '';
  String selectedActivity = '';
  String selectedPlace = '';
  String selectedWeather = '';
  File? _image;
  bool _isLoading = true;
  int? _existingEntryId;

  final ImagePicker _picker = ImagePicker();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _loadExistingEntry();
    _setupShakeDetector();
  }

  Future<void> _loadExistingEntry() async {
    final dateStr = widget.selectedDate.toIso8601String().split('T').first;

    try {
      final List<Map<String, dynamic>> allDiaries = await SQLHelper.getDiaries();

      // Find entry for specific date
      Map<String, dynamic>? existing;
      for (var entry in allDiaries) {
        if (entry['createdAt'] == dateStr) {
          existing = entry;
          break;
        }
      }

      if (existing != null && mounted) {
        setState(() {
          _existingEntryId = existing!['id'] as int;
          _titleController.text = existing['title'] ?? '';
          _thoughtsController.text = existing['thoughts'] ?? '';
          selectedFeeling = existing['feeling'] ?? '';
          selectedWith = existing['withWhom'] ?? '';
          selectedActivity = existing['activity'] ?? '';
          selectedPlace = existing['place'] ?? '';
          selectedWeather = existing['weather'] ?? '';
          if (existing['photoPath'] != null && existing['photoPath'].isNotEmpty) {
            _image = File(existing['photoPath']);
          }
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading entry: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setupShakeDetector() {
    _accelerometerSubscription = accelerometerEventStream().listen(
          (AccelerometerEvent event) {
        double acceleration = event.x.abs() + event.y.abs() + event.z.abs();
        if (acceleration > 35) {
          _showResetDialog();
        }
      },
    );
  }

  void _resetEntry() {
    setState(() {
      selectedFeeling = '';
      selectedWith = '';
      selectedActivity = '';
      selectedPlace = '';
      selectedWeather = '';
      _titleController.clear();
      _thoughtsController.clear();
      _image = null;
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Shake detected!"),
        content: const Text("Clear this entry and start over?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Keep Writing")),
          TextButton(
            onPressed: () {
              _resetEntry();
              Navigator.pop(context);
            },
            child: const Text("Clear All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _titleController.dispose();
    _thoughtsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _saveDiary() async {
    if (selectedFeeling.isEmpty && _thoughtsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add content")));
      return;
    }

    final dateStr = widget.selectedDate.toIso8601String().split('T').first;

    try {
      if (_existingEntryId != null) {
        await SQLHelper.updateDiary(
          id: _existingEntryId!,
          title: _titleController.text,
          feeling: selectedFeeling,
          thoughts: _thoughtsController.text,
          activity: selectedActivity,
          place: selectedPlace,
          weather: selectedWeather,
          withWhom: selectedWith,
          createdAt: dateStr,
          photoPath: _image?.path,
        );
      } else {
        await SQLHelper.createDiary(
          title: _titleController.text,
          feeling: selectedFeeling,
          thoughts: _thoughtsController.text,
          activity: selectedActivity,
          place: selectedPlace,
          weather: selectedWeather,
          withWhom: selectedWith,
          createdAt: dateStr,
          photoPath: _image?.path,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  Widget buildChips(String label, List<String> options, String selected, void Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final isSelected = selected == option;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(option, style: const TextStyle(fontSize: 20)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => onSelected(option)),
                  selectedColor: Colors.blue.shade400,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(_existingEntryId != null ? "Edit Entry" : "New Entry")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 20),
            buildChips("Mood", ["😄", "😊", "😐", "😟", "😭"], selectedFeeling, (v) => selectedFeeling = v),
            buildChips("With", ["🙋‍♀️", "👨‍👩‍👧", "👯", "🐕"], selectedWith, (v) => selectedWith = v),
            buildChips("Activity", ["📚", "🍽️", "🛍️", "✈️", "🚶"], selectedActivity, (v) => selectedActivity = v),
            buildChips("Place", ["🏠", "🏫", "🏢", "☕", "🍴"], selectedPlace, (v) => selectedPlace = v),
            buildChips("Weather", ["☀️", "🌧️", "💨", "☁️", "🔥"], selectedWeather, (v) => selectedWeather = v),
            TextField(controller: _thoughtsController, maxLines: 5, decoration: const InputDecoration(hintText: "Thoughts...")),
            const SizedBox(height: 20),
            if (_image != null) Image.file(_image!, height: 150),
            TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Add Photo")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveDiary, child: const Text("Save Diary")),
          ],
        ),
      ),
    );
  }
}