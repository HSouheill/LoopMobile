import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class InsuranceCardWidget extends StatelessWidget {
  const InsuranceCardWidget({super.key});

  static final Uri _insuranceChatUri =
      Uri.parse('https://sib-wa-click-tracker.oqiwsier.workers.dev/w/loop');

  static const LinearGradient _brandGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 103, 155, 218),
      Color.fromARGB(255, 69, 100, 201),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<void> _openInsuranceChat(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final launched = await launchUrl(
        _insuranceChatUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n?.couldNotOpenWhatsApp ?? 'Could not open WhatsApp'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.errorOpeningWhatsApp(e.toString()) ?? 'Error opening WhatsApp: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Shield watermark sitting behind the text.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Icon(
                  Icons.verified_user,
                  size: 64,
                  color: const Color.fromARGB(255, 69, 100, 201).withValues(alpha: 0.13),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.insuranceCardTitle ?? 'Insurance',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n?.insuranceCardDescription ??
                            'Questions about insurance? Chat with our team on WhatsApp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _openInsuranceChat(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 9.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: _brandGradient,
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n?.insuranceCardButton ?? 'Ask',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
