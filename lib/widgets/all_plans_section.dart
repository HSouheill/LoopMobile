import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../environment.dart';
import 'profile_widgets/dynamic_gradient_button.dart';
import 'subscription_modal.dart';

/// All Plans Section with pagination and show/hide functionality
class AllPlansSection extends StatefulWidget {
  final VoidCallback? onSubscriptionChanged;

  const AllPlansSection({
    super.key,
    this.onSubscriptionChanged,
  });

  @override
  State<AllPlansSection> createState() => _AllPlansSectionState();
}

class _AllPlansSectionState extends State<AllPlansSection> {
  List<dynamic> _plans = [];
  bool _isLoading = false;
  bool _isVisible = false;
  int _currentPage = 0;
  final int _plansPerPage = 3;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
    });

    final plans = await SubscriptionService.getAllPlans();

    setState(() {
      _plans = plans ?? [];
      _isLoading = false;
    });
  }

  void _toggleVisibility() async {
    if (!_isVisible && _plans.isEmpty) {
      await _loadPlans();
    }
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _nextPage() {
    if ((_currentPage + 1) * _plansPerPage < _plans.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  List<dynamic> _getCurrentPagePlans() {
    final startIndex = _currentPage * _plansPerPage;
    final endIndex = (startIndex + _plansPerPage).clamp(0, _plans.length);
    return _plans.sublist(startIndex, endIndex);
  }

  String? _getPlanImageUrl(dynamic plan) {
    final imageFilename = plan['image'];
    if (imageFilename != null && imageFilename.toString().isNotEmpty) {
      return '${Environment.apiUrl}assets/$imageFilename';
    }
    return null;
  }

  String _getFallbackImagePath() {
    return 'assets/basic.png';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Toggle button
        Center(
          child: DynamicGradientButton(
            buttonText: _isVisible ? 'Hide Plans' : 'Show All Plans',
            onTap: _toggleVisibility,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textSize: 13.0,
          ),
        ),

        const SizedBox(height: 16),

        // Plans section
        if (_isVisible) ...[
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_plans.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No plans available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else ...[
            // Plans list
            ..._getCurrentPagePlans().map((plan) => _buildPlanCard(plan, screenWidth)),

            const SizedBox(height: 16),

            // Pagination controls
            if (_plans.length > _plansPerPage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentPage > 0 ? _previousPage : null,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(AppLocalizations.of(context)?.previous ?? 'Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 69, 100, 201),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Page ${_currentPage + 1} of ${(_plans.length / _plansPerPage).ceil()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: (_currentPage + 1) * _plansPerPage < _plans.length
                          ? _nextPage
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(AppLocalizations.of(context)?.next ?? 'Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 69, 100, 201),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ],
      ],
    );
  }

  Widget _buildPlanCard(dynamic plan, double screenWidth) {
    final cardWidth = screenWidth * 0.88;
    final cardHeight = 140.0;

    return GestureDetector(
      onTap: () {
        _showSubscribeModal(plan);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                clipper: _ImageCurvedClipper(),
                child: _getPlanImageUrl(plan) != null
                    ? Image.network(
                        _getPlanImageUrl(plan)!,
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
                painter: _WavyLinePainter(),
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
                  padding: const EdgeInsets.only(left: 20, top: 12, right: 10, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        plan['name'] ?? 'Unknown Plan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (plan['description'] != null && plan['description'].toString().isNotEmpty)
                        Text(
                          plan['description'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPlanStat(Icons.list_alt_sharp, '${plan['listings'] ?? 0}', 'Listings'),
                          _buildPlanStat(Icons.calendar_month_outlined, '${plan['length'] ?? 0}', 'Days'),
                          _buildPlanStat(Icons.currency_exchange, '\$${plan['price'] ?? 0}', ''),
                        ],
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
    );
  }

  void _showSubscribeModal(dynamic plan) {
    final planId = plan['_id'] ?? plan['id'];
    if (planId == null) return;

    SubscriptionModal.showSubscribeModal(
      context,
      planId: planId.toString(),
      planName: plan['name'] ?? 'Unknown Plan',
      planPrice: '\$${plan['price'] ?? 0}',
      onSuccess: () {
        // Reload plans to reflect changes
        _loadPlans();
        // Notify parent to refresh active plan widget
        if (widget.onSubscriptionChanged != null) {
          widget.onSubscriptionChanged!();
        }
      },
    );
  }

  Widget _buildPlanStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// Custom clipper for curved edge on the right side of the image
class _ImageCurvedClipper extends CustomClipper<Path> {
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
class _WavyLinePainter extends CustomPainter {
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
