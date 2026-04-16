import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/annunci_wecoop_service.dart';
import '../../services/secure_storage_service.dart';

class AnnunciScreen extends StatefulWidget {
  const AnnunciScreen({super.key});

  @override
  State<AnnunciScreen> createState() => _AnnunciScreenState();
}

class _AnnunciScreenState extends State<AnnunciScreen> {
  final _service = AnnunciWecoopService();
  final _storage = SecureStorageService();
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _annunci = [];
  List<Map<String, dynamic>> _categorie = [];
  bool _loading = true;
  bool _isLoggedIn = false;
  String? _selectedCategoria;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final token = await _storage.read(key: 'jwt_token');
    setState(() => _isLoggedIn = token != null && token.isNotEmpty);
    final cats = await _service.getCategorie();
    setState(() => _categorie = cats);
    await _loadAnnunci(reset: true);
  }

  Future<void> _loadAnnunci({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _loading = true;
      });
    }
    final items = await _service.getAnnunci(
      categoria: _selectedCategoria,
      search:
          _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      page: _page,
    );
    setState(() {
      if (reset) {
        _annunci = items;
      } else {
        _annunci.addAll(items);
      }
      _hasMore = items.length >= 20;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _page++;
    });
    await _loadAnnunci();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1282A8),
        foregroundColor: Colors.white,
        title: const Text('Annunci',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Pubblica annuncio',
              onPressed: () => _showCreaAnnuncio(context),
            ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchCtrl,
            onSearch: () => _loadAnnunci(reset: true),
          ),
          _CategorieBar(
            categorie: _categorie,
            selected: _selectedCategoria,
            onSelect: (slug) {
              setState(() => _selectedCategoria = slug);
              _loadAnnunci(reset: true);
            },
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1282A8)))
                : _annunci.isEmpty
                    ? const _EmptyState()
                    : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n is ScrollEndNotification &&
                              n.metrics.extentAfter < 200) {
                            _loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              _annunci.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == _annunci.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF1282A8))),
                              );
                            }
                            return _AnnuncioCard(
                              annuncio: _annunci[i],
                              onTap: () => _showDetail(
                                  context, _annunci[i]['id'] as int),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1282A8),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Pubblica'),
              onPressed: () => _showCreaAnnuncio(context),
            )
          : null,
    );
  }

  void _showDetail(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AnnuncioDetailSheet(id: id, service: _service),
    );
  }

  void _showCreaAnnuncio(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreaAnnuncioSheet(
        categorie: _categorie,
        service: _service,
        onCreated: () => _loadAnnunci(reset: true),
      ),
    );
  }
}

// =============================================================================
// Search bar
// =============================================================================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1282A8),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cerca eventi, ristoranti, concerti...',
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon:
              const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 16),
        ),
        onSubmitted: (_) => onSearch(),
      ),
    );
  }
}

// =============================================================================
// Categorie chips
// =============================================================================

class _CategorieBar extends StatelessWidget {
  final List<Map<String, dynamic>> categorie;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _CategorieBar(
      {required this.categorie,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      color: scheme.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _Chip(
              label: 'Tutti',
              selected: selected == null,
              onTap: () => onSelect(null)),
          ...categorie.map((cat) => _Chip(
                label: cat['name'] as String,
                selected: selected == cat['slug'],
                onTap: () => onSelect(cat['slug'] as String),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1282A8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF1282A8)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Annuncio card
// =============================================================================

class _AnnuncioCard extends StatelessWidget {
  final Map<String, dynamic> annuncio;
  final VoidCallback onTap;

  const _AnnuncioCard(
      {required this.annuncio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final imgUrl = annuncio['immagine_url'] as String? ?? '';
    final dataInizio = annuncio['data_inizio'] as String? ?? '';
    final ora = annuncio['ora_inizio'] as String? ?? '';
    final luogo = annuncio['luogo'] as String? ?? '';
    final citta = annuncio['citta'] as String? ?? '';
    final prezzo =
        (annuncio['prezzo_ingresso'] as num?)?.toDouble() ?? 0.0;
    final cats = (annuncio['categorie'] as List?) ?? [];
    final catName =
        cats.isNotEmpty ? cats.first['name'] as String : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imgUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: Image.network(
                  imgUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (catName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1282A8)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(catName,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1282A8),
                                  fontWeight: FontWeight.w600)),
                        ),
                      const Spacer(),
                      Text(
                        prezzo == 0
                            ? 'Gratuito'
                            : '€${prezzo.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: prezzo == 0
                              ? Colors.green.shade700
                              : const Color(0xFF1282A8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    annuncio['titolo'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if ((annuncio['descrizione'] as String? ?? '')
                      .isNotEmpty)
                    Text(
                      annuncio['descrizione'] as String,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (dataInizio.isNotEmpty) ...[
                        const Icon(Icons.calendar_today,
                            size: 13, color: Color(0xFF1282A8)),
                        const SizedBox(width: 4),
                        Text(
                          '$dataInizio${ora.isNotEmpty ? '  $ora' : ''}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1282A8)),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (luogo.isNotEmpty || citta.isNotEmpty) ...[
                        const Icon(Icons.location_on,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            [luogo, citta]
                                .where((s) => s.isNotEmpty)
                                .join(', '),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
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

// =============================================================================
// Detail bottom sheet
// =============================================================================

class _AnnuncioDetailSheet extends StatefulWidget {
  final int id;
  final AnnunciWecoopService service;

  const _AnnuncioDetailSheet(
      {required this.id, required this.service});

  @override
  State<_AnnuncioDetailSheet> createState() =>
      _AnnuncioDetailSheetState();
}

class _AnnuncioDetailSheetState
    extends State<_AnnuncioDetailSheet> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  int? _currentUserId;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    widget.service.getAnnuncio(widget.id).then((d) {
      setState(() {
        _data = d;
        _loading = false;
      });
    });
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final storage = SecureStorageService();
    final raw = await storage.read(key: 'user_id');
    if (raw != null) {
      setState(() => _currentUserId = int.tryParse(raw));
    }
  }

  bool get _isOwner {
    if (_currentUserId == null || _data == null) return false;
    final autoreId = _data!['autore_id'];
    if (autoreId == null) return false;
    return (autoreId as int) == _currentUserId;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina annuncio'),
        content: const Text(
            'Sei sicuro di voler eliminare questo annuncio? L\'operazione non può essere annullata.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    final ok = await widget.service.eliminaAnnuncio(widget.id);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context); // chiude il bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annuncio eliminato'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Errore durante l\'eliminazione')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF1282A8)))
            : _data == null
                ? const Center(child: Text('Annuncio non trovato'))
                : ListView(
                    controller: ctrl,
                    children: [
                      Center(
                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(vertical: 10),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if ((_data!['immagine_url'] as String? ?? '')
                          .isNotEmpty)
                        Image.network(
                          _data!['immagine_url'] as String,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _data!['titolo'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _MetaRow(data: _data!),
                            const SizedBox(height: 16),
                            if ((_data!['descrizione']
                                        as String? ??
                                    '')
                                .isNotEmpty)
                              Text(
                                _data!['descrizione'] as String,
                                style: const TextStyle(
                                    fontSize: 15, height: 1.6),
                              ),
                            const SizedBox(height: 16),
                            _SpecificiSection(data: _data!),
                            const SizedBox(height: 16),
                            _ContattiSection(data: _data!),
                            const SizedBox(height: 16),
                            if (_isOwner)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: _deleting
                                      ? null
                                      : () => _confirmDelete(context),
                                  icon: _deleting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child:
                                              CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2))
                                      : const Icon(Icons.delete_outline),
                                  label: Text(_deleting
                                      ? 'Eliminazione...'
                                      : 'Elimina annuncio'),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MetaRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final dataInizio = data['data_inizio'] as String? ?? '';
    final oraInizio = data['ora_inizio'] as String? ?? '';
    final luogo = data['luogo'] as String? ?? '';
    final citta = data['citta'] as String? ?? '';
    final prezzo =
        (data['prezzo_ingresso'] as num?)?.toDouble() ?? 0.0;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        if (dataInizio.isNotEmpty)
          _MetaChip(
            icon: Icons.calendar_today,
            label:
                '$dataInizio${oraInizio.isNotEmpty ? ' · $oraInizio' : ''}',
          ),
        if (luogo.isNotEmpty || citta.isNotEmpty)
          _MetaChip(
            icon: Icons.location_on,
            label: [luogo, citta]
                .where((s) => s.isNotEmpty)
                .join(', '),
          ),
        _MetaChip(
          icon: Icons.euro,
          label: prezzo == 0
              ? 'Ingresso gratuito'
              : '€${prezzo.toStringAsFixed(0)}',
          color: prezzo == 0
              ? Colors.green
              : const Color(0xFF1282A8),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MetaChip(
      {required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1282A8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: c,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SpecificiSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SpecificiSection({required this.data});

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artista = data['artista'] as String? ?? '';
    final genere = data['genere_musicale'] as String? ?? '';
    final linkBiglietti = data['link_biglietti'] as String? ?? '';
    final menu = data['menu_giorno'] as String? ?? '';
    final offerta = data['offerta_speciale'] as String? ?? '';
    final coperti = data['coperti_disp'] as int? ?? 0;
    final prenota = data['prenota_tavolo'] as String? ?? '';
    final disp = data['disponibilita'] as String? ?? '';
    final tariffa =
        (data['tariffa'] as num?)?.toDouble() ?? 0.0;

    final hasInfo = artista.isNotEmpty ||
        genere.isNotEmpty ||
        menu.isNotEmpty ||
        offerta.isNotEmpty ||
        disp.isNotEmpty;
    if (!hasInfo) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1282A8).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Artista', artista),
          _row('Genere', genere),
          if (linkBiglietti.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(linkBiglietti)),
                child: const Text('🎟 Acquista biglietti',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1282A8),
                        decoration:
                            TextDecoration.underline)),
              ),
            ),
          _row('Menu del giorno', menu),
          _row('Offerta speciale', offerta),
          if (coperti > 0)
            _row('Coperti disponibili', coperti.toString()),
          if (prenota.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () {
                  final uri = prenota.startsWith('http')
                      ? Uri.parse(prenota)
                      : Uri.parse('tel:$prenota');
                  launchUrl(uri);
                },
                child: Text('📞 Prenota: $prenota',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1282A8),
                        decoration:
                            TextDecoration.underline)),
              ),
            ),
          _row('Disponibilità', disp),
          if (tariffa > 0)
            _row('Tariffa',
                '€${tariffa.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

class _ContattiSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ContattiSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final tel = data['telefono'] as String? ?? '';
    final email = data['email'] as String? ?? '';
    final sito = data['sito_web'] as String? ?? '';
    final indirizzo = data['indirizzo'] as String? ?? '';
    final cap = data['cap'] as String? ?? '';
    final citta = data['citta'] as String? ?? '';

    if (tel.isEmpty && email.isEmpty && sito.isEmpty && indirizzo.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contatti',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (indirizzo.isNotEmpty)
          _ContactRow(
              icon: Icons.location_on,
              label: [indirizzo, cap, citta]
                  .where((s) => s.isNotEmpty)
                  .join(', ')),
        if (tel.isNotEmpty)
          _ContactRow(
              icon: Icons.phone,
              label: tel,
              onTap: () => launchUrl(Uri.parse('tel:$tel'))),
        if (email.isNotEmpty)
          _ContactRow(
              icon: Icons.email,
              label: email,
              onTap: () =>
                  launchUrl(Uri.parse('mailto:$email'))),
        if (sito.isNotEmpty)
          _ContactRow(
              icon: Icons.language,
              label: sito,
              onTap: () => launchUrl(Uri.parse(sito))),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ContactRow(
      {required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1282A8)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 14,
                    color: onTap != null
                        ? const Color(0xFF1282A8)
                        : Colors.black87,
                    decoration: onTap != null
                        ? TextDecoration.underline
                        : TextDecoration.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Form pubblica annuncio
// =============================================================================

class _CreaAnnuncioSheet extends StatefulWidget {
  final List<Map<String, dynamic>> categorie;
  final AnnunciWecoopService service;
  final VoidCallback onCreated;

  const _CreaAnnuncioSheet(
      {required this.categorie,
      required this.service,
      required this.onCreated});

  @override
  State<_CreaAnnuncioSheet> createState() =>
      _CreaAnnuncioSheetState();
}

class _CreaAnnuncioSheetState
    extends State<_CreaAnnuncioSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titoloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _luogoCtrl = TextEditingController();
  final _cittaCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _sitoCtrl = TextEditingController();
  final _prezzoCtrl = TextEditingController();

  String? _selectedCategoria;
  DateTime? _dataInizio;
  TimeOfDay? _oraInizio;
  bool _submitting = false;

  // Foto
  final _imagePicker = ImagePicker();
  File? _copertina;
  final List<File> _fotoGalleria = [];

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _descCtrl.dispose();
    _luogoCtrl.dispose();
    _cittaCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _sitoCtrl.dispose();
    _prezzoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final data = <String, dynamic>{
      'titolo': _titoloCtrl.text.trim(),
      'descrizione': _descCtrl.text.trim(),
      if (_selectedCategoria != null) 'categoria': _selectedCategoria,
      if (_luogoCtrl.text.isNotEmpty) 'luogo': _luogoCtrl.text.trim(),
      if (_cittaCtrl.text.isNotEmpty) 'citta': _cittaCtrl.text.trim(),
      if (_telCtrl.text.isNotEmpty) 'telefono': _telCtrl.text.trim(),
      if (_emailCtrl.text.isNotEmpty) 'email': _emailCtrl.text.trim(),
      if (_sitoCtrl.text.isNotEmpty) 'sito_web': _sitoCtrl.text.trim(),
      if (_prezzoCtrl.text.isNotEmpty)
        'prezzo_ingresso': _prezzoCtrl.text.trim(),
      if (_dataInizio != null)
        'data_inizio':
            '${_dataInizio!.year.toString().padLeft(4, '0')}-${_dataInizio!.month.toString().padLeft(2, '0')}-${_dataInizio!.day.toString().padLeft(2, '0')}',
      if (_oraInizio != null)
        'ora_inizio':
            '${_oraInizio!.hour.toString().padLeft(2, '0')}:${_oraInizio!.minute.toString().padLeft(2, '0')}',
      'giorni_pubblicazione': 3,
    };

    final result = await widget.service.creaAnnuncio(data);

    if (result['success'] != true) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] as String? ?? 'Errore'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Carica foto dopo aver creato l'annuncio
    final annuncioId = (result['annuncio']?['id'] as int?) ?? 0;
    if (annuncioId > 0) {
      if (_copertina != null) {
        await widget.service.uploadCopertina(annuncioId, _copertina!);
      }
      for (final foto in _fotoGalleria) {
        await widget.service.uploadFoto(annuncioId, foto);
      }
    }

    setState(() => _submitting = false);
    if (!mounted) return;
    Navigator.pop(context);
    widget.onCreated();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('✅ Annuncio pubblicato! Visibile per 3 giorni gratis.'),
      backgroundColor: Color(0xFF1282A8),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.98,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: ctrl,
            padding:
                const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Pubblica un annuncio',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '✅ 3 giorni gratuiti · €1/giorno per estenderlo',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade700),
              ),
              const SizedBox(height: 20),

              _FormField(
                controller: _titoloCtrl,
                label: 'Titolo *',
                hint:
                    'Es. Concerto di Soolking, Aperitivo speciale...',
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Campo obbligatorio'
                        : null,
              ),
              const SizedBox(height: 16),

              // --- Foto copertina ---
              _SectionLabel(label: '📷 Foto copertina'),
              const SizedBox(height: 8),
              _CopertinaPickerTile(
                file: _copertina,
                onPick: () async {
                  final picked = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                    maxWidth: 1400,
                  );
                  if (picked != null) {
                    setState(() => _copertina = File(picked.path));
                  }
                },
                onRemove: () => setState(() => _copertina = null),
              ),
              const SizedBox(height: 16),

              // --- Foto galleria ---
              _SectionLabel(label: '🖼 Foto galleria (max 8)'),
              const SizedBox(height: 8),
              _GalleriaPickerRow(
                files: _fotoGalleria,
                onAdd: () async {
                  if (_fotoGalleria.length >= 8) return;
                  final picked = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                    maxWidth: 1200,
                  );
                  if (picked != null) {
                    setState(() => _fotoGalleria.add(File(picked.path)));
                  }
                },
                onRemove: (i) => setState(() => _fotoGalleria.removeAt(i)),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('— Seleziona —')),
                  ...widget.categorie.map((c) =>
                      DropdownMenuItem(
                        value: c['slug'] as String,
                        child: Text(c['name'] as String),
                      )),
                ],
                onChanged: (v) =>
                    setState(() => _selectedCategoria = v),
              ),
              const SizedBox(height: 8),

              _FormField(
                  controller: _descCtrl,
                  label: 'Descrizione',
                  hint: 'Descrivi l\'annuncio...',
                  maxLines: 4),
              const SizedBox(height: 8),

              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today,
                        size: 16),
                    label: Text(_dataInizio == null
                        ? 'Data evento'
                        : '${_dataInizio!.day}/${_dataInizio!.month}/${_dataInizio!.year}'),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now()
                            .add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365)),
                      );
                      if (d != null)
                        setState(() => _dataInizio = d);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time,
                        size: 16),
                    label: Text(_oraInizio == null
                        ? 'Ora'
                        : _oraInizio!.format(context)),
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null)
                        setState(() => _oraInizio = t);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 8),

              Row(children: [
                Expanded(
                    child: _FormField(
                        controller: _luogoCtrl,
                        label: 'Luogo / Venue',
                        hint: 'Nome del posto')),
                const SizedBox(width: 8),
                Expanded(
                    child: _FormField(
                        controller: _cittaCtrl,
                        label: 'Città',
                        hint: 'Milano')),
              ]),
              const SizedBox(height: 8),

              _FormField(
                  controller: _prezzoCtrl,
                  label: 'Prezzo ingresso (€)',
                  hint: '0 = gratuito',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),

              _FormField(
                  controller: _telCtrl,
                  label: 'Telefono',
                  hint: '+39...',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 8),

              _FormField(
                  controller: _emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),

              _FormField(
                  controller: _sitoCtrl,
                  label: 'Sito web / Link prenotazione',
                  hint: 'https://...',
                  keyboardType: TextInputType.url),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1282A8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text(
                          'Pubblica gratis (3 giorni)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }
}

// =============================================================================
// Empty state
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Nessun annuncio trovato',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Sii il primo a pubblicare!',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// =============================================================================
// Foto helpers widgets
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600));
  }
}

/// Tile per la foto copertina — anteprima grande con bottone rimuovi
class _CopertinaPickerTile extends StatelessWidget {
  final File? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _CopertinaPickerTile(
      {required this.file,
      required this.onPick,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return GestureDetector(
        onTap: onPick,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1282A8).withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1282A8).withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 36, color: Color(0xFF1282A8)),
              SizedBox(height: 8),
              Text('Aggiungi foto copertina',
                  style: TextStyle(
                      color: Color(0xFF1282A8),
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('JPG, PNG o WebP · max 5MB',
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file!,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _PhotoActionBtn(
                  icon: Icons.edit, onTap: onPick, tooltip: 'Cambia'),
              const SizedBox(width: 6),
              _PhotoActionBtn(
                  icon: Icons.delete,
                  onTap: onRemove,
                  tooltip: 'Rimuovi',
                  color: Colors.red),
            ],
          ),
        ),
      ],
    );
  }
}

/// Riga scrollabile con le foto della galleria + bottone aggiungi
class _GalleriaPickerRow extends StatelessWidget {
  final List<File> files;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _GalleriaPickerRow(
      {required this.files,
      required this.onAdd,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Bottone aggiungi
          if (files.length < 8)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1282A8).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        const Color(0xFF1282A8).withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 28, color: Color(0xFF1282A8)),
                    SizedBox(height: 4),
                    Text('Aggiungi',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1282A8))),
                  ],
                ),
              ),
            ),
          ...files.asMap().entries.map((e) {
            final i = e.key;
            final f = e.value;
            return Stack(
              children: [
                Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(f,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 12,
                  child: _PhotoActionBtn(
                    icon: Icons.close,
                    onTap: () => onRemove(i),
                    tooltip: 'Rimuovi',
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PhotoActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;
  final double size;

  const _PhotoActionBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon,
              size: size, color: color ?? Colors.white),
        ),
      ),
    );
  }
}
