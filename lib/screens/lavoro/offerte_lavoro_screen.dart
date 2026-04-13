import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wecoop_app/models/offerta_lavoro_model.dart';
import 'package:wecoop_app/screens/servizi/lavoro_orientamento_screen.dart';
import 'package:wecoop_app/services/offerte_lavoro_service.dart';
import 'package:wecoop_app/services/annunci_submission_service.dart';

class OfferteLavoroScreen extends StatefulWidget {
  const OfferteLavoroScreen({super.key});

  @override
  State<OfferteLavoroScreen> createState() => _OfferteLavoroScreenState();
}

class _OfferteLavoroScreenState extends State<OfferteLavoroScreen> {
  static const String _wecoopWhatsAppNumber = '393515112113';

  final TextEditingController _searchController = TextEditingController();

  List<OffertaLavoro> _offerte = [];
  List<OffertaCategoria> _categorie = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  String? _selectedCategoriaSlug;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    final categorieResult = await OfferteLavoroService.getCategorie();
    final offerteResult = await OfferteLavoroService.getOfferte(
      page: 1,
      perPage: 12,
      search: _searchController.text,
      categoria: _selectedCategoriaSlug,
    );

    if (!mounted) return;

    if (offerteResult['success'] == true) {
      final pagination =
          offerteResult['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      setState(() {
        _offerte = (offerteResult['offerte'] as List<OffertaLavoro>);
        _totalPages = (pagination['total_pages'] as num?)?.toInt() ?? 1;
        _isLoading = false;
        _categorie =
            categorieResult['success'] == true
                ? (categorieResult['categorie'] as List<OffertaCategoria>)
                : <OffertaCategoria>[];
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage =
          (offerteResult['message'] ?? 'Errore caricamento annunci').toString();
      _categorie =
          categorieResult['success'] == true
              ? (categorieResult['categorie'] as List<OffertaCategoria>)
              : <OffertaCategoria>[];
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final result = await OfferteLavoroService.getOfferte(
      page: nextPage,
      perPage: 12,
      search: _searchController.text,
      categoria: _selectedCategoriaSlug,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final pagination =
          result['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      setState(() {
        _offerte.addAll(result['offerte'] as List<OffertaLavoro>);
        _currentPage = nextPage;
        _totalPages =
            (pagination['total_pages'] as num?)?.toInt() ?? _totalPages;
        _isLoadingMore = false;
      });
      return;
    }

    setState(() => _isLoadingMore = false);
  }

  Future<void> _openDetail(OffertaLavoro offerta) async {
    final result = await OfferteLavoroService.getOfferta(offerta.id);
    if (!mounted) return;

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] ?? 'Dettaglio non disponibile').toString(),
          ),
        ),
      );
      return;
    }

    final detailed = result['offerta'] as OffertaLavoro;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => _OffertaLavoroDetailScreen(
              offerta: detailed,
              onApply: () => _openApplySheet(detailed),
            ),
      ),
    );
  }

  Future<void> _openApplySheet(OffertaLavoro offerta) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CandidaturaSheet(offerta: offerta),
    );

    if (!mounted || result == null) return;

    final success = result['success'] == true;
    final msg = (result['message'] ?? '').toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg.isEmpty
              ? (success ? 'Candidatura inviata' : 'Errore candidatura')
              : msg,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _openSupportWhatsApp({required String message}) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$_wecoopWhatsAppNumber?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossibile aprire WhatsApp')),
    );
  }

  Future<void> _openPublishAdSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PubblicaAnnuncioSheet(),
    );

    if (!mounted || result == null) return;

    final success = result['success'] == true;
    final message = (result['message'] ?? '').toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.isEmpty ? 'Richiesta inviata' : message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offerte e Annunci Lavoro'),
        actions: [
          IconButton(
            tooltip: 'Servizio orientamento',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LavoroOrientamentoScreen(),
                ),
              );
            },
            icon: const Icon(Icons.school),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 12),
          Center(child: Text(_errorMessage!, textAlign: TextAlign.center)),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Riprova'),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cosa vuoi fare?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Puoi cercare offerte lavoro, attivare supporto servizi oppure pubblicare un annuncio.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadInitialData,
                    icon: const Icon(Icons.search),
                    label: const Text('Cerca lavoro'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LavoroOrientamentoScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Cerca servizi'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openPublishAdSheet,
                    icon: const Icon(Icons.campaign),
                    label: const Text('Inserisci annuncio'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed:
                    () => _openSupportWhatsApp(
                      message:
                          'Ciao WECOOP, vorrei informazioni per cercare lavoro o attivare servizi dedicati.',
                    ),
                icon: const Icon(Icons.chat),
                label: const Text('Contatta WECOOP su WhatsApp'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cerca: baby sitter, badante, colf, OSS, ASO, DJ...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.arrow_forward),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _loadInitialData(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Tutte'),
                  selected: _selectedCategoriaSlug == null,
                  onSelected: (_) {
                    setState(() => _selectedCategoriaSlug = null);
                    _loadInitialData();
                  },
                ),
              ),
              ..._categorie.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: _selectedCategoriaSlug == c.slug,
                    onSelected: (_) {
                      setState(() => _selectedCategoriaSlug = c.slug);
                      _loadInitialData();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_offerte.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Nessun annuncio disponibile con questi filtri. Prova categorie come Pulizie/Limpieza, Badante o Baby sitter.',
            ),
          )
        else
          ..._offerte.map(
            (offerta) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => _openDetail(offerta),
                title: Text(
                  offerta.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (offerta.companyName.isNotEmpty)
                      Text(offerta.companyName),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (offerta.city.isNotEmpty)
                          _MetaChip(
                            icon: Icons.location_on,
                            text: offerta.city,
                          ),
                        if (offerta.contractType.isNotEmpty)
                          _MetaChip(
                            icon: Icons.badge,
                            text: offerta.contractType,
                          ),
                        if (offerta.isFeatured)
                          const _MetaChip(
                            icon: Icons.star,
                            text: 'In evidenza',
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        if (_currentPage < _totalPages)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton(
              onPressed: _isLoadingMore ? null : _loadMore,
              child:
                  _isLoadingMore
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Carica altri annunci'),
            ),
          ),
      ],
    );
  }
}

class _PubblicaAnnuncioSheet extends StatefulWidget {
  const _PubblicaAnnuncioSheet();

  @override
  State<_PubblicaAnnuncioSheet> createState() => _PubblicaAnnuncioSheetState();
}

class _PubblicaAnnuncioSheetState extends State<_PubblicaAnnuncioSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titoloCtrl = TextEditingController();
  final _cittaCtrl = TextEditingController();
  final _contattoCtrl = TextEditingController();
  final _descrizioneCtrl = TextEditingController();
  bool _privacy = false;
  String _tipo = 'Lavoro';
  bool _isSending = false;

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _cittaCtrl.dispose();
    _contattoCtrl.dispose();
    _descrizioneCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (!_formKey.currentState!.validate()) return false;
    if (_privacy) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Devi accettare il consenso privacy')),
    );
    return false;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isSending = true);

    final result = await AnnunciSubmissionService.submitJobAnnouncement(
      submissionType: _tipo,
      titleOffer: _titoloCtrl.text.trim(),
      city: _cittaCtrl.text.trim(),
      contactPhone: _contattoCtrl.text.trim(),
      description: _descrizioneCtrl.text.trim(),
      consentPrivacy: _privacy,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inserisci annuncio',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Compila i dati e invia la richiesta a WECOOP per la pubblicazione.',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                items: const [
                  DropdownMenuItem(value: 'Lavoro', child: Text('Lavoro')),
                  DropdownMenuItem(value: 'Servizio', child: Text('Servizio')),
                ],
                onChanged: (value) => setState(() => _tipo = value ?? 'Lavoro'),
                decoration: const InputDecoration(labelText: 'Tipo annuncio'),
              ),
              TextFormField(
                controller: _titoloCtrl,
                decoration: const InputDecoration(labelText: 'Titolo annuncio'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              TextFormField(
                controller: _cittaCtrl,
                decoration: const InputDecoration(labelText: 'Citta'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              TextFormField(
                controller: _contattoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telefono o email di contatto',
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              TextFormField(
                controller: _descrizioneCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  hintText:
                      'Descrivi mansione/servizio, orari e requisiti principali',
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().length < 20)
                            ? 'Inserisci almeno 20 caratteri'
                            : null,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _privacy,
                onChanged: (v) => setState(() => _privacy = v == true),
                title: const Text('Accetto il trattamento dei dati personali'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[400],
                    disabledForegroundColor: Colors.grey[600],
                  ),
                  icon:
                      _isSending
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.send, size: 22),
                  label: Text(
                    _isSending ? 'Invio in corso...' : 'Invia annuncio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _OffertaLavoroDetailScreen extends StatelessWidget {
  final OffertaLavoro offerta;
  final VoidCallback onApply;

  const _OffertaLavoroDetailScreen({
    required this.offerta,
    required this.onApply,
  });

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String value) async {
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('https://wa.me/${digits.replaceAll('+', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio annuncio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            offerta.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (offerta.companyName.isNotEmpty)
            Text(
              offerta.companyName,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (offerta.city.isNotEmpty)
                _MetaChip(icon: Icons.location_on, text: offerta.city),
              if (offerta.contractType.isNotEmpty)
                _MetaChip(icon: Icons.badge, text: offerta.contractType),
              if (offerta.workMode.isNotEmpty)
                _MetaChip(icon: Icons.workspaces, text: offerta.workMode),
              if (offerta.languageRequirement.isNotEmpty)
                _MetaChip(
                  icon: Icons.language,
                  text: offerta.languageRequirement,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (offerta.requirements.isNotEmpty) ...[
            const Text(
              'Requisiti',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.requirements),
            const SizedBox(height: 12),
          ],
          if (offerta.content.isNotEmpty) ...[
            const Text(
              'Descrizione',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.content),
            const SizedBox(height: 12),
          ] else if (offerta.excerpt.isNotEmpty) ...[
            const Text(
              'Descrizione',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.excerpt),
            const SizedBox(height: 12),
          ],
          if (offerta.schedule.isNotEmpty) ...[
            const Text('Orari', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(offerta.schedule),
            const SizedBox(height: 12),
          ],
          if (offerta.salaryRange.isNotEmpty) ...[
            const Text(
              'Retribuzione',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.salaryRange),
            const SizedBox(height: 12),
          ],
          if (offerta.expiresAt.isNotEmpty) ...[
            const Text(
              'Scadenza',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.expiresAt),
            const SizedBox(height: 12),
          ],
          if (offerta.categories.isNotEmpty) ...[
            const Text(
              'Categorie',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  offerta.categories
                      .map((c) => Chip(label: Text(c.name)))
                      .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (offerta.phoneWhatsapp.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _openWhatsApp(offerta.phoneWhatsapp),
              icon: const Icon(Icons.chat),
              label: const Text('Contatta su WhatsApp'),
            ),
          if (offerta.sourceUrl.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => _openUrl(offerta.sourceUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Apri annuncio originale'),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.send),
            label: const Text('Candidati ora'),
          ),
        ],
      ),
    );
  }
}

class _CandidaturaSheet extends StatefulWidget {
  final OffertaLavoro offerta;

  const _CandidaturaSheet({required this.offerta});

  @override
  State<_CandidaturaSheet> createState() => _CandidaturaSheetState();
}

class _CandidaturaSheetState extends State<_CandidaturaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _privacy = false;
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_privacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devi accettare il consenso privacy')),
      );
      return;
    }

    setState(() => _sending = true);

    final result = await OfferteLavoroService.inviaCandidatura(
      offerId: widget.offerta.id,
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      city: _cityCtrl.text,
      note: _noteCtrl.text,
      consentPrivacy: _privacy,
    );

    if (!mounted) return;
    setState(() => _sending = false);

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Candidatura rapida',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(widget.offerta.title),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome e cognome'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefono / WhatsApp',
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (opzionale)',
                ),
              ),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Citta (opzionale)',
                ),
              ),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nota (opzionale)',
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _privacy,
                onChanged: (v) => setState(() => _privacy = v == true),
                title: const Text('Accetto il trattamento dei dati personali'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  child:
                      _sending
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Invia candidatura'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
