import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../sql_helper.dart';
import 'diary_entry_page.dart';
import 'package:diary/widgets/parallax_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<String> _diaryDates = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadDiaryDates();
  }

  Future<void> _loadDiaryDates() async {
    final data = await SQLHelper.getDiaries();
    setState(() {
      _diaryDates = data.map<String>((entry) => entry['createdAt'] as String).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold (
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ParallaxWidget(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                eventLoader: (day) {
                  final formatted = day.toIso8601String().split('T').first;
                  return _diaryDates.contains(formatted) ? [formatted] : [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 228, 204, 73),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = selectedDay;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiaryEntryPage(selectedDate: selectedDay),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _loadDiaryDates(); // Refresh calendar markers
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}