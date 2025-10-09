import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/social_links_service.dart';

class SocialLinksDisplayWidget extends StatelessWidget {
  final List<dynamic> socialLinks;
  final VoidCallback? onRefresh;

  const SocialLinksDisplayWidget({
    Key? key,
    required this.socialLinks,
    this.onRefresh,
  }) : super(key: key);

  Future<void> _deleteSocialLink(BuildContext context, String linkId, String linkName) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Social Link'),
          content: Text('Are you sure you want to delete "$linkName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await SocialLinksService.deleteSocialLink(linkId);
        if (onRefresh != null) {
          onRefresh!();
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Social link deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting social link: $e')),
          );
        }
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: socialLinks.map<Widget>((link) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 255, 255, 255),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0048FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.link,
                color: Color(0xFF0048FF),
                size: 20,
              ),
            ),
            title: Text(
              link['name'] ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              link['link'] ?? '',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  onPressed: () => _launchUrl(link['link']),
                  tooltip: 'Open link',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _deleteSocialLink(context, link['_id'], link['name']),
                  tooltip: 'Delete link',
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
