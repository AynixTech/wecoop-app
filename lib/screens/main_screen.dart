import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'annunci/annunci_screen.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'lavoro/offerte_lavoro_screen.dart';
import 'sportello/sportello_screen.dart';
import 'profilo/profilo_screen.dart';
import 'eventi/eventi_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => const [
    HomeScreen(),
    EventiScreen(),
    AnnunciScreen(),
    CalendarScreen(),
    OfferteLavoroScreen(),
    SportelloScreen(),
    ProfiloScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMenuIcon(
    String assetPath, {
    required bool selected,
    double size = 22,
  }) {
    const selectedColor = Color(0xFF1282A8);
    const unselectedColor = Color(0xFF9CA3AF);

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        selected ? selectedColor : unselectedColor,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String assetPath,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        child: Center(
          child: _buildMenuIcon(
            assetPath,
            selected: isSelected,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterHomeButton() {
    final isSelected = _selectedIndex == 0;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => _onItemTapped(0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: (isSelected
                      ? const Color(0xFF1282A8)
                      : const Color(0xFF1F2933))
                  .withOpacity(0.14),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFF1282A8) : Colors.white,
            width: 3,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/icons/app_icon.png',
            width: 34,
            height: 34,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 22,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        index: 1,
                        assetPath: 'assets/icons/menu/eventi.svg',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 2,
                        assetPath: 'assets/icons/menu/annunci.svg',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 3,
                        assetPath: 'assets/icons/menu/richiesta_servizi.svg',
                      ),
                    ),
                    const SizedBox(width: 86),
                    Expanded(
                      child: _buildNavItem(
                        index: 4,
                        assetPath: 'assets/icons/menu/lavoro.svg',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 5,
                        assetPath: 'assets/icons/menu/sportello.svg',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 6,
                        assetPath: 'assets/icons/menu/profilo.svg',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -2,
              child: _buildCenterHomeButton(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}
