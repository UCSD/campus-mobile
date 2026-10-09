import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssistantEmptyState extends StatelessWidget {
  const AssistantEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset('assets/images/tgpt/uc-san-diego-assistant.svg', width: 286),
            const SizedBox(height: 10),
            const Text(
              'This assistant has access to campus information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Brix Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9A9A9A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
