import 'dart:convert';

enum ActivityType {
  twoTruthsAndLie,
  wouldYouRather,
  icebreaker,
}

class ChatActivity {
  final ActivityType type;
  final String title;
  final String creatorId;
  final List<String> options; // For two truths (3 items) or would you rather (2 items)
  final int? correctIndex; // The lie index (0, 1, or 2)
  final String? prompt; // For icebreakers or WYR title
  final Map<String, dynamic> responses; // userId -> choice or answer
  final bool isCompleted;
  final double blurBoost;

  const ChatActivity({
    required this.type,
    required this.title,
    required this.creatorId,
    this.options = const [],
    this.correctIndex,
    this.prompt,
    this.responses = const {},
    this.isCompleted = false,
    this.blurBoost = 0.25,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'creatorId': creatorId,
      'options': options,
      'correctIndex': correctIndex,
      'prompt': prompt,
      'responses': responses,
      'isCompleted': isCompleted,
      'blurBoost': blurBoost,
    };
  }

  factory ChatActivity.fromMap(Map<String, dynamic> map) {
    return ChatActivity(
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.icebreaker,
      ),
      title: map['title'] as String? ?? 'Activity',
      creatorId: map['creatorId'] as String? ?? '',
      options: (map['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctIndex: map['correctIndex'] as int?,
      prompt: map['prompt'] as String?,
      responses: (map['responses'] as Map<String, dynamic>?) ?? {},
      isCompleted: map['isCompleted'] as bool? ?? false,
      blurBoost: (map['blurBoost'] as num?)?.toDouble() ?? 0.25,
    );
  }

  String encode() => '[ACTIVITY]:${jsonEncode(toMap())}';

  static bool isActivity(String content) => content.startsWith('[ACTIVITY]:');

  static ChatActivity? decode(String content) {
    if (!isActivity(content)) return null;
    try {
      final jsonStr = content.substring('[ACTIVITY]:'.length);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ChatActivity.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  ChatActivity copyWith({
    ActivityType? type,
    String? title,
    String? creatorId,
    List<String>? options,
    int? correctIndex,
    String? prompt,
    Map<String, dynamic>? responses,
    bool? isCompleted,
    double? blurBoost,
  }) {
    return ChatActivity(
      type: type ?? this.type,
      title: title ?? this.title,
      creatorId: creatorId ?? this.creatorId,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      prompt: prompt ?? this.prompt,
      responses: responses ?? this.responses,
      isCompleted: isCompleted ?? this.isCompleted,
      blurBoost: blurBoost ?? this.blurBoost,
    );
  }
}
