import 'package:flutter/material.dart';
import '../../profile/providers/profile_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  final bool isFullScreen;
  const AIAssistantScreen({super.key, this.isFullScreen = false});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  late final List<Map<String, dynamic>> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final name = ProfileProvider().profileData['name']?.toString() ?? 'Kullanıcı';
    _messages = [
      {
        'isUser': false,
        'text': 'Merhaba $name! Ben AlpamysAI, kişisel spor ve beslenme asistanınım. Bugün sana nasıl yardımcı olabilirim?',
      }
    ];
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
      });
      
      final userText = text.toLowerCase();
      _controller.clear();
      
      _scrollToBottom();
      
      // Simulate AI response delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            String reply = 'Bu kulağa çok ilginç geliyor! Bunun için bir antrenman programı oluşturabilirim.';
            if (userText.contains('diyet') || userText.contains('yemek') || userText.contains('beslenme') || userText.contains('kilo')) {
              reply = 'Hedeflediğiniz kilo için protein ağırlıklı beslenmenizi (tavuk göğsü, balık, yumurta) ve kaliteli karbonhidratlar (yulaf, esmer pirinç) tüketmenizi öneririm.';
            } else if (userText.contains('antrenman') || userText.contains('spor') || userText.contains('egzersiz')) {
              reply = 'Sizin için haftalık 3 günlük bir program öneririm: Pazartesi (Göğüs/Arka Kol), Çarşamba (Sırt/Ön Kol), Cuma (Bacak/Omuz).';
            }
            
            _messages.add({
              'isUser': false,
              'text': reply,
            });
            
            _scrollToBottom();
          });
        }
      });
    });
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header matching Messages screen style
             Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 24.0, top: 16.0, bottom: 8.0),
              child: Row(
                children: [
                  if (widget.isFullScreen) ...[
                    GestureDetector(
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
                    const SizedBox(width: 12),
                  ] else ...[
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    'ALPAMYS AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final name = ProfileProvider().profileData['name']?.toString() ?? 'Kullanıcı';
                      setState(() {
                        _messages.clear();
                        _messages.add({
                          'isUser': false,
                          'text': 'Merhaba $name! Ben AlpamysAI, kişisel spor ve beslenme asistanınım. Bugün sana nasıl yardımcı olabilirim?',
                        });
                      });
                      _scrollToBottom();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.refresh_rounded, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFF3F4F6), thickness: 1.5, height: 16),

            // Message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['isUser'] as bool;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: const CircleAvatar(
                              radius: 15,
                              backgroundColor: Color(0xFFE8F5E9),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF10B981),
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
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
                            message['text'] as String,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
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
                    // AI decoration badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text input field
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          style: const TextStyle(fontSize: 14.0, color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'AlpamysAI\'ye bir şeyler sorun...',
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
                      onTap: _sendMessage,
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
      ),
    );
  }
}
