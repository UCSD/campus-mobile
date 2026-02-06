import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_history.dart';

class SideSlider extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final double width;
  final VoidCallback onNewChat;
  final void Function(String sessionId) onSelectSession;
  final List<ChatSessionMeta> sessions;
  final bool isLoggedIn;

  SideSlider({
    super.key,
    required this.isOpen,
    required this.onClose,
    this.width = 300,
    required this.onNewChat,
    required this.onSelectSession,
    required this.sessions,
    required this.isLoggedIn,
  }) {}

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final prev7 = <ChatSessionMeta>[];
    final prev30 = <ChatSessionMeta>[];
    final older = <ChatSessionMeta>[];

    for (final s in sessions) {
      final age = now.difference(s.updatedAt).inDays;
      if (age <= 7) {
        prev7.add(s);
      } else if (age <= 30) {
        prev30.add(s);
      } else {
        older.add(s);
      }
    }

    return IgnorePointer(
      ignoring: !isOpen,
      child: Stack(
        children: [
          if (isOpen)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                child: Container(color: const Color(0xFFD5D5D5).withOpacity(0.14)),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: isOpen ? 0 : -width - 24,
            width: width,
            child: Material(
              elevation: 12,
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    _header(onClose, isLoggedIn, isOpen, onNewChat, onClose),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _sectionHeader('Chats', color: Color(0xFF182B49), fontWeight: FontWeight.w700),
                          if (prev7.isNotEmpty)
                            _ChatsGroup(
                              title: 'Previous 7 Days',
                              items: prev7.map((s) => _ChatItemData(id: s.id, title: s.title)).toList(),
                              onTap: (id) {
                                onSelectSession(id);
                                onClose();
                              },
                            ),
                          if (prev30.isNotEmpty)
                            _ChatsGroup(
                              title: 'Previous 30 Days',
                              items: prev30.map((s) => _ChatItemData(id: s.id, title: s.title)).toList(),
                              onTap: (id) {
                                onSelectSession(id);
                                onClose();
                              },
                            ),
                          if (older.isNotEmpty)
                            _ChatsGroup(
                              title: 'Older',
                              items: older.map((s) => _ChatItemData(id: s.id, title: s.title)).toList(),
                              onTap: (id) {
                                onSelectSession(id);
                                onClose();
                              },
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _header(VoidCallback onClose, bool isLoggedIn, bool isSidebarOpen, VoidCallback onNewChat,
          VoidCallback onToggleSidebar) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                onNewChat();
                onClose();
              },
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/tgpt/new_chat_icon.svg',
                    width: 20,
                    height: 20,
                    color: Color(0xFF182B49),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Chat',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF6A6B6D),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (isSidebarOpen)
              IconButton(
                tooltip: 'Collapse',
                icon: isLoggedIn
                    ? SvgPicture.asset('assets/images/tgpt/unpin-sidebar.svg',
                        width: 22, height: 22, color: Color(0xFF747678))
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: const Icon(
                          Icons.login_rounded,
                          color: Color(0xFF00629B),
                          size: 26,
                        ),
                      ),
                onPressed: onToggleSidebar,
              ),
          ],
        ),
      );

  static Widget _sectionHeader(String text,
          {Widget? icon, Color color = const Color(0xFF6B7280), FontWeight fontWeight = FontWeight.w400}) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 22,
                color: color,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      );
}

class _ChatItemData {
  final String id;
  final String title;
  _ChatItemData({required this.id, required this.title});
}

class _ChatsGroup extends StatefulWidget {
  final String title;
  final List<_ChatItemData> items;
  final void Function(String id) onTap;
  const _ChatsGroup({required this.title, required this.items, required this.onTap});

  @override
  State<_ChatsGroup> createState() => _ChatsGroupState();
}

class _ChatsGroupState extends State<_ChatsGroup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 6, right: 16),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: Color(0xFF182B49),
                  size: 40,
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF182B49),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Builder(builder: (context) {
            final hasItems = widget.items.isNotEmpty;
            final shouldShowItems = _isExpanded && hasItems;
            if (!shouldShowItems) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onTap(widget.items.first.id),
                  child: Container(
                    padding: const EdgeInsets.only(left: 46, right: 16),
                    height: 24,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.items.first.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6A6B6D),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                ...widget.items.skip(1).map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity(vertical: -4),
                        contentPadding: const EdgeInsets.only(left: 46),
                        title: Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6A6B6D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => widget.onTap(t.id),
                      ),
                    )),
              ],
            );
          }),
        ],
      ],
    );
  }
}
