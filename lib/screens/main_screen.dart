import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'sportello/chatbot_assistenza_screen.dart';
import 'progetti/progetti_screen.dart';
import 'profilo/profilo_screen.dart';
import 'eventi/eventi_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventiScreen(),
    const CalendarScreen(),
    const ChatbotAssistenzaScreen(),
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
    final l10n = AppLocalizations.of(context)!;
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
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event),
            label: l10n.events,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: l10n.calendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.support_agent),
            label: l10n.sportello,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.volunteer_activism),
            label: l10n.projects,
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.profile),
        ],
      ),
    );
  }
}
