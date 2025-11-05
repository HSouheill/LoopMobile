import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../../services/social_links_service.dart';

class AddSocialAccountWidget extends StatelessWidget {
  final Function(String name, String url)? onSubmit;
  final VoidCallback? onRefresh;

  const AddSocialAccountWidget({Key? key, this.onSubmit, this.onRefresh}) : super(key: key);

  static const List<String> popularSocialAccounts = [
    'facebook',
    'instagram',
    'twitter',
    'linkedin',
    'youtube',
    'tiktok',
    'snapchat',
    'pinterest',
    'reddit',
    'discord',
    'telegram',
    'whatsapp',
  ];

  void _showAddSocialDialog(BuildContext context) {
    String? selectedSocialAccount;
    final TextEditingController urlController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSocialAccount,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.exampleFacebook ?? 'select social account',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0048FF)),
                      ),
                    ),
                    items: popularSocialAccounts.map((account) {
                      return DropdownMenuItem<String>(
                        value: account,
                        child: Text(account),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedSocialAccount = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.addSocialAccountUrlHint ?? 'add social account URL',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0048FF)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return DynamicGradientButton(
                    buttonText: isLoading ? (l10n?.adding ?? 'Adding...') : 'Submit',
                    onTap: isLoading ? null : () async {
                      final name = selectedSocialAccount;
                      final url = urlController.text.trim();
                      
                      if (name == null || name.isEmpty || url.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n?.pleaseFillAllFields ?? 'Please fill in all fields')),
                        );
                        return;
                      }

                      // Basic URL validation
                      if (!url.startsWith('http://') && !url.startsWith('https://')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n?.urlMustStartWithHttp ?? 'URL must start with http:// or https://')),
                        );
                        return;
                      }

                      try {
                        setState(() {
                          isLoading = true;
                        });
                        await SocialLinksService.addSocialLink(name, url);
                        if (onRefresh != null) {
                          onRefresh!();
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n?.socialLinkAddedSuccessfully ?? 'Social link added successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n?.errorAddingSocialLink(e.toString()) ?? 'Error adding social link: $e')),
                          );
                        }
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    useGradient: true,
                    textColor: const Color(0xFFFFFFFF),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showAddSocialDialog(context),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5F5F5), // background color
                    border: Border.all(
                      color: const Color(0xFF0048FF), // border color
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(1),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF0048FF),
                    size: 14, // icon color
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.addSocialAccountUrl ?? 'Add Social Account URL',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
