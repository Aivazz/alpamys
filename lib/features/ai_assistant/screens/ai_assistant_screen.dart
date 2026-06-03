import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../profile/providers/profile_provider.dart';
import '../services/chat_history_service.dart';
import '../services/openrouter_service.dart';

class AIAssistantScreen extends StatefulWidget {
  final bool isFullScreen;
  const AIAssistantScreen({super.key, this.isFullScreen = false});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenRouterService _openRouterService = OpenRouterService();

  List<ChatSession> _chats = [];
  ChatSession? _currentChat;
  bool _isLoadingResponse = false;

  @override
  void initState() {
    super.initState();
    _loadAllChats();
  }

  Future<void> _loadAllChats() async {
    final loaded = await ChatHistoryService.loadChats();
    setState(() {
      _chats = loaded;
      if (_chats.isNotEmpty) {
        _currentChat = _chats.first;
      } else {
        _createNewChat(shouldOpenDrawer: false);
      }
    });
    _scrollToBottom();
  }

  void _createNewChat({bool shouldOpenDrawer = false}) {
    final name = ProfileProvider().profileData['name']?.toString() ?? 'Kullanıcı';
    final newChat = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Yeni Sohbet ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      messages: [
        {
          'role': 'assistant',
          'content': 'Merhaba $name! Ben AlpamysAI, kişisel spor ve beslenme asistanınım. Bugün sana nasıl yardımcı olabilirim?',
        }
      ],
      createdAt: DateTime.now(),
    );

    setState(() {
      _chats.insert(0, newChat);
      _currentChat = newChat;
    });

    ChatHistoryService.saveChats(_chats);
    _inputController.clear();
    _scrollToBottom();

    if (shouldOpenDrawer) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoadingResponse || _currentChat == null) return;

    _inputController.clear();
    setState(() {
      _currentChat!.messages.add({
        'role': 'user',
        'content': text,
      });
      _isLoadingResponse = true;
    });
    _scrollToBottom();

    // Dynamically rename chat if it is the first real question
    if (_currentChat!.title.startsWith('Yeni Sohbet') && _currentChat!.messages.length == 2) {
      _currentChat!.title = text.length > 22 ? '${text.substring(0, 20)}...' : text;
    }

    ChatHistoryService.saveChats(_chats);

    // Call OpenRouter
    final response = await _openRouterService.getChatResponse(_currentChat!.messages);

    if (mounted) {
      setState(() {
        _currentChat!.messages.add({
          'role': 'assistant',
          'content': response,
        });
        _isLoadingResponse = false;
      });
      _scrollToBottom();
      ChatHistoryService.saveChats(_chats);
    }
  }

  void _deleteChat(ChatSession session) {
    setState(() {
      _chats.removeWhere((c) => c.id == session.id);
      if (_currentChat?.id == session.id) {
        _currentChat = _chats.isNotEmpty ? _chats.first : null;
      }
    });
    ChatHistoryService.saveChats(_chats);
    if (_currentChat == null) {
      _createNewChat();
    }
  }

  void _togglePin(ChatSession session) {
    setState(() {
      session.isPinned = !session.isPinned;
      // Re-sort chats
      _chats.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    });
    ChatHistoryService.saveChats(_chats);
  }

  void _renameChat(ChatSession session) {
    final textCtrl = TextEditingController(text: session.title);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sohbeti Yeniden Adlandır',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Yeni başlık girin...',
            hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              final newTitle = textCtrl.text.trim();
              if (newTitle.isNotEmpty) {
                setState(() {
                  session.title = newTitle;
                });
                ChatHistoryService.saveChats(_chats);
              }
              Navigator.pop(context);
            },
            child: const Text('Kaydet', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
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
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
      drawer: _buildHistoryDrawer(isDark),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(isDark),
            Divider(
              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
              thickness: 1.5,
              height: 1,
            ),
            // Messages
            Expanded(
              child: _currentChat == null || _currentChat!.messages.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildMessageList(isDark),
            ),
            // Loading Indicator
            if (_isLoadingResponse) _buildTypingIndicator(isDark),
            // Input Bar
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.menu_rounded, color: isDark ? Colors.white : Colors.black, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALPAMYS AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _currentChat?.title ?? 'Sohbet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _createNewChat(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF86AB1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: Colors.black, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Sorularınızı bekliyorum...',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: _currentChat!.messages.length,
      itemBuilder: (context, index) {
        final msg = _currentChat!.messages[index];
        final isUser = msg['role'] == 'user';
        final content = msg['content'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 14),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                    boxShadow: isDark || isUser
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: isUser ? Colors.black : (isDark ? Colors.white : Colors.black),
                      fontSize: 14.5,
                      fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDotPulse(0),
                const SizedBox(width: 4),
                _buildDotPulse(1),
                const SizedBox(width: 4),
                _buildDotPulse(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotPulse(int index) {
    return _BouncingDot(delay: Duration(milliseconds: index * 150));
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _inputController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'AlpamysAI\'ye sorun...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600, fontSize: 14.5),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.send_rounded, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF131313) : const Color(0xFFF6F8FA),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sohbetler',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_comment_rounded, color: isDark ? Colors.white70 : Colors.black87),
                    onPressed: () {
                      _createNewChat();
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  final isCurrent = _currentChat?.id == chat.id;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(
                        chat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isCurrent 
                              ? AppColors.primary 
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      leading: Icon(
                        chat.isPinned ? Icons.push_pin_rounded : Icons.chat_bubble_outline_rounded,
                        color: chat.isPinned ? AppColors.primary : (isDark ? Colors.white30 : Colors.black26),
                        size: 18,
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded, size: 18, color: isDark ? Colors.white54 : Colors.black45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) {
                          if (val == 'pin') {
                            _togglePin(chat);
                          } else if (val == 'rename') {
                            _renameChat(chat);
                          } else if (val == 'delete') {
                            _deleteChat(chat);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'pin',
                            child: Row(
                              children: [
                                Icon(Icons.push_pin_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 16),
                                const SizedBox(width: 8),
                                Text(chat.isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, color: isDark ? Colors.white70 : Colors.black87, size: 16),
                                const SizedBox(width: 8),
                                Text('Yeniden Adlandır', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                Text('Sil', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _currentChat = chat;
                        });
                        Navigator.pop(context); // Close drawer
                        _scrollToBottom();
                      },
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

// Bouncing Dot animation component
class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _ctrl.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _anim.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
