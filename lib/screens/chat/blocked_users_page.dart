import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/blocked_user.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  List<BlockedUser> blockedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = AuthService.token;
      if (token != null) {
        final blockedList = await ChatService.getBlockedUsers(token);
        setState(() {
          blockedUsers = blockedList;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n != null ? l10n.errorLoadingBlockedUsers(e.toString()) : 'Error loading blocked users: $e')),
        );
      }
    }
  }

  Future<void> _unblockUser(BlockedUser blockedUser) async {
    try {
      final token = AuthService.token;
      if (token != null) {
        final success = await ChatService.unblockUser(token, blockedUser.blockedId);
        if (success && mounted) {
          setState(() {
            blockedUsers.removeWhere((bu) => bu.id == blockedUser.id);
          });
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n != null ? l10n.userUnblockedSuccessfully(blockedUser.blockedUser?.fullName ?? (l10n.unknownUser)) : '${blockedUser.blockedUser?.fullName ?? 'User'} unblocked successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n != null ? l10n.errorUnblockingUser(e.toString()) : 'Error unblocking user: $e')),
        );
      }
    }
  }

  void _showUnblockDialog(BlockedUser blockedUser) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.unblockUser ?? 'Unblock User'),
        content: Text(l10n != null ? l10n.unblockUserConfirm(blockedUser.blockedUser?.fullName ?? (l10n.unknownUser)) : 'Are you sure you want to unblock ${blockedUser.blockedUser?.fullName ?? 'this user'}? You will be able to send and receive messages from them again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unblockUser(blockedUser);
            },
            child: Text(l10n?.unblockUser ?? 'Unblock', style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  String _formatBlockedDate(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return l10n != null 
          ? (difference.inDays == 1 ? l10n.dayAgo(difference.inDays) : l10n.daysAgoFull(difference.inDays))
          : '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return l10n != null
          ? (difference.inHours == 1 ? l10n.hourAgo(difference.inHours) : l10n.hoursAgoFull(difference.inHours))
          : '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return l10n != null
          ? (difference.inMinutes == 1 ? l10n.minuteAgo(difference.inMinutes) : l10n.minutesAgoFull(difference.inMinutes))
          : '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return l10n?.justNow ?? 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.blockedUsers ?? 'Blocked Users',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blockedUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n?.noBlockedUsers ?? 'No blocked users',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.blockedUsersDescription ?? 'Users you block will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBlockedUsers,
                  child: ListView.builder(
                    itemCount: blockedUsers.length,
                    itemBuilder: (context, index) {
                      final blockedUser = blockedUsers[index];
                      final user = blockedUser.blockedUser;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user?.profileImage != null
                                ? NetworkImage(user!.profileImage!)
                                : null,
                            child: user?.profileImage == null
                                ? Text(user?.fullName.isNotEmpty == true 
                                    ? user!.fullName[0].toUpperCase() 
                                    : '?')
                                : null,
                          ),
                          title: Text(
                            user?.fullName ?? (l10n?.unknownUser ?? 'Unknown User'),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (blockedUser.reason != null) ...[
                                Text(
                                  '${l10n?.reason ?? 'Reason:'} ${blockedUser.reason}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                l10n != null 
                                    ? l10n.blockedAgo(_formatBlockedDate(blockedUser.blockedAt, context))
                                    : 'Blocked ${_formatBlockedDate(blockedUser.blockedAt, context)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.block_flipped, color: Colors.green),
                                onPressed: () => _showUnblockDialog(blockedUser),
                                tooltip: l10n?.unblockUser ?? 'Unblock User',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
