class DrobotTurn {
  const DrobotTurn({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, String> toJson() => <String, String>{
        'role': role,
        'content': content,
      };
}

class DrobotReply {
  const DrobotReply({
    required this.text,
    required this.source,
    this.suggestions = const <String>[],
  });

  final String text;
  final String source;
  final List<String> suggestions;
}
