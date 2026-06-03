import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSession {
  final String id;
  String title;
  final List<Map<String, String>> messages; // {'role': 'user'|'assistant', 'content': '...'}
  bool isPinned;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    this.isPinned = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        title: json['title'] as String,
        messages: (json['messages'] as List<dynamic>)
            .map((m) => Map<String, String>.from(m as Map))
            .toList(),
        isPinned: json['isPinned'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ChatHistoryService {
  static const String _storageKey = 'alpamys_ai_chats';

  // Load all chats sorted by pinned state and creation date
  static Future<List<ChatSession>> loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      final List<ChatSession> chats = decoded.map((item) => ChatSession.fromJson(item as Map<String, dynamic>)).toList();
      
      // Sort: pinned first, then newest first
      chats.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      return chats;
    } catch (_) {
      return [];
    }
  }

  // Save all chats to SharedPreferences
  static Future<void> saveChats(List<ChatSession> chats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(chats.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }
}
