import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/screens/home_screen.dart';
import 'package:diary/screens/diary_list_page.dart';
import 'package:diary/screens/profile_page.dart';
import 'package:diary/theme/app_colors.dart';
import 'package:diary/theme/theme_provider.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, this.selectedIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<String> _titles = [
    'My Calendar',     
    'My Diary Pages',  
    'My Profile',      
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  final List<Widget> _pages = const [
    HomeScreen(),       // 📅 Calendar
    DiaryListPage(),    // 📖 Diary list
    ProfilePage(),      // 👤 Profile
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newEntry');
        },
        backgroundColor: AppColors.cyberAqua,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: isDark ? AppColors.astralGray : AppColors.lightCard,
        selectedItemColor: AppColors.enchantedIndigo,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Pages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
