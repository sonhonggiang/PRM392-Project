import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../models/user_model.dart';

// ─── Model tin nhắn ─────────────────────────────────────────────────────────
class Message {
  final int id;
  final String text;
  final bool isSender; // true = người đang xem là người gửi
  final DateTime time;
  final String senderName;

  Message({
    required this.id,
    required this.text,
    required this.isSender,
    required this.time,
    required this.senderName,
  });
}

// ─── Màn hình chat hỗ trợ (tự động hiển thị đúng giao diện theo role) ───────
class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.currentUser.role == UserRole.admin;

    if (isAdmin) {
      return const AdminChatInboxScreen();
    }
    return const UserChatScreen();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GIAO DIỆN USER: Nhắn tin thực tế cho Admin
// ══════════════════════════════════════════════════════════════════════════════
class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  List<Message> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Tự động reload tin nhắn mỗi 5 giây để cập nhật tin nhắn mới từ Admin
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadMessages(silent: true));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    try {
      final auth = context.read<AuthProvider>();
      final myId = int.tryParse(auth.currentUser.id) ?? 0;
      final list = await ApiService.getUserMessages();
      
      final mapped = list.map((m) => Message(
        id: m['id'] ?? 0,
        text: m['message'] ?? '',
        isSender: (m['sender_id'] ?? 0) == myId,
        time: m['created_at'] != null ? DateTime.parse(m['created_at']).toLocal() : DateTime.now(),
        senderName: m['sender_name'] ?? 'Hệ thống',
      )).toList();

      if (mounted) {
        setState(() {
          _messages = mapped;
          _isLoading = false;
        });
        if (!silent) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    // Gửi tin nhắn thực lên DB
    final success = await ApiService.sendSupportMessage(text);
    if (success) {
      _loadMessages(silent: true);
      _scrollToBottom();
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(color: AppTheme.teal, shape: BoxShape.circle),
              child: const Center(child: Text('👑', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Hỗ Trợ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                Text('Trực tuyến (Realtime)', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.indigo),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('👋', style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Hãy bắt đầu cuộc trò chuyện!',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gửi tin nhắn bên dưới và Admin sẽ phản hồi bạn.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return _buildMessageBubble(msg, context);
                          },
                        ),
                ),
                _buildInputBar(),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(Message msg, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isSender) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.teal,
              child: Text('👑', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: msg.isSender ? AppTheme.indigo : AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isSender ? 16 : 4),
                  bottomRight: Radius.circular(msg.isSender ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isSender ? Colors.white : AppTheme.text,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (msg.isSender) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi của bạn...',
                filled: true,
                fillColor: AppTheme.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (val) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: AppTheme.teal, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GIAO DIỆN ADMIN: Hộp thư đến thực tế - xem tất cả tin nhắn từ DB
// ══════════════════════════════════════════════════════════════════════════════
class AdminChatInboxScreen extends StatefulWidget {
  const AdminChatInboxScreen({super.key});

  @override
  State<AdminChatInboxScreen> createState() => _AdminChatInboxScreenState();
}

class _AdminChatInboxScreenState extends State<AdminChatInboxScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  Timer? _inboxTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Tự động làm mới danh sách inbox mỗi 7 giây
    _inboxTimer = Timer.periodic(const Duration(seconds: 7), (_) => _loadConversations(silent: true));
  }

  @override
  void dispose() {
    _inboxTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    try {
      final list = await ApiService.adminGetConversations();
      if (mounted) {
        setState(() {
          _conversations = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.indigo, AppTheme.teal]),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hộp thư hỗ trợ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                Text('${_conversations.length} cuộc hội thoại thực tế', style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.indigo),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : Column(
              children: [
                // Banner chế độ admin
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A2F6E), Color(0xFF0E7A7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chế độ Admin Thực Tế', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Nhận và phản hồi các tin nhắn thực từ cơ sở dữ liệu', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách hội thoại
                Expanded(
                  child: _conversations.isEmpty
                      ? const Center(child: Text('Chưa có tin nhắn nào từ người dùng thực.', style: TextStyle(color: AppTheme.muted)))
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          color: AppTheme.teal,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conv = _conversations[index];
                              final userName = conv['display_name'] ?? conv['email'] ?? 'User';
                              final userId = conv['user_id'];
                              final lastMsgText = conv['last_message'] ?? '';
                              final lastSenderId = conv['last_sender_id'];
                              // Tin nhắn cuối không phải của admin -> cần phản hồi
                              final bool hasUnread = lastSenderId != null && lastSenderId != int.tryParse(context.read<AuthProvider>().currentUser.id);

                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminChatDetailScreen(
                                      userId: userId,
                                      userName: userName,
                                    ),
                                  ),
                                ).then((_) => _loadConversations(silent: true)),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: hasUnread ? AppTheme.teal.withValues(alpha: 0.4) : AppTheme.border),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: AppTheme.indigoLight,
                                        child: Text(
                                          userName[0].toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo, fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    lastMsgText,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: hasUnread ? AppTheme.text : AppTheme.muted,
                                                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                                if (hasUnread)
                                                  Container(
                                                    width: 8, height: 8,
                                                    margin: const EdgeInsets.only(left: 6),
                                                    decoration: const BoxDecoration(color: AppTheme.teal, shape: BoxShape.circle),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GIAO DIỆN ADMIN: Chi tiết hội thoại thực tế
// ══════════════════════════════════════════════════════════════════════════════
class AdminChatDetailScreen extends StatefulWidget {
  final dynamic userId;
  final String userName;

  const AdminChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  List<Message> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = true;
  Timer? _detailTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Tự động load tin nhắn mới từ user mỗi 4 giây
    _detailTimer = Timer.periodic(const Duration(seconds: 4), (_) => _loadMessages(silent: true));
  }

  @override
  void dispose() {
    _detailTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    try {
      final auth = context.read<AuthProvider>();
      final myId = int.tryParse(auth.currentUser.id) ?? 0;
      final list = await ApiService.adminGetConversationDetail(widget.userId);
      
      final mapped = list.map((m) => Message(
        id: m['id'] ?? 0,
        text: m['message'] ?? '',
        isSender: (m['sender_id'] ?? 0) == myId,
        time: m['created_at'] != null ? DateTime.parse(m['created_at']).toLocal() : DateTime.now(),
        senderName: m['sender_name'] ?? 'User',
      )).toList();

      if (mounted) {
        setState(() {
          _messages = mapped;
          _isLoading = false;
        });
        if (!silent) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendReply() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final success = await ApiService.adminReplyToUser(widget.userId, text);
    if (success) {
      _loadMessages(silent: true);
      _scrollToBottom();
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.indigoLight,
              child: Text(
                widget.userName[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.indigo),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                const Text('Hội thoại thực tế', style: TextStyle(fontSize: 10, color: AppTheme.muted)),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.indigo),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: msg.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!msg.isSender) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.indigoLight,
                                child: Text(widget.userName[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.indigo)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                                decoration: BoxDecoration(
                                  color: msg.isSender ? AppTheme.indigo : AppTheme.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(msg.isSender ? 16 : 4),
                                    bottomRight: Radius.circular(msg.isSender ? 4 : 16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: msg.isSender ? Colors.white : AppTheme.text,
                                    fontSize: 13, height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            if (msg.isSender) ...[
                              const SizedBox(width: 8),
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.teal,
                                child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 14),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Reply bar cho Admin
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    border: const Border(top: BorderSide(color: AppTheme.border)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, -2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: AppTheme.indigo, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Nhập phản hồi của Admin...',
                            filled: true,
                            fillColor: AppTheme.bg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (val) => _sendReply(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendReply,
                        child: Container(
                          width: 44, height: 44,
                          decoration: const BoxDecoration(color: AppTheme.indigo, shape: BoxShape.circle),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
