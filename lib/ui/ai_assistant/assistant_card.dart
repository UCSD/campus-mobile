import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/ai_assistant/assistant.dart';

const cardId = 'AIAssistant';

// Card UI for launching the chatbot from dashboard or card list
// When tapped, navigates to ChatPage (assistant.dart)
class AssistantCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardsDataProvider = Provider.of<CardsDataProvider>(context);

    return Stack(
      children: [
        CardContainer(
          active: cardsDataProvider.cardStates[cardId],
          hide: () => cardsDataProvider.toggleCard(cardId),
          reload: () {
            // Add logic to refresh data if needed.
          },
          isLoading: false,
          titleText: CardTitleConstants.TITLE_MAP[cardId] ?? 'TritonGPT',
          errorText: null,
          child: () => buildCardContent(context),
        ),
      ],
    );
  }

  // Card content: shows chat icon, title, subtitle, and handles navigation to chatbot UI
  Widget buildCardContent(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.chat, color: Colors.blue),
      title: Text("Chat with TritonGPT"),
      subtitle: Text("Tap to open the TritonGPT page"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatPage()), // Navigates to chatbot UI
        );
      },
    );
  }
}
