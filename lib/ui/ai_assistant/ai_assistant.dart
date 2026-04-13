import 'package:campus_mobile_experimental/core/providers/chat_provider.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/ai_assistant_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AIAssistantTab extends StatelessWidget {
  const AIAssistantTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (BuildContext providerContext) {
        final ChatProvider chatProvider = ChatProvider(providerContext.read<UserDataProvider>());
        chatProvider.initialize();
        return chatProvider;
      },
      child: const AIAssistantView(),
    );
  }
}
