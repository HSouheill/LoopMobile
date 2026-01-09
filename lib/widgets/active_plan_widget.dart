import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../environment.dart';
import 'subscription_modal.dart';
import 'profile_widgets/dynamic_gradient_button.dart';

/// Reusable Active Plan Widget for all dashboards
/// Fetches subscription data from the backend API and displays it
class ActivePlanWidget extends StatefulWidget {
  const ActivePlanWidget({
    super.key,
  });

  @override
  State<ActivePlanWidget> createState() => _ActivePlanWidgetState();
}

class _ActivePlanWidgetState extends State<ActivePlanWidget> {
  Map<String, dynamic>? _subscriptionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() {
      _isLoading = true;
    });

    final data = await SubscriptionService.getMySubscription();

    setState(() {
      _subscriptionData = data;
      _isLoading = false;
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String? _getPlanImageUrl() {
    final imageFilename = _subscriptionData?['subscription']?['planId']?['image'];
    if (imageFilename != null && imageFilename.toString().isNotEmpty) {
      return '${Environment.apiUrl}assets/$imageFilename';
    }
    return null;
  }

  String _getFallbackImagePath() {
    return 'assets/basic.png';
  }

  int _getDaysRemaining() {
    final expiryDate = _subscriptionData?['subscription']?['expiryDate'];
    if (expiryDate == null) return 0;

    try {
      final expiry = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  int _getListingsLeft() {
    // First check if it's in the subscription data at root level
    if (_subscriptionData?['listingsLeft'] != null) {
      return _subscriptionData!['listingsLeft'] as int;
    }
    // Fallback to checking in planId
    final listings = _subscriptionData?['subscription']?['planId']?['listings'];
    if (listings != null) {
      return listings as int;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.88;
    final cardHeight = 140.0;

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_subscriptionData == null || _subscriptionData!['subscription'] == null) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background image on the left with curved edge clipping
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: cardWidth * 0.38,
                    child: ClipPath(
                      clipper: ImageCurvedClipper(),
                      child: Image.asset(
                        _getFallbackImagePath(),
                        fit: BoxFit.cover,
                        width: cardWidth * 0.38,
                        height: cardHeight,
                      ),
                    ),
                  ),
                  // Wavy green line separator
                  Positioned(
                    left: cardWidth * 0.38 - 2,
                    top: 0,
                    bottom: 0,
                    width: 6,
                    child: CustomPaint(
                      painter: WavyLinePainter(),
                      child: Container(),
                    ),
                  ),
                  // Blue gradient overlay on the right
                  Positioned(
                    left: cardWidth * 0.38,
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 103, 155, 218),
                            Color.fromARGB(255, 69, 100, 201),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 15, right: 10, bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.activePlan ?? "Active Plan:",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)?.noPlan ?? 'No Plan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)?.validUntil('N/A') ?? 'Valid Until: N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final subscription = _subscriptionData!['subscription'];
    final plan = subscription['planId'];
    final planName = plan?['name'] ?? 'Unknown Plan';
    final expiryDate = subscription['expiryDate'];
    final daysRemaining = _getDaysRemaining();
    final listingsLeft = _getListingsLeft();

    return Column(
      children: [
        // Active Plan Card with wavy curve design
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background image on the left with curved edge clipping
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: cardWidth * 0.38,
                  child: ClipPath(
                    clipper: ImageCurvedClipper(),
                    child: _getPlanImageUrl() != null
                        ? Image.network(
                            _getPlanImageUrl()!,
                            fit: BoxFit.cover,
                            width: cardWidth * 0.38,
                            height: cardHeight,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                _getFallbackImagePath(),
                                fit: BoxFit.cover,
                                width: cardWidth * 0.38,
                                height: cardHeight,
                              );
                            },
                          )
                        : Image.asset(
                            _getFallbackImagePath(),
                            fit: BoxFit.cover,
                            width: cardWidth * 0.38,
                            height: cardHeight,
                          ),
                  ),
                ),
                // Wavy green line separator
                Positioned(
                  left: cardWidth * 0.38 - 2,
                  top: 0,
                  bottom: 0,
                  width: 6,
                  child: CustomPaint(
                    painter: WavyLinePainter(),
                    child: Container(),
                  ),
                ),
                // Blue gradient overlay on the right
                Positioned(
                  left: cardWidth * 0.38,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 103, 155, 218),
                          Color.fromARGB(255, 69, 100, 201),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.activePlan ?? "Active Plan:",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            planName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)?.validUntil(_formatDate(expiryDate)) ?? 'Valid Until: ${_formatDate(expiryDate)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (daysRemaining > 0 || listingsLeft > 0) ...[
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (listingsLeft > 0) ...[
                                  Text(
                                    '$listingsLeft listings',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  if (daysRemaining > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 1,
                                      height: 10,
                                      color: Colors.white38,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                                if (daysRemaining > 0)
                                  Text(
                                    '$daysRemaining days remaining',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Unsubscribe button
        const SizedBox(height: 12),
        Center(
          child: DynamicGradientButton(
            buttonText: 'Unsubscribe',
            onTap: _showUnsubscribeModal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            textSize: 12.0,
            backgroundColor: Colors.red,
            useGradient: false,
          ),
        ),
      ],
    );
  }

  void _showUnsubscribeModal() {
    if (_subscriptionData == null) return;

    final subscription = _subscriptionData!['subscription'];
    final plan = subscription['planId'];
    final planName = plan?['name'] ?? 'Unknown Plan';

    SubscriptionModal.showUnsubscribeModal(
      context,
      planName: planName,
      onSuccess: () {
        // Reload subscription data
        _loadSubscription();
      },
    );
  }
}

// Custom clipper for curved edge on the right side of the image
class ImageCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    // Create wavy curve on the right edge
    double waveHeight = 12.0;
    double waveCount = 4.0;
    double segmentHeight = size.height / waveCount;

    for (int i = 0; i < waveCount.toInt(); i++) {
      double y1 = size.height - (i * segmentHeight);
      double y2 = size.height - ((i + 0.5) * segmentHeight);
      double y3 = size.height - ((i + 1) * segmentHeight);

      path.quadraticBezierTo(
        size.width + waveHeight, y2,
        size.width, y3,
      );
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom painter for the wavy line separator
class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 92, 184, 92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = Path();
    path.moveTo(size.width / 2, 0);

    double waveHeight = 8.0;
    double waveCount = 8.0;
    double segmentHeight = size.height / waveCount;

    for (int i = 0; i < waveCount.toInt(); i++) {
      double y1 = i * segmentHeight;
      double y2 = (i + 0.5) * segmentHeight;
      double y3 = (i + 1) * segmentHeight;

      path.quadraticBezierTo(
        size.width / 2 + waveHeight, y2,
        size.width / 2, y3,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
