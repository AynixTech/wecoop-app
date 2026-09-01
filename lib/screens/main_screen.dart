import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_avatar_store.dart';
import '../services/socio_service.dart';
import '../services/secure_storage_service.dart';
import '../services/app_localizations.dart';
import 'annunci/annunci_screen.dart';
import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'lavoro/offerte_lavoro_screen.dart';
import 'sportello/sportello_screen.dart';
import 'profilo/profilo_screen.dart';
import 'profilo/completa_profilo_screen.dart';
import 'eventi/eventi_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final String? initialRichiestaId;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.initialRichiestaId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late final List<Widget> _tabScreens;
  int _profileScreenVersion = 0;
  bool _profileCheckDone = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabScreens = [
      const HomeScreen(),
      const EventiScreen(),
      const AnnunciScreen(),
      CalendarScreen(initialRichiestaId: widget.initialRichiestaId),
      const OfferteLavoroScreen(),
      const SportelloScreen(),
      const SizedBox.shrink(),
    ];
    UserAvatarStore.hydrate();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkProfiloCompleto());
  }

  Future<void> _checkProfiloCompleto() async {
    if (_profileCheckDone) return;
    _profileCheckDone = true;

    final token = await SecureStorageService().read(key: 'jwt_token');
    if (token == null || token.isEmpty) return;

    try {
      final res = await SocioService.getProfiloCompleto();
      if (res['success'] != true) return;
      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final completo = data['profilo_completo'] == true;
      if (completo || !mounted) return;
      _showCompletaProfiloDialog();
    } catch (_) {
      // Silenzioso: non bloccare l'app se la verifica fallisce.
    }
  }

  void _showCompletaProfiloDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.translate('completeProfileDialogTitle'))),
          ],
        ),
        content: Text(
          l10n.translate('completeProfileDialogMessage'),
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.translate('completeProfileLater')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CompletaProfiloScreen()),
              );
            },
            child: Text(l10n.completeNow),
          ),
        ],
      ),
    );
  }

  List<Widget> get _resolvedScreens => [
    _tabScreens[0],
    _tabScreens[1],
    _tabScreens[2],
    _tabScreens[3],
    _tabScreens[4],
    _tabScreens[5],
    ProfiloScreen(key: ValueKey('profile-$_profileScreenVersion')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 6 && _selectedIndex != 6) {
        _profileScreenVersion++;
      }
      _selectedIndex = index;
    });
  }

  Widget _buildMenuIcon(
    String assetPath, {
    required bool selected,
    double size = 22,
  }) {
    const selectedColor = AppColors.primary;
    const unselectedColor = AppColors.iconInactive;

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
    const selectedColor = AppColors.primary;
    const unselectedColor = AppColors.iconInactive;
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
                      color: AppColors.bgSubtle,
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
                      ? AppColors.primary
                      : AppColors.textPrimary)
                  .withOpacity(0.14),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderInput,
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
                      color: AppColors.border,
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
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _resolvedScreens),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }
}

