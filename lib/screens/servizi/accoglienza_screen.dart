import 'package:flutter/material.dart';
import 'permesso_soggiorno_screen.dart';
import 'cittadinanza_screen.dart';
import 'asilo_politico_screen.dart';
import 'visa_turismo_screen.dart';

class AccoglienzaScreen extends StatelessWidget {
  const AccoglienzaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accoglienza e Orientamento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleziona il servizio di cui hai bisogno',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ti guideremo passo dopo passo per completare la tua richiesta',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _ServiceOptionCard(
                icon: Icons.badge,
                title: 'Permesso di Soggiorno',
                description: 'Richiesta, rinnovo e informazioni',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PermessoSoggiornoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.flag,
                title: 'Cittadinanza',
                description: 'Richiesta cittadinanza italiana',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CittadinanzaScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.verified_user,
                title: 'Asilo Politico',
                description: 'Protezione internazionale',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AsiloPoliticoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.flight,
                title: 'Visa per Turismo',
                description: 'Richiesta visto turistico',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VisaTurismoScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.amber.shade700, size: 28),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
