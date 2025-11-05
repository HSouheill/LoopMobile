import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/review_service.dart';
import '../../models/review.dart';
import '../../environment.dart';

class AllReviewsPage extends StatefulWidget {
  const AllReviewsPage({super.key});

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  List<Review> reviews = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 1;
  bool hasNextPage = false;
  bool hasPrevPage = false;
  int totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        currentPage = 1;
        reviews.clear();
      });
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await ReviewService.getMyReviews(
        page: currentPage,
        limit: 10,
      );

      setState(() {
        if (isRefresh) {
          reviews = response.reviews;
        } else {
          reviews.addAll(response.reviews);
        }
        currentPage = response.pagination.currentPage;
        totalPages = response.pagination.totalPages;
        hasNextPage = response.pagination.hasNextPage;
        hasPrevPage = response.pagination.hasPrevPage;
        totalCount = response.pagination.totalCount;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (hasNextPage && !isLoading) {
      setState(() {
        currentPage++;
      });
      await _loadReviews();
    }
  }

  Future<void> _refreshData() async {
    await _loadReviews(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Container(
            padding: const EdgeInsets.only(top: 15, left: 50),
            child: Text(
              l10n.myReviews,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF82A6FF),
                  Color(0xFF487CFF),
                  Color(0xFF3770FF),
                  Color(0xFF0048FF),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.only(top: 15),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF0048FF), width: 1),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF0048FF),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          titleSpacing: 0,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            if (totalCount > 0)
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.totalReviews(totalCount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
            Expanded(
              child: _buildReviewsList(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(AppLocalizations l10n) {
    if (isLoading && reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError && reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingReviews,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.reviews_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noReviewsYet,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reviewsWillAppearHere,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length + (hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == reviews.length) {
          // Load more indicator
          if (hasNextPage) {
            _loadNextPage();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        }

        final review = reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0048FF), width: 1),
                ),
                child: ClipOval(
                  child: review.userProfileImage.isNotEmpty
                      ? Image.network(
                          '${Environment.apiUrl}assets/${review.userProfileImage}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Color(0xFF0048FF),
                            );
                          },
                        )
                      : const Icon(
                          Icons.person,
                          color: Color(0xFF0048FF),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // User info and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStars(review.rating.toDouble()),
                  ],
                ),
              ),
              // Date
              Text(
                review.formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E1E1E),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    final int full = rating.floor();
    final bool hasHalf = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (i == full && hasHalf) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }
}
