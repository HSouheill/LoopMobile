import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../models/review.dart';
import '../environment.dart';
import 'review_report_dialog.dart';

class ReviewCardWidget extends StatelessWidget {
  final Review review;
  final bool showUserInfo;

  const ReviewCardWidget({
    super.key,
    required this.review,
    this.showUserInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            children: [
              // User profile image.
              // CircleAvatar.backgroundImage has no error callback, so a failed
              // load throws uncaught (harmless red box in debug, but can crash a
              // release build on Android). Use Image.network with an errorBuilder
              // inside a ClipOval so a missing avatar falls back to the icon.
              if (showUserInfo) ...[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: Container(
                      color: Colors.grey[300],
                      child: review.userProfileImage.isNotEmpty
                          ? Image.network(
                              '${Environment.apiUrl}assets/${review.userProfileImage}',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, color: Colors.grey),
                            )
                          : const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              // User name and date
              if (showUserInfo) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        review.formattedDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    review.formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              
              // Star rating
              _buildStarRating(review.rating),
              
              // Report button
              const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return IconButton(
                    icon: const Icon(Icons.flag, color: Colors.red, size: 18),
                    onPressed: () => _showReportDialog(context),
                    tooltip: l10n.reportThisReview,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Review comment
          if (review.comment.isNotEmpty) ...[
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReviewReportDialog(
        reviewId: review.id,
        reviewerName: review.userName,
        reviewComment: review.comment,
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }
}
