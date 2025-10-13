import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.chat),
        backgroundColor: const Color.fromARGB(255, 27, 55, 147),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Color.fromARGB(255, 27, 55, 147),
            ),
            SizedBox(height: 16),
            Text(
              'Chat feature coming soon!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 27, 55, 147),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Stay tuned for updates',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
