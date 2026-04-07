import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../models/post_model.dart';
import '../../models/evento_model.dart';
import '../../models/documento.dart';
import '../../services/wordpress_service.dart';
import '../../services/eventi_service.dart';
import '../../services/documento_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../servizi/accoglienza_screen.dart';
import '../servizi/mediazione_fiscale_screen.dart';
import '../servizi/supporto_contabile_screen.dart';
import '../servizi/orientamento_fiscale_screen.dart';
import '../servizi/cv_ai_screen.dart';
import '../onboarding/first_access_screen.dart';
import '../progetti/project_category_detail_screen.dart';
import '../eventi/evento_detail_screen.dart';
import '../profilo/documenti_screen.dart';
import '../../widgets/language_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = SecureStorageService();
  String userName = '...'; // valore iniziale
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final token = await storage.read(key: 'jwt_token');
    final fullName = await storage.read(key: 'full_name');
    final displayName = await storage.read(key: 'user_display_name');
    final nicename = await storage.read(key: 'user_nicename');
    final email = await storage.read(key: 'user_email');

    // Priorità: full_name (nome + cognome) > display_name > nicename > email
    String finalName = 'Utente';
    bool logged = token != null && token.isNotEmpty;

    if (fullName != null && fullName.isNotEmpty) {
      finalName = fullName;
    } else if (displayName != null && displayName.isNotEmpty) {
      finalName = displayName;
    } else if (nicename != null && nicename.isNotEmpty) {
      finalName = nicename;
    } else if (email != null && email.isNotEmpty) {
      // Estrai il nome dalla parte prima della @
      finalName = email.split('@').first;
    }

    if (mounted) {
      setState(() {
        userName = finalName;
        isLoggedIn = logged;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const LanguageSelector(),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [scheme.surfaceContainerLowest, scheme.surface],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingSection(userName: userName, isLoggedIn: isLoggedIn),
                const SizedBox(height: 24),

                // Avviso documenti in scadenza
                if (isLoggedIn) const _DocumentiScadenzaSection(),
                if (isLoggedIn) const SizedBox(height: 24),

                if (!isLoggedIn)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary,
                              Color.alphaBlend(
                                scheme.secondary.withOpacity(0.28),
                                scheme.primary,
                              ),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withOpacity(0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: scheme.onPrimary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: scheme.onPrimary.withOpacity(0.35),
                                  ),
                                ),
                                child: Icon(
                                  Icons.login,
                                  color: scheme.onPrimary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.alreadyRegistered,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.loginToAccess,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: scheme.onPrimary.withOpacity(
                                          0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: scheme.onPrimary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isLoggedIn) const SizedBox(height: 24),

                const _ServicesSection(),
                const SizedBox(height: 24),

                const _UpcomingEventsSection(),

                const SizedBox(height: 24),

                _ActiveProjectsSection(),

                const SizedBox(height: 24),

                const _LatestPostsSection(),

                const SizedBox(height: 24),

                const _QuickAccessSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveProjectsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final categories = [
      {
        'key': 'giovani',
        'name': l10n.youthCategory,
        'icon': Icons.school,
        'color': scheme.primary,
        'projects': [
          {
            'name': 'MAFALDA',
            'description': l10n.mafaldaDescription,
            'services': [
              l10n.mafaldaService1,
              l10n.mafaldaService2,
              l10n.mafaldaService3,
              l10n.mafaldaService4,
            ],
          },
        ],
      },
      {
        'key': 'donne',
        'name': l10n.womenCategory,
        'icon': Icons.people,
        'color': scheme.secondary,
        'projects': [
          {
            'name': 'WOMENTOR',
            'description': l10n.womentorDescription,
            'services': [
              l10n.womentorService1,
              l10n.womentorService2,
              l10n.womentorService3,
              l10n.womentorService4,
            ],
          },
        ],
      },
      {
        'key': 'sport',
        'name': l10n.sportsCategory,
        'icon': Icons.sports_soccer,
        'color': Color.alphaBlend(
          scheme.secondary.withOpacity(0.6),
          scheme.primary,
        ),
        'projects': [
          {
            'name': 'SPORTUNITY',
            'description': l10n.sportunityDescription,
            'services': [
              l10n.sportunityService1,
              l10n.sportunityService2,
              l10n.sportunityService3,
              l10n.sportunityService4,
            ],
          },
        ],
      },
      {
        'key': 'migranti',
        'name': l10n.migrantsCategory,
        'icon': Icons.support_agent,
        'color': Color.alphaBlend(
          scheme.error.withOpacity(0.35),
          scheme.primary,
        ),
        'projects': [
          {
            'name': 'PASSAPAROLA',
            'description': l10n.passaparolaDescription,
            'services': [
              l10n.passaparolaService1,
              l10n.passaparolaService2,
              l10n.passaparolaService3,
              l10n.passaparolaService4,
            ],
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.activeProjects),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProjectCategoryDetailScreen(
                            categoryKey: category['key'] as String,
                            categoryName: category['name'] as String,
                            categoryIcon: category['icon'] as IconData,
                            categoryColor: category['color'] as Color,
                            projects:
                                category['projects']
                                    as List<Map<String, dynamic>>,
                          ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 148,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (category['color'] as Color).withOpacity(0.7),
                        category['color'] as Color,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.onPrimary.withOpacity(0.14),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (category['color'] as Color).withOpacity(0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          size: 24,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final String userName;
  final bool isLoggedIn;

  const _GreetingSection({required this.userName, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              scheme.secondary.withOpacity(0.24),
              scheme.primary,
            ),
            scheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.hello}, $userName',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.welcome,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.onPrimary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLoggedIn ? Icons.verified_user : Icons.person_outline,
                  color: scheme.onPrimary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isLoggedIn ? 'Area soci' : 'Guest',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? link;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.link,
    this.onTap,
  });

  void _openLink() async {
    if (link == null || link!.isEmpty) return;

    final uri = Uri.parse(link!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap ?? (link != null ? _openLink : null),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 208,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            scheme.onSurface.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: scheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.7),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.quickAccess),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _QuickAccessButton(
              icon: Icons.map,
              label: l10n.communityMap,
              onTap: () {},
            ),
            _QuickAccessButton(
              icon: Icons.book,
              label: l10n.resourcesGuides,
              onTap: () {},
            ),
            _QuickAccessButton(
              icon: Icons.group,
              label: l10n.localGroups,
              onTap: () {},
            ),
            _QuickAccessButton(
              icon: Icons.message,
              label: l10n.forumDiscussions,
              onTap: () {},
            ),
            _QuickAccessButton(
              icon: Icons.help_center,
              label: l10n.support,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.ourServices),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.welcomeOrientation,
          imagePath: 'assets/images/home/accoglienza.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const AccoglienzaScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.taxMediation,
          imagePath: 'assets/images/home/mediazione.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const MediazioneFiscaleScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.accountingSupport,
          imagePath: 'assets/images/home/contabile.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const SupportoContabileScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.translate('taxGuidanceAndClarifications'),
          imagePath: 'assets/images/home/orientamento.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const OrientamentoFiscaleScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.translate('cvAiServiceName'),
          imagePath: 'assets/images/home/cv_ai.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const CvAiScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _ServiceButton({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.14),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Immagine di sfondo
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback con colore gradiente se l'immagine non esiste
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Color.alphaBlend(
                            scheme.secondary.withOpacity(0.28),
                            scheme.primary,
                          ),
                          scheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Overlay scuro per migliorare la leggibilità del testo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    scheme.onSurface.withOpacity(0.62),
                    scheme.primary.withOpacity(0.35),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Testo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: scheme.shadow.withOpacity(0.45),
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Icona freccia a destra
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.onPrimary.withOpacity(0.18),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: scheme.onPrimary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 94,
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary,
                    Color.alphaBlend(
                      scheme.secondary.withOpacity(0.22),
                      scheme.primary,
                    ),
                  ],
                ),
              ),
              child: Icon(icon, color: scheme.onPrimary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _LatestPostsSection extends StatefulWidget {
  const _LatestPostsSection();

  @override
  State<_LatestPostsSection> createState() => _LatestPostsSectionState();
}

class _LatestPostsSectionState extends State<_LatestPostsSection> {
  final WordpressService wpService = WordpressService();
  late Future<List<Post>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = wpService.getPosts(perPage: 5);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.latestArticles),
        const SizedBox(height: 12),
        FutureBuilder<List<Post>>(
          future: postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('${l10n.errorLoading}: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(l10n.noArticlesAvailable);
            }

            final posts = snapshot.data!;
            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _InfoCard(
                    title: post.title,
                    subtitle: post.excerpt,
                    imageUrl: post.imageUrl,
                    link: post.link,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UpcomingEventsSection extends StatefulWidget {
  const _UpcomingEventsSection();

  @override
  State<_UpcomingEventsSection> createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<_UpcomingEventsSection> {
  late Future<List<Evento>> eventiFuture;

  @override
  void initState() {
    super.initState();
    eventiFuture = _loadEventi();
  }

  Future<List<Evento>> _loadEventi() async {
    try {
      final result = await EventiService.getEventi(stato: 'futuro', perPage: 5);
      if (result['success'] == true && result['eventi'] != null) {
        return result['eventi'] as List<Evento>;
      }
      return [];
    } catch (e) {
      print('Errore caricamento eventi: $e');
      return [];
    }
  }

  String _formatData(String dataStr) {
    try {
      final data = DateTime.parse(dataStr);
      final mesi = [
        'Gen',
        'Feb',
        'Mar',
        'Apr',
        'Mag',
        'Giu',
        'Lug',
        'Ago',
        'Set',
        'Ott',
        'Nov',
        'Dic',
      ];
      return '${data.day} ${mesi[data.month - 1]}';
    } catch (e) {
      return dataStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<Evento>>(
      future: eventiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final eventi = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: l10n.upcomingEvents),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: eventi.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final evento = eventi[index];
                  return _InfoCard(
                    title: evento.titolo,
                    subtitle: _formatData(evento.dataInizio),
                    imageUrl: evento.immagineCopertina,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EventoDetailScreen(
                                eventoId: evento.id,
                                evento: evento,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Sezione avviso documenti in scadenza
class _DocumentiScadenzaSection extends StatefulWidget {
  const _DocumentiScadenzaSection();

  @override
  State<_DocumentiScadenzaSection> createState() =>
      _DocumentiScadenzaSectionState();
}

class _DocumentiScadenzaSectionState extends State<_DocumentiScadenzaSection> {
  final DocumentoService _documentoService = DocumentoService();
  List<Documento> _documentiInScadenza = [];
  List<Documento> _documentiScaduti = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDocumenti();
  }

  Future<void> _checkDocumenti() async {
    final inScadenza = await _documentoService.getDocumentiInScadenza();
    final scaduti = await _documentoService.getDocumentiScaduti();

    if (mounted) {
      setState(() {
        _documentiInScadenza = inScadenza;
        _documentiScaduti = scaduti;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_documentiScaduti.isEmpty && _documentiInScadenza.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Documenti scaduti (priorità alta)
        if (_documentiScaduti.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.error, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error, color: scheme.error),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '⚠️ DOCUMENTI SCADUTI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hai ${_documentiScaduti.length} documento/i scaduto/i. Aggiornali subito!',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                ..._documentiScaduti.map(
                  (doc) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• ${TipoDocumento.getDisplayName(doc.tipo)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DocumentiScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Aggiorna documenti'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Documenti in scadenza
        if (_documentiInScadenza.isNotEmpty) ...[
          if (_documentiScaduti.isNotEmpty) const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.secondary, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: scheme.secondary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '📅 Documenti in scadenza',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hai ${_documentiInScadenza.length} documento/i che scadono a breve:',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                ..._documentiInScadenza.map((doc) {
                  final giorniRimanenti =
                      doc.dataScadenza!.difference(DateTime.now()).inDays;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• ${TipoDocumento.getDisplayName(doc.tipo)} (tra $giorniRimanenti giorni)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DocumentiScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Gestisci documenti'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.secondary,
                      side: BorderSide(color: scheme.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
