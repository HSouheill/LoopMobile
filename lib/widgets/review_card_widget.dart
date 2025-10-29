import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
              // User profile image
              if (showUserInfo) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: review.userProfileImage.isNotEmpty
                      ? NetworkImage('${Environment.apiUrl}assets/${review.userProfileImage}')
                      : null,
                  child: review.userProfileImage.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
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
