import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  State<HelpAndSupportPage> createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage>
    with TickerProviderStateMixin {
  List<Map<String, String>> _buildFaqs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        "title": l10n.updateContactInformation,
        "answer": l10n.resetPasswordAnswer,
      },
      {
        "title": l10n.howToListNewService,
        "answer": l10n.contactSupportAnswer,
      },
      {
        "title": l10n.canEditOrDeleteService,
        "answer": l10n.tutorialAvailableAnswer,
      },
      {
        "title": l10n.whatHappensAfterServiceRequest,
        "answer": l10n.tutorialAvailableAnswer,
      },
      {
        "title": l10n.howDoIDeleteMyAccount,
        "answer": l10n.tutorialAvailableAnswer,
      },
    ];
  }

  // Track which panels are expanded
  late List<bool> _expanded;

  // Submit ticket state
  bool _issueExpanded = false;
  String? _selectedIssue;

  List<String> _buildIssueOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.paymentProblem,
      l10n.technicalError,
      l10n.accountIssue,
      l10n.other,
    ];
  }

  @override
  void initState() {
    super.initState();
    _expanded = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final faqs = _buildFaqs(context);
    if (_expanded.length != faqs.length) {
      _expanded = List.generate(faqs.length, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// Scrollable AppBar
          SliverAppBar(
            backgroundColor: const Color.fromARGB(0, 245, 245, 245),
            elevation: 0,
            floating: true,
            pinned: false,
            snap: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF0048FF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF0048FF),
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
            title: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Container(
                  margin: const EdgeInsets.only(left: 50),
                  child: Text(
                    l10n.helpAndSupport,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),
          ),

          /// Scrollable body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FAQ section
                  Builder(
                    builder: (context) {
                      final faqs = _buildFaqs(context);
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: const Color(0xFF0048FF), width: 1),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(faqs.length, (index) {
                            return Column(
                              children: [
                                _buildRow(context, index),
                                if (index != faqs.length - 1)
                                  const Divider(
                                      height: 1, color: Color(0xFF0048FF)),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  /// Submit a ticket section
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Center(
                        child: Text(
                          l10n.submitATicket,
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.whatsYourIssueAbout,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  /// Select Issue Container
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      final issueOptions = _buildIssueOptions(context);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _issueExpanded = !_issueExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF0048FF)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedIssue ?? l10n.selectIssue,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1E1E1E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                                ],
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _issueExpanded
                                    ? Column(
                                        children: issueOptions.map((option) {
                                          return ListTile(
                                            dense: true, // reduces vertical height
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 0,
                                                    vertical:
                                                        0), // adjust as needed
                                            title: Text(
                                              option,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1E1E1E),
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _selectedIssue = option;
                                                _issueExpanded = false;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Image + Textarea in a bordered container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF0048FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Circular image placeholder with border
                        /// Circular image placeholder with border (smaller)
                        Container(
                          width: 36, // total width including border
                          height: 36, // total height including border
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0048FF),
                              width: 1.5, // thinner border
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 16, // smaller avatar
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person,
                                color: Colors.white, size: 16),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Text area (no border)
                        Expanded(
                          child: TextField(
                            maxLines: 4,
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.describeYourIssueHere,
                              hintStyle: const TextStyle(
                                color: Color(0xFF1E1E1E),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none, // removes border
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Submit button
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Center(
                        child: DynamicGradientButton(
                          buttonText: l10n.submitTicket,
                          onTap: () {
                            Navigator.pushNamed(context, '/contact-support');
                          },
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5),
                          textColor: Colors.white,
                          textSize: 15,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final faqs = _buildFaqs(context);
    final faq = faqs[index];
    final isExpanded = _expanded[index];

    return InkWell(
      onTap: () {
        setState(() {
          _expanded[index] = !isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with arrow
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq["title"]!,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0, // rotate 180°
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24,
                  ),
                ),
              ],
            ),

            // Expandable answer (ONLY this animates)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        faq["answer"]!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
