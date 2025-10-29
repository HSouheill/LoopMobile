import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/service_provider.dart';
import '../models/review.dart';
import '../environment.dart';
import 'review_submission_widget.dart';
import 'review_report_dialog.dart';

class ServiceProviderReviewsWidget extends StatefulWidget {
  final ServiceProviderWithReviews serviceProvider;
  final VoidCallback? onReviewSubmitted;

  const ServiceProviderReviewsWidget({
    super.key,
    required this.serviceProvider,
    this.onReviewSubmitted,
  });

  @override
  State<ServiceProviderReviewsWidget> createState() => _ServiceProviderReviewsWidgetState();
}

class _ServiceProviderReviewsWidgetState extends State<ServiceProviderReviewsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Provider's Reviews Section
        _buildReviewsSection(context),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.rate_review, color: Colors.black, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.reviews,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (widget.serviceProvider.reviews.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/all-reviews',
                    arguments: {
                      'objectId': widget.serviceProvider.id,
                      'table': 'user',
                      'objectName': widget.serviceProvider.displayName,
                    },
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.seeAllReviews(widget.serviceProvider.reviewCount),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue,
                      size: 12,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Reviews
        if (widget.serviceProvider.reviews.isEmpty)
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noReviewsAvailable,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.serviceProviderNoReviewsYet,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              // Show up to 3 reviews
              ...widget.serviceProvider.reviews.take(3).map((review) => _buildReviewCard(context, review)),
            ],
          ),
        
        // Review Submission Widget (always shown, regardless of review count)
        ReviewSubmissionWidget(
          agentId: widget.serviceProvider.id,
          onReviewSubmitted: () {
            widget.onReviewSubmitted?.call();
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: review.userProfileImage.isNotEmpty
                    ? NetworkImage('${Environment.apiUrl}assets/${review.userProfileImage}')
                    : null,
                child: review.userProfileImage.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey, size: 20)
                    : null,
              ),
              
              const SizedBox(width: 12),
              
              // Review Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name, date and rating
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                review.formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Star rating
                        _buildStarRating(review.rating),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Comment
                    Text(
                      review.comment,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Report button
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return IconButton(
                    icon: const Icon(Icons.flag, color: Colors.red, size: 18),
                    onPressed: () => _showReportDialog(context, review),
                    tooltip: l10n.reportThisReview,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, Review review) {
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
        if (index < rating) {
          return const Icon(
            Icons.star,
            color: Colors.amber,
            size: 18,
          );
        } else {
          return const Icon(
            Icons.star_border,
            color: Colors.amber,
            size: 18,
          );
        }
      }),
    );
  }
}
