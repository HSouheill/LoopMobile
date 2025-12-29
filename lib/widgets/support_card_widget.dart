import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportCardWidget extends StatelessWidget {
  const SupportCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 255, 255, 255),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(0, 238, 238, 238),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile background image
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 103, 155, 218),
                  Color.fromARGB(255, 69, 100, 201),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Lottie.asset(
                      'assets/call-center.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse('https://iconscout.com/lottie-animations/call-center');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: const Text(
                            'Call Center',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 6,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          ' by ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse('https://iconscout.com/contributors/israfil-hossain-anik');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: const Text(
                            'Israfil Hossain',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 6,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppLocalizations.of(context)?.supportCardDescription ?? 'Facing Legal Issues Or Other Concerns Related To Your Property? Our Expert Support Team Is Just A Message Away Ready To Assist You',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/contact-support');
            },
            child: Container(
              width: 250,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 103, 155, 218),
                    Color.fromARGB(255, 69, 100, 201),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50.0),
                boxShadow: [], // Removes the shadows
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)?.contactSupport ?? 'Contact Support',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }
}
