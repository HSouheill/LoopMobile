import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeSwitchStates();
  }

  void _initializeSwitchStates() {
    switchStates = List.generate(widget.rows.length, (index) {
      if (widget.userOptions == null) return false;
      
      final rowText = widget.rows[index]['text'] ?? '';
      
      // Map row text to user options
      switch (rowText) {
        case 'New Messages':
          return widget.userOptions!.newMessagesNotifications;
        case 'Listing Approval':
          return widget.userOptions!.listingApprovalNotifications;
        case 'Service Requests':
          return widget.userOptions!.serviceRequestsNotifications;
        case 'Promotions':
          return widget.userOptions!.promotionsNotifications;
        case 'Hide Social Links':
          return widget.userOptions!.hideSocialLinks;
        case 'Hide Contact Info':
          return widget.userOptions!.hideContactInfo;
        default:
          return false;
      }
    });
  }

  @override
  void didUpdateWidget(DynamicSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userOptions != widget.userOptions) {
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
    
    // Map row text to option name for API call
    String? optionName;
    switch (rowText) {
      case 'New Messages':
        optionName = 'newMessagesNotifications';
        break;
      case 'Listing Approval':
        optionName = 'listingApprovalNotifications';
        break;
      case 'Service Requests':
        optionName = 'serviceRequestsNotifications';
        break;
      case 'Promotions':
        optionName = 'promotionsNotifications';
        break;
      case 'Hide Social Links':
        optionName = 'hideSocialLinks';
        break;
      case 'Hide Contact Info':
        optionName = 'hideContactInfo';
        break;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update setting: ${e.toString()}'),
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
