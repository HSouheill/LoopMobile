import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/auth_service.dart';

class DynamicSection extends StatefulWidget {
  final String title;
  final List<Map<String, String>> rows;
  final UserOptions? userOptions;
  final Function(String optionName, bool value)? onOptionChanged;

  const DynamicSection({
    super.key,
    required this.title,
    required this.rows,
    this.userOptions,
    this.onOptionChanged,
  });

  @override
  State<DynamicSection> createState() => _DynamicSectionState();
}

class _DynamicSectionState extends State<DynamicSection> {
  late List<bool> switchStates;
  bool _isUpdating = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    switchStates = List.filled(widget.rows.length, false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeSwitchStates();
      _initialized = true;
    }
  }

  void _initializeSwitchStates() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null || widget.userOptions == null) {
      return;
    }

    switchStates = List.generate(widget.rows.length, (index) {
      final rowText = widget.rows[index]['text'] ?? '';
      
      // Map row text to user options (using translations)
      if (rowText == l10n.newMessages) {
        return widget.userOptions!.newMessagesNotifications;
      } else if (rowText == l10n.listingApproval) {
        return widget.userOptions!.listingApprovalNotifications;
      } else if (rowText == l10n.serviceRequests) {
        return widget.userOptions!.serviceRequestsNotifications;
      } else if (rowText == l10n.promotions) {
        return widget.userOptions!.promotionsNotifications;
      } else if (rowText == l10n.hideSocialLinks) {
        return widget.userOptions!.hideSocialLinks;
      } else if (rowText == l10n.hideContactInfo) {
        return widget.userOptions!.hideContactInfo;
      }
      return false;
    });
  }

  @override
  void didUpdateWidget(DynamicSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userOptions != widget.userOptions || 
        oldWidget.rows != widget.rows) {
      _initializeSwitchStates();
    }
  }

  Future<void> _handleSwitchChange(int index, bool value) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      switchStates[index] = value;
    });

    final rowText = widget.rows[index]['text'] ?? '';
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    // Map row text to option name for API call (using translations)
    String? optionName;
    if (rowText == l10n.newMessages) {
      optionName = 'newMessagesNotifications';
    } else if (rowText == l10n.listingApproval) {
      optionName = 'listingApprovalNotifications';
    } else if (rowText == l10n.serviceRequests) {
      optionName = 'serviceRequestsNotifications';
    } else if (rowText == l10n.promotions) {
      optionName = 'promotionsNotifications';
    } else if (rowText == l10n.hideSocialLinks) {
      optionName = 'hideSocialLinks';
    } else if (rowText == l10n.hideContactInfo) {
      optionName = 'hideContactInfo';
    }

    if (optionName != null && widget.onOptionChanged != null) {
      try {
        await widget.onOptionChanged!(optionName, value);
      } catch (e) {
        // Revert the switch state if the API call failed
        setState(() {
          switchStates[index] = !value;
        });
        
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToUpdateSetting(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    setState(() {
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
        Column(
          children: widget.rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70, // keeps the track wide
                    child: Transform.translate(
                      offset: const Offset(-12, 0), // shift left
                      child: Transform.scale(
                        scaleX: 0.8,
                        scaleY: 0.6,
                        child: SwitchTheme(
                          data: SwitchThemeData(
                            trackOutlineColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: Switch(
                            value: switchStates[index],
                            onChanged: _isUpdating ? null : (value) {
                              _handleSwitchChange(index, value);
                            },
                            activeTrackColor: const Color(0xFF0048FF),
                            inactiveTrackColor: const Color(0xFFADADAD),
                            activeColor: const Color(0xFFFFFFFF),
                            inactiveThumbColor: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    row["text"] ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
