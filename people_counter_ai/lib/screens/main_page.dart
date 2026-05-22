import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'live_people_screen.dart';
import 'setting_screen.dart';
import 'video_detection_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final pages = const [
    LivePeopleScreen(),
    DashboardScreen(),
    HistoryScreen(),
    SettingScreen(),
    VideoDetectionScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff15111f),
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.white54,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Live'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_display),
            label: 'Video',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}
