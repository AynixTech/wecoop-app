import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_localizations.dart';

class ContattiScreen extends StatelessWidget {
  const ContattiScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contacts),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con immagine o colore
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contactsTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'WECOOP',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenuto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sede
                  _buildSectionTitle(l10n.ourOffice),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    title: l10n.officeAddress,
                    subtitle: l10n.getDirections,
                    onTap: () {
                      // Google Maps
                      _launchUrl('https://www.google.com/maps/search/?api=1&query=Via+Populonia+8,+20159+Milano+MI');
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Orari
                  _buildSectionTitle(l10n.officeHours),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    iconColor: Colors.blue,
                    title: l10n.officeHoursDetails,
                    subtitle: null,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Telefono
                  _buildSectionTitle(l10n.contactPhone),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.phone,
                    iconColor: Colors.green,
                    title: '+39 02 1234567',
                    subtitle: l10n.callUs,
                    onTap: () {
                      _launchUrl('tel:+390212345678');
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Email
                  _buildSectionTitle(l10n.emailAddress),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.email,
                    iconColor: Colors.orange,
                    title: 'info@wecoop.it',
                    subtitle: l10n.contactSendEmail,
                    onTap: () {
                      _launchUrl('mailto:info@wecoop.it');
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social Media
                  _buildSectionTitle(l10n.followUs),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        color: const Color(0xFF1877F2),
                        label: 'Facebook',
                        onTap: () {
                          _launchUrl('https://www.facebook.com/wecoop');
                        },
                      ),
                      _buildSocialButton(
                        icon: Icons.camera_alt,
                        color: const Color(0xFFE4405F),
                        label: 'Instagram',
                        onTap: () {
                          _launchUrl('https://www.instagram.com/wecoop');
                        },
                      ),
                      _buildSocialButton(
                        icon: Icons.language,
                        color: Colors.blue.shade700,
                        label: 'Website',
                        onTap: () {
                          _launchUrl('https://www.wecoop.it');
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Mappa (opzionale - immagine statica o widget mappa)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.map,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _launchUrl('https://www.google.com/maps/search/?api=1&query=Via+Populonia+8,+20159+Milano+MI');
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.map,
                                      size: 48,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.getDirections,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
  
  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
