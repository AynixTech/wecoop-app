import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'sportello/sportello_screen.dart';
import 'progetti/progetti_screen.dart';
import 'profilo/profilo_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const SportelloScreen(),
    const ProgettiScreen(),
    const ProfiloScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/wecoop_logo.png', height: 36),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Sportello',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Progetti',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
        ],
      ),
    );
  }
}
