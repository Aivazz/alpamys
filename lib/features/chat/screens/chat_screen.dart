import 'package:flutter/material.dart';
import '../../profile/providers/profile_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock chat list with full message history
  late final List<Map<String, dynamic>> _chats;

  @override
  void initState() {
    super.initState();
    final name = ProfileProvider().profileData['name']?.toString() ?? 'Kullanıcı';
    _chats = [
      {
        'id': '1',
        'name': 'Coach Alex',
        'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        'lastMessage': 'Remember to hit your protein targets today.',
        'time': '10:35 AM',
        'unreadCount': 2,
        'isOnline': true,
        'messages': [
          {
            'isUser': false,
            'sender': 'Coach Alex',
            'text': 'Hi $name! How did your leg day workout go today?',
            'time': '10:30 AM',
          },
          {
            'isUser': true,
            'sender': name,
            'text': 'Hey Coach! It was tough but I completed all sets. Felt great!',
            'time': '10:32 AM',
          },
          {
            'isUser': false,
            'sender': 'Coach Alex',
            'text': 'Excellent job! Remember to hit your protein targets today.',
            'time': '10:35 AM',
          },
        ]
      },
      {
        'id': '2',
        'name': 'FitCoach Emily',
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
        'lastMessage': 'Awesome! Let\'s review your meal plan tomorrow.',
        'time': 'Yesterday',
        'unreadCount': 0,
        'isOnline': true,
        'messages': [
          {
            'isUser': false,
            'sender': 'FitCoach Emily',
            'text': 'Hi $name, how are you tracking your calories?',
            'time': 'Yesterday, 4:15 PM',
          },
          {
            'isUser': true,
            'sender': name,
            'text': 'I\'ve been using the app tracker! It\'s very convenient.',
            'time': 'Yesterday, 4:20 PM',
          },
          {
            'isUser': false,
            'sender': 'FitCoach Emily',
            'text': 'Awesome! Let\'s review your meal plan tomorrow.',
            'time': 'Yesterday, 4:22 PM',
          },
        ]
      },
      {
        'id': '3',
        'name': 'David (Gym Partner)',
        'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop&q=80',
        'lastMessage': 'Are we hitting the gym at 6 PM today?',
        'time': 'Mon',
        'unreadCount': 0,
        'isOnline': false,
        'messages': [
          {
            'isUser': false,
            'sender': 'David',
            'text': 'Are we hitting the gym at 6 PM today?',
            'time': 'Mon, 11:00 AM',
          }
        ]
      },
      {
        'id': '4',
        'name': 'Sarah (Yoga Coach)',
        'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
        'lastMessage': 'Great stretching session today!',
        'time': 'Sun',
        'unreadCount': 0,
        'isOnline': false,
        'messages': [
          {
            'isUser': false,
            'sender': 'Sarah',
            'text': 'Great stretching session today!',
            'time': 'Sun, 2:30 PM',
          }
        ]
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = _chats.where((chat) {
      return chat['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 8.0),
              child: Text(
                'MESAJLAR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Antrenör veya arkadaş ara...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Recent Chats list
            Expanded(
              child: filteredChats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            'Sohbet bulunamadı',
                            style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final unreadCount = chat['unreadCount'] as int;

                        return InkWell(
                          onTap: () {
                            // Navigate to DirectMessageScreen pushing on top of Navigator to hide bottom nav bar
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DirectMessageScreen(
                                  chat: chat,
                                  onMessageSent: (newMessage) {
                                    setState(() {
                                      chat['messages'].add(newMessage);
                                      chat['lastMessage'] = newMessage['text'];
                                      chat['time'] = 'Just now';
                                      chat['unreadCount'] = 0;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundImage: NetworkImage(chat['avatar'] as String),
                                    ),
                                    if (chat['isOnline'] as bool)
                                      Positioned(
                                        right: 1,
                                        bottom: 1,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chat['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        chat['lastMessage'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                                          color: unreadCount > 0 ? Colors.black : const Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      chat['time'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w500,
                                        color: unreadCount > 0 ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    if (unreadCount > 0) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REDESIGNED DIRECT MESSAGE SCREEN ---
class DirectMessageScreen extends StatefulWidget {
  final Map<String, dynamic> chat;
  final ValueChanged<Map<String, dynamic>> onMessageSent;

  const DirectMessageScreen({
    super.key,
    required this.chat,
    required this.onMessageSent,
  });

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _submitMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final name = ProfileProvider().profileData['name']?.toString() ?? 'Kullanıcı';
    final newMessage = {
      'isUser': true,
      'sender': name,
      'text': text,
      'time': timeStr,
    };

    widget.onMessageSent(newMessage);
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.chat['messages'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.chat['avatar'] as String),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.chat['name'] as String,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (widget.chat['isOnline'] as bool) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      widget.chat['isOnline'] as bool ? 'Çevrimiçi' : 'Çevrimdışı',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.chat['isOnline'] as bool ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFF3F4F6),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Message History
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['isUser'] as bool;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          child: Text(
                            msg['text'] as String,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            msg['time'] as String,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating Input Bar
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              child: Row(
                children: [
                  // Add button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF9CA3AF), size: 24),
                    onPressed: () {},
                  ),
                  // Text input field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _submitMessage(),
                        style: const TextStyle(fontSize: 14.0, color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Mesaj yazın...',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14.0),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                      ),
                    ),
                  ),
                  // Send button
                  GestureDetector(
                    onTap: _submitMessage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
