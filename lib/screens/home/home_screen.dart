import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../models/post_model.dart';
import '../../services/wordpress_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../servizi/accoglienza_screen.dart';
import '../servizi/mediazione_fiscale_screen.dart';
import '../servizi/supporto_contabile_screen.dart';
import '../servizi/servizi_gate_screen.dart';
import '../progetti/project_category_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = FlutterSecureStorage();
  String userName = '...'; // valore iniziale

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final displayName = await storage.read(key: 'user_display_name');
    final nicename = await storage.read(key: 'user_nicename');
    final email = await storage.read(key: 'user_email');

    // Usa il display name se disponibile, altrimenti nicename, altrimenti nome dall'email
    String finalName = 'Utente';

    if (displayName != null && displayName.isNotEmpty) {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingSection(userName: userName),
              const SizedBox(height: 24),

              const _ServicesSection(),
              const SizedBox(height: 24),

              _SectionWithHorizontalCards(
                title: '📅 ${l10n.upcomingEvents}',
                items: const [
                  {'title': 'Cena Interculturale', 'subtitle': '3 Ago'},
                  {'title': 'Laboratorio di cucito', 'subtitle': '5 Ago'},
                  {'title': 'Corso di italiano', 'subtitle': '7 Ago'},
                ],
              ),

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
    );
  }
}

class _ActiveProjectsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final categories = [
      {
        'key': 'giovani',
        'name': l10n.youthCategory,
        'icon': Icons.school,
        'color': Colors.blue,
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
        'color': Colors.purple,
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
        'color': Colors.green,
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
        'color': Colors.orange,
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
        _SectionTitle(title: '🤝 ${l10n.activeProjects}'),
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
                      builder: (context) => ProjectCategoryDetailScreen(
                        categoryKey: category['key'] as String,
                        categoryName: category['name'] as String,
                        categoryIcon: category['icon'] as IconData,
                        categoryColor: category['color'] as Color,
                        projects: category['projects'] as List<Map<String, dynamic>>,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 140,
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
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  const _GreetingSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.hello}, $userName 👋',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.welcome,
        ),
      ],
    );
  }
}

class _SectionWithHorizontalCards extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  const _SectionWithHorizontalCards({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _InfoCard(
                title: item['title'] ?? '',
                subtitle: item['subtitle'] ?? '',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? link;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.link,
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
    return InkWell(
      onTap: _openLink,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2196F3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl!,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
        _SectionTitle(title: '⚡ ${l10n.quickAccess}'),
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
        _SectionTitle(title: '🛠️ ${l10n.ourServices}'),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.welcomeOrientation,
          imagePath: 'assets/images/home/accoglienza.jpg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ServiziGateScreen(
                      destinationScreen: const AccoglienzaScreen(),
                      serviceName: l10n.welcomeOrientation,
                    ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.taxMediation,
          imagePath: 'assets/images/home/mediazione.jpg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ServiziGateScreen(
                      destinationScreen: const MediazioneFiscaleScreen(),
                      serviceName: l10n.taxMediation,
                    ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.accountingSupport,
          imagePath: 'assets/images/home/contabile.jpg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ServiziGateScreen(
                      destinationScreen: const SupportoContabileScreen(),
                      serviceName: l10n.accountingSupport,
                    ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Immagine di sfondo
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback con colore gradiente se l'immagine non esiste
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [const Color(0xFF64B5F6), const Color(0xFF2196F3)],
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
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.3),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
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
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.9),
                  size: 24,
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
    return InkWell(
      borderRadius: BorderRadius.circular(48),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF2196F3),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
        _SectionTitle(title: '📰 ${l10n.latestArticles}'),
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
                separatorBuilder: (_, __) => const SizedBox(width: 12),
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
