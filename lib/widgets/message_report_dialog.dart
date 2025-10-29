import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/report_service.dart';

class MessageReportDialog extends StatefulWidget {
  final String messageId;
  final String messageContent;

  const MessageReportDialog({
    super.key,
    required this.messageId,
    required this.messageContent,
  });

  @override
  State<MessageReportDialog> createState() => _MessageReportDialogState();
}

class _MessageReportDialogState extends State<MessageReportDialog> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.pleaseSelectReasonForReporting ?? 'Please select a reason for reporting')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ReportService.reportMessage(
        messageId: widget.messageId,
        reason: _selectedReason!,
        extraDetails: _detailsController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n != null ? l10n.errorSubmittingReport(e.toString()) : 'Error submitting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reasonLabels = ReportService.getReasonLabels();
    final reasons = ReportService.getReportReasons();
    final messagePreview = widget.messageContent.length > 50 ? '${widget.messageContent.substring(0, 50)}...' : widget.messageContent;

    return AlertDialog(
      title: Text(l10n?.reportMessage ?? 'Report Message'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n != null ? l10n.reportMessagePrompt(messagePreview) : 'Report message: "$messagePreview"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.selectReasonForReporting ?? 'Please select a reason for reporting this message:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...reasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reasonLabels[reason] ?? reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                dense: true,
              );
            }).toList(),
            const SizedBox(height: 16),
            Text(
              l10n?.additionalDetailsOptional ?? 'Additional details (optional):',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: l10n?.provideAdditionalInformation ?? 'Provide additional information about why you are reporting this message...',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(l10n?.submitReport ?? 'Submit Report'),
        ),
      ],
    );
  }
}
