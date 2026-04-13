import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/tgpt_models/chat_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssistantSidebar extends StatelessWidget {
  const AssistantSidebar({
    super.key,
    required this.isLoggedIn,
    required this.sessions,
    required this.activeSessionId,
    required this.onNewChat,
    required this.onSelectSession,
    required this.onClose,
  });

  final bool isLoggedIn;
  final List<ChatSessionMeta> sessions;
  final String? activeSessionId;
  final Future<void> Function() onNewChat;
  final Future<void> Function(String sessionId) onSelectSession;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = MediaQuery.sizeOf(context).width * 0.78;
    final DateTime cutoff = DateTime.now().subtract(const Duration(days: 7));
    final List<ChatSessionMeta> recentSessions =
        sessions.where((ChatSessionMeta session) => session.updatedAt.isAfter(cutoff)).toList();
    final List<ChatSessionMeta> olderSessions =
        sessions.where((ChatSessionMeta session) => !session.updatedAt.isAfter(cutoff)).toList();

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    splashRadius: 20,
                    icon: SvgPicture.asset(
                      'assets/images/tgpt/pin-sidebar.svg',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE1E6EE),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/images/tgpt/new_chat_icon.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'New Chat',
                        style: TextStyle(
                          fontFamily: 'Brix Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: lightPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Chats',
                style: TextStyle(
                  fontFamily: 'Brix Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: lightPrimaryColor,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: <Widget>[
                  if (isLoggedIn) ...<Widget>[
                    if (recentSessions.isNotEmpty) ...<Widget>[
                      const _SidebarSectionTitle(title: 'Previous 7 Days'),
                      ...recentSessions.map(_buildSessionRow),
                    ],
                    if (olderSessions.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      const _SidebarSectionTitle(title: 'Older'),
                      ...olderSessions.map(_buildSessionRow),
                    ],
                  ] else
                    ...sessions.map(_buildSessionRow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionRow(ChatSessionMeta session) {
    final bool isActive = session.id == activeSessionId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: InkWell(
        onTap: () => onSelectSession(session.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive ? const Color(0xFFF3F5F8) : Colors.transparent,
          ),
          child: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Brix Sans',
              fontSize: 17,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              color: isActive ? lightPrimaryColor : const Color(0xFF747678),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 16, 4),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.arrow_drop_down,
            size: 26,
            color: lightPrimaryColor,
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Brix Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: lightPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
