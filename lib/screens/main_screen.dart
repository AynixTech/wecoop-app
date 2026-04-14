import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_avatar_store.dart';
import 'annunci/annunci_screen.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'lavoro/offerte_lavoro_screen.dart';
import 'sportello/sportello_screen.dart';
import 'profilo/profilo_screen.dart';
import 'eventi/eventi_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  int _profileScreenVersion = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    UserAvatarStore.hydrate();
  }

  List<Widget> get _screens => const [
    HomeScreen(),
    EventiScreen(),
    AnnunciScreen(),
    CalendarScreen(),
    OfferteLavoroScreen(),
    SportelloScreen(),
    // Placeholder, replaced below to keep the profile tab refreshable.
    SizedBox.shrink(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 6 && _selectedIndex != 6) {
        _profileScreenVersion++;
      }
      _selectedIndex = index;
    });
  }

  List<Widget> get _resolvedScreens => [
    _screens[0],
    _screens[1],
    _screens[2],
    _screens[3],
    _screens[4],
    _screens[5],
    ProfiloScreen(key: ValueKey('profile-$_profileScreenVersion')),
  ];

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

  Widget _buildProfileNavItem() {
    const selectedColor = Color(0xFF1282A8);
    const unselectedColor = Color(0xFF9CA3AF);
    final isSelected = _selectedIndex == 6;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _onItemTapped(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        child: Center(
          child: ValueListenableBuilder<String?>(
            valueListenable: UserAvatarStore.avatarUrl,
            builder: (context, avatarUrl, _) {
              if (avatarUrl == null) {
                return _buildMenuIcon(
                  'assets/icons/menu/profilo.svg',
                  selected: isSelected,
                  size: 24,
                );
              }

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? selectedColor : unselectedColor,
                    width: isSelected ? 2.4 : 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelected ? 0.12 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person,
                        color: isSelected ? selectedColor : unselectedColor,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
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
                      child: _buildProfileNavItem(),
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
      body: IndexedStack(index: _selectedIndex, children: _resolvedScreens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

