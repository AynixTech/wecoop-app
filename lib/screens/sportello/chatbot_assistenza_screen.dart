import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/supporto_ai_service.dart';
import '../servizi/servizi_gate_screen.dart';
import '../progetti/progetti_screen.dart';
import '../servizi/permesso_soggiorno_screen.dart';
import '../servizi/cittadinanza_screen.dart';
import '../servizi/asilo_politico_screen.dart';
import '../servizi/mediazione_fiscale_screen.dart';
import '../servizi/accoglienza_screen.dart';
import '../servizi/lavoro_orientamento_screen.dart';
import '../servizi/educazione_finanziaria_credito_screen.dart';
import '../servizi/supporto_contabile_screen.dart';

class ChatbotAssistenzaScreen extends StatefulWidget {
  const ChatbotAssistenzaScreen({super.key});

  @override
  State<ChatbotAssistenzaScreen> createState() => _ChatbotAssistenzaScreenState();
}

class _ChatbotAssistenzaScreenState extends State<ChatbotAssistenzaScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFAQ = true;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(_welcomeMessage());
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text, {Widget? action}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        action: action,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _textController.clear();
    _scrollToBottom();
    
    _simulateThinkingThenReply(() {
      _processUserInput(text);
    });
  }

  String _welcomeMessage() {
    final l10n = AppLocalizations.of(context)!;
    return '${l10n.translate('chatbotWelcome')}\n\n'
        'Sono il tuo assistente WECOOP. Ti aiuto in modo pratico su:\n'
        '• Accesso al lavoro\n'
        '• Credito e finanziamento piccole aziende\n'
        '• Partita IVA e contabilita\n'
        '• Vivere in Italia e documenti\n'
        '• Prenotazione appuntamenti';
  }

  void _simulateThinkingThenReply(VoidCallback onReply) {
    if (!mounted) return;
    setState(() => _isTyping = true);
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      onReply();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _processUserInput(String input) async {
    final l10n = AppLocalizations.of(context)!;
    final inputLower = input.toLowerCase();

    final backendReply = await SupportoAiService.askAssistant(
      message: input,
      language: Localizations.localeOf(context).languageCode,
    );

    if (backendReply['success'] == true &&
        (backendReply['reply'] ?? '').toString().trim().isNotEmpty) {
      final replyText = (backendReply['reply'] ?? '').toString();
      final actionKey = (backendReply['action_key'] ?? '').toString();
      final actionLabel = (backendReply['action_label'] ?? '').toString();

      _addBotMessage(
        replyText,
        action: _buildBackendAction(actionKey, actionLabel),
      );
      return;
    }

    final asksWork =
        inputLower.contains('lavoro') ||
        inputLower.contains('stage') ||
        inputLower.contains('tirocin') ||
        inputLower.contains('agenzi') ||
        inputLower.contains('job') ||
        inputLower.contains('work');

    final asksCreditoImpresa =
        inputLower.contains('microcredito') ||
        inputLower.contains('credito') ||
        inputLower.contains('finanzi') ||
        inputLower.contains('impresa') ||
        inputLower.contains('azienda') ||
        inputLower.contains('business');

    final asksPiva =
        inputLower.contains('partita iva') ||
        inputLower.contains('contabil') ||
        inputLower.contains('fattur') ||
        inputLower.contains('iva') ||
        inputLower.contains('accounting');

    final asksWelcome =
        inputLower.contains('vivere in italia') ||
        inputLower.contains('integrazione') ||
        inputLower.contains('permesso') ||
        inputLower.contains('soggiorno') ||
        inputLower.contains('migranti') ||
        inputLower.contains('documenti');

    final asksAppointment =
        inputLower.contains('appuntamento') ||
        inputLower.contains('prenot') ||
        inputLower.contains('cita') ||
        inputLower.contains('appointment');

    if (asksWork) {
      _addBotMessage(
        'Ottimo, posso accompagnarti su accesso al lavoro: candidature, orientamento e attivazione supporto lavoro.',
        action: _buildNavigationButton('Apri Accesso al lavoro', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const ServiziGateScreen(
                    destinationScreen: LavoroOrientamentoScreen(),
                    serviceName: 'Accesso al lavoro',
                  ),
            ),
          );
        }),
      );
      return;
    }

    if (asksCreditoImpresa) {
      _addBotMessage(
        'Perfetto, per microcredito e finanziamento a piccole aziende ti porto nel percorso dedicato.',
        action: _buildNavigationButton(
          'Apri Educazione finanziaria + credito',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => const ServiziGateScreen(
                      destinationScreen: EducazioneFinanziariaCreditoScreen(),
                      serviceName: 'Educazione finanziaria + credito',
                    ),
              ),
            );
          },
        ),
      );
      return;
    }

    if (asksPiva) {
      _addBotMessage(
        'Per apertura attivita, gestione Partita IVA e contabilita ti guido nello sportello dedicato.',
        action: _buildNavigationButton('Apri Partita IVA e contabilita', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const ServiziGateScreen(
                    destinationScreen: SupportoContabileScreen(),
                    serviceName: 'Partita IVA e contabilita',
                  ),
            ),
          );
        }),
      );
      return;
    }

    if (asksWelcome) {
      _addBotMessage(
        'Ti aiuto volentieri. Per documenti e integrazione in Italia, apri direttamente Vivere in Italia.',
        action: _buildNavigationButton('Apri Vivere in Italia', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const ServiziGateScreen(
                    destinationScreen: AccoglienzaScreen(),
                    serviceName: 'Vivere in Italia',
                  ),
            ),
          );
        }),
      );
      return;
    }

    if (asksAppointment) {
      _addBotMessage(
        'Perfetto, prenotiamo subito un appuntamento con il team WECOOP.',
        action: _buildNavigationButton('Prenota appuntamento', () {
          Navigator.pushNamed(context, '/prenotaAppuntamento');
        }),
      );
      return;
    }
    
    // Servizi - multilingua
    if (inputLower.contains('serviz') || inputLower.contains('service') || inputLower.contains('aiuto') || 
        inputLower.contains('help') || inputLower.contains('ayuda')) {
      _addBotMessage(
        'Ti aiuto subito. Dimmi pure se preferisci lavoro, credito, partita IVA o vivere in Italia. Se vuoi, usa una scorciatoia:',
        action: _buildFeatureHubButtons(),
      );
    }
    // Progetti - multilingua
    else if (inputLower.contains('progett') || inputLower.contains('project') || inputLower.contains('proyecto') ||
             inputLower.contains('mafalda') || inputLower.contains('womentor') || 
             inputLower.contains('sport') || inputLower.contains('giovani') || 
             inputLower.contains('donne') || inputLower.contains('youth') || inputLower.contains('women')) {
      _addBotMessage(
        l10n.translate('chatbotProjectsResponse'),
        action: _buildProjectButtons(),
      );
    }
    // Permesso di soggiorno - multilingua
    else if (inputLower.contains('permesso') || inputLower.contains('soggiorno') || 
             inputLower.contains('permit') || inputLower.contains('residence') ||
             inputLower.contains('permiso') || inputLower.contains('residencia')) {
      _addBotMessage(
        l10n.translate('chatbotPermitResponse'),
        action: _buildNavigationButton(l10n.translate('chatbotGoToServices'), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiziGateScreen(
            destinationScreen: PermessoSoggiornoScreen(),
            serviceName: 'Permesso di Soggiorno',
          )));
        }),
      );
    }
    // Cittadinanza - multilingua
    else if (inputLower.contains('cittadinanza') || inputLower.contains('citizenship') || inputLower.contains('ciudadanía')) {
      _addBotMessage(
        l10n.translate('chatbotCitizenshipResponse'),
        action: _buildNavigationButton(l10n.translate('chatbotRequestCitizenship'), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiziGateScreen(
            destinationScreen: CittadinanzaScreen(),
            serviceName: 'Cittadinanza',
          )));
        }),
      );
    }
    // Asilo politico - multilingua
    else if (inputLower.contains('asilo') || inputLower.contains('protezione') || inputLower.contains('rifugiato') ||
             inputLower.contains('asylum') || inputLower.contains('protection') || inputLower.contains('refugee') ||
             inputLower.contains('asilo político') || inputLower.contains('protección') || inputLower.contains('refugiado')) {
      _addBotMessage(
        l10n.translate('chatbotAsylumResponse'),
        action: _buildNavigationButton(l10n.translate('chatbotStartRequest'), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiziGateScreen(
            destinationScreen: AsiloPoliticoScreen(),
            serviceName: 'Protezione Internazionale',
          )));
        }),
      );
    }
    // 730 e tasse - multilingua
    else if (inputLower.contains('730') || inputLower.contains('tasse') || inputLower.contains('fiscal') ||
             inputLower.contains('tax') || inputLower.contains('impuestos')) {
      _addBotMessage(
        l10n.translate('chatbotTaxResponse'),
        action: _buildNavigationButton(l10n.translate('chatbotFiscalServices'), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiziGateScreen(
            destinationScreen: MediazioneFiscaleScreen(),
            serviceName: 'Servizi Fiscali',
          )));
        }),
      );
    }
    // Appuntamento - multilingua
    else if (inputLower.contains('appuntamento') || inputLower.contains('prenot') ||
             inputLower.contains('appointment') || inputLower.contains('book') ||
             inputLower.contains('cita') || inputLower.contains('reserv')) {
      _addBotMessage(
        l10n.translate('chatbotAppointmentResponse'),
        action: _buildNavigationButton(l10n.translate('chatbotBookNow'), () {
          Navigator.pushNamed(context, '/prenotaAppuntamento');
        }),
      );
    }
    // Saluti - multilingua
    else if (inputLower.contains('ciao') || inputLower.contains('buongiorno') || 
             inputLower.contains('buonasera') || inputLower.contains('hello') || 
             inputLower.contains('hi ') || inputLower.contains('hola') || inputLower.contains('buenos')) {
      _addBotMessage(l10n.translate('chatbotGreeting'));
    }
    // Grazie - multilingua
    else if (inputLower.contains('grazie') || inputLower.contains('thank') || inputLower.contains('gracias')) {
      _addBotMessage(l10n.translate('chatbotThanksResponse'));
    }
    // Default - multilingua
    else {
      _addBotMessage(
        'Capito. Per darti una risposta precisa, scegli un percorso e ti accompagno passo passo:',
        action: _buildFeatureHubButtons(),
      );
    }
  }

  Widget? _buildBackendAction(String actionKey, String actionLabel) {
    final label = actionLabel.trim().isEmpty ? 'Apri percorso' : actionLabel;

    switch (actionKey) {
      case 'open_work':
        return _buildNavigationButton(label, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const ServiziGateScreen(
                    destinationScreen: LavoroOrientamentoScreen(),
                    serviceName: 'Accesso al lavoro',
                  ),
            ),
          );
        });
      case 'open_credit':
        return _buildNavigationButton(label, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const ServiziGateScreen(
                    destinationScreen: EducazioneFinanziariaCreditoScreen(),
                    serviceName: 'Educazione finanziaria + credito',
                  ),
            ),
          );
        });
      case 'open_accounting':
        return _buildNavigationButton(label, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const ServiziGateScreen(
                    destinationScreen: SupportoContabileScreen(),
                    serviceName: 'Partita IVA e contabilita',
                  ),
            ),
          );
        });
      case 'open_welcome':
        return _buildNavigationButton(label, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const ServiziGateScreen(
                    destinationScreen: AccoglienzaScreen(),
                    serviceName: 'Vivere in Italia',
                  ),
            ),
          );
        });
      case 'open_booking':
        return _buildNavigationButton(label, () {
          Navigator.pushNamed(context, '/prenotaAppuntamento');
        });
      case 'open_hub':
        return _buildFeatureHubButtons();
      default:
        return null;
    }
  }

  Widget _buildProjectButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildQuickReplyButton('🔵 ${l10n.translate('chatbotYouthBtn')}', () {
          _addUserMessage(l10n.translate('chatbotYouthProjects'));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgettiScreen()));
        }),
        _buildQuickReplyButton('🟣 ${l10n.translate('chatbotWomenBtn')}', () {
          _addUserMessage(l10n.translate('chatbotWomenProjects'));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgettiScreen()));
        }),
        _buildQuickReplyButton('🟢 ${l10n.translate('chatbotSportBtn')}', () {
          _addUserMessage(l10n.translate('chatbotSportProjects'));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgettiScreen()));
        }),
        _buildQuickReplyButton('🟠 ${l10n.translate('chatbotMigrantsProjectBtn')}', () {
          _addUserMessage(l10n.translate('chatbotMigrantsProjects'));
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgettiScreen()));
        }),
      ],
    );
  }

  Widget _buildFeatureHubButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildQuickReplyButton('💼 Accesso al lavoro', () {
          _addUserMessage('Accesso al lavoro');
        }),
        _buildQuickReplyButton('💳 Credito e finanziamento', () {
          _addUserMessage('Microcredito e finanziamento piccole aziende');
        }),
        _buildQuickReplyButton('📒 Partita IVA e contabilita', () {
          _addUserMessage('Partita IVA e contabilita');
        }),
        _buildQuickReplyButton('🌍 Vivere in Italia', () {
          _addUserMessage('Vivere in Italia e documenti');
        }),
        _buildQuickReplyButton('📅 Prenota appuntamento', () {
          _addUserMessage('Prenota appuntamento');
        }),
      ],
    );
  }

  Widget _buildQuickReplyButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        side: const BorderSide(color: Color(0xFF2196F3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildNavigationButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward, size: 18),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('chatbotTitle')),
        actions: [
          IconButton(
            icon: Icon(_showFAQ ? Icons.chat : Icons.help_outline),
            onPressed: () {
              setState(() {
                _showFAQ = !_showFAQ;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFAQ) _buildFAQSection(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingBubble();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: ExpansionTile(
          title: Text(l10n.translate('chatbotFAQTitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
          initiallyExpanded: false,
          children: [
            _buildFAQItem(
              l10n.translate('chatbotFAQ1Question'),
              l10n.translate('chatbotFAQ1Answer'),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiziGateScreen(
                  destinationScreen: PermessoSoggiornoScreen(),
                  serviceName: 'Permesso di Soggiorno',
                )));
              },
            ),
            _buildFAQItem(
              l10n.translate('chatbotFAQ2Question'),
              l10n.translate('chatbotFAQ2Answer'),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiziGateScreen(
                  destinationScreen: MediazioneFiscaleScreen(),
                  serviceName: '730',
                )));
              },
            ),
            _buildFAQItem(
              l10n.translate('chatbotFAQ3Question'),
              l10n.translate('chatbotFAQ3Answer'),
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgettiScreen()));
              },
            ),
            _buildFAQItem(
              l10n.translate('chatbotFAQ4Question'),
              l10n.translate('chatbotFAQ4Answer'),
              () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            _buildFAQItem(
              l10n.translate('chatbotFAQ5Question'),
              l10n.translate('chatbotFAQ5Answer'),
              () {
                Navigator.pushNamed(context, '/prenotaAppuntamento');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, VoidCallback onTap) {
    return ListTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(answer, style: const TextStyle(fontSize: 13)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF2196F3)),
      onTap: onTap,
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 20),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isUser ? const Color(0xFF2196F3) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (message.action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: message.action!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate('chatbotInputHint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _addUserMessage(text.trim());
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _addUserMessage(_textController.text.trim());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 20),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Sto pensando alla soluzione migliore per te...',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Widget? action;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.action,
  });
}
