import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/drobot_config.dart';
import '../core/theme.dart';
import '../data/drobot_knowledge.dart';
import '../models/drobot_models.dart';
import '../services/drobot_service.dart';

void showDrobotAssistant(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const FractionallySizedBox(
      heightFactor: .95,
      child: DrobotAssistantSheet(),
    ),
  );
}

class DrobotAssistantSheet extends StatefulWidget {
  const DrobotAssistantSheet({super.key});

  @override
  State<DrobotAssistantSheet> createState() => _DrobotAssistantSheetState();
}

class _DrobotAssistantSheetState extends State<DrobotAssistantSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DrobotService _service = DrobotService();

  final List<_DrobotMessage> _messages = <_DrobotMessage>[
    const _DrobotMessage(
      fromUser: false,
      text: 'Bonjour 👋 Je suis Drobot, ton copilote expert. Donne-moi une surface, un objectif, un drone ou un problème : je peux construire une méthode complète, faire des estimations, proposer une checklist et expliquer les contrôles qualité.\n\nExemple : « Planifie une mission photogrammétrique de 50 ha à 100 m ».',
      source: 'Drobot • Expert embarqué',
    ),
  ];

  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _isThinking) return;

    final history = _messages
        .where((message) => message.text.trim().isNotEmpty)
        .map(
          (message) => DrobotTurn(
            role: message.fromUser ? 'user' : 'assistant',
            content: message.text,
          ),
        )
        .toList();

    setState(() {
      _messages.add(_DrobotMessage(fromUser: true, text: text));
      _controller.clear();
      _isThinking = true;
    });
    _scrollToBottom();

    final reply = await _service.answer(question: text, history: history);
    if (!mounted) return;

    setState(() {
      _messages.add(
        _DrobotMessage(
          fromUser: false,
          text: reply.text,
          source: reply.source,
          suggestions: reply.suggestions,
        ),
      );
      _isThinking = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _clearConversation() {
    setState(() {
      _messages
        ..clear()
        ..add(
          const _DrobotMessage(
            fromUser: false,
            text: 'Nouvelle conversation ouverte. Décris ta mission, ton matériel, ta zone ou ton problème technique.',
            source: 'Drobot',
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            const SizedBox(height: 9),
            Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.15),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            _Header(onClear: _clearConversation),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isThinking && index == _messages.length) {
                    return const _ThinkingBubble();
                  }
                  final message = _messages[index];
                  return _MessageBubble(
                    message: message,
                    onSuggestion: _send,
                  );
                },
              ),
            ),
            if (_messages.length <= 2)
              SizedBox(
                height: 43,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: drobotQuickSuggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ActionChip(
                    avatar: Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: dark ? cyan : const Color(0xFF006B61),
                    ),
                    backgroundColor:
                        dark ? const Color(0xFF13283A) : const Color(0xFFE7F4F7),
                    disabledColor:
                        dark ? const Color(0xFF182633) : const Color(0xFFF0F3F5),
                    surfaceTintColor: Colors.transparent,
                    side: BorderSide(
                      color: dark
                          ? Colors.white.withOpacity(.13)
                          : const Color(0xFFB8D2D9),
                    ),
                    labelStyle: TextStyle(
                      color: dark ? scheme.onSurface : const Color(0xFF102A43),
                      fontWeight: FontWeight.w800,
                    ),
                    label: Text(drobotQuickSuggestions[index]),
                    onPressed: () => _send(drobotQuickSuggestions[index]),
                  ),
                ),
              ),
            _Composer(
              controller: _controller,
              enabled: !_isThinking,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 6, 11),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[cyan, Color(0xFF39E5D0)]),
              borderRadius: BorderRadius.circular(17),
              boxShadow: <BoxShadow>[
                BoxShadow(color: cyan.withOpacity(.22), blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.smart_toy_rounded, color: navy, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Drobot',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -.4),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: success),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        DrobotConfig.onlineEnabled
                            ? 'IA en ligne + expertise hors ligne'
                            : 'Drone • SIG • capteurs • IA • hors ligne',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: success, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Nouvelle conversation',
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Fermer',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final Future<void> Function([String?]) onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: enabled ? (_) => onSend() : null,
              decoration: const InputDecoration(
                hintText: 'Ex. Calcule le GSD avec altitude 100 m…',
                prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
              ),
            ),
          ),
          const SizedBox(width: 9),
          IconButton.filled(
            tooltip: 'Envoyer',
            onPressed: enabled ? () => onSend() : null,
            icon: const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(
              backgroundColor: cyan,
              foregroundColor: navy,
              minimumSize: const Size(52, 52),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrobotMessage {
  const _DrobotMessage({
    required this.fromUser,
    required this.text,
    this.source,
    this.suggestions = const <String>[],
  });

  final bool fromUser;
  final String text;
  final String? source;
  final List<String> suggestions;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onSuggestion});

  final _DrobotMessage message;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: message.fromUser ? cyan : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(19),
            topRight: const Radius.circular(19),
            bottomLeft: Radius.circular(message.fromUser ? 19 : 5),
            bottomRight: Radius.circular(message.fromUser ? 5 : 19),
          ),
          border: message.fromUser ? null : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormattedMessage(
              text: message.text,
              color: message.fromUser ? navy : Theme.of(context).colorScheme.onSurface,
              bold: message.fromUser,
            ),
            if (!message.fromUser && message.source != null) ...[
              const SizedBox(height: 11),
              Row(
                children: [
                  Icon(Icons.verified_rounded, size: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      message.source!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copier la réponse',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Réponse copiée.')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 17),
                  ),
                ],
              ),
            ],
            if (!message.fromUser && message.suggestions.isNotEmpty) ...[
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: message.suggestions
                    .take(3)
                    .map(
                      (suggestion) => ActionChip(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: dark
                            ? const Color(0xFF152B3D)
                            : const Color(0xFFE8F3F8),
                        disabledColor: dark
                            ? const Color(0xFF182633)
                            : const Color(0xFFF0F3F5),
                        surfaceTintColor: Colors.transparent,
                        side: BorderSide(
                          color: dark
                              ? Colors.white.withOpacity(.13)
                              : const Color(0xFFBCD0DA),
                        ),
                        labelStyle: TextStyle(
                          color: dark ? scheme.onSurface : const Color(0xFF102A43),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        label: Text(suggestion),
                        onPressed: () => onSuggestion(suggestion),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormattedMessage extends StatelessWidget {
  const _FormattedMessage({required this.text, required this.color, required this.bold});

  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (lines[i].isNotEmpty)
            Text(
              lines[i].replaceAll('**', '').replaceAll('`', ''),
              style: TextStyle(
                color: color,
                height: 1.46,
                fontWeight: bold || lines[i].startsWith('**') ? FontWeight.w800 : FontWeight.w500,
                fontSize: lines[i].startsWith('**') ? 16 : 14,
              ),
            )
          else
            const SizedBox(height: 7),
        ],
      ],
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2.2)),
            SizedBox(width: 10),
            Text('Drobot analyse la question…', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
