import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MarketUpdate {
  final String title;
  final String time;

  MarketUpdate({required this.title, required this.time});
}

class LatestUpdatesWidget extends StatefulWidget {
  final List<MarketUpdate> updates;
  final double animationSpeed;

  const LatestUpdatesWidget({
    super.key, 
    required this.updates,
    this.animationSpeed = 50.0, // pixels per second
  });

  @override
  _LatestUpdatesWidgetState createState() => _LatestUpdatesWidgetState();
}

class _LatestUpdatesWidgetState extends State<LatestUpdatesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Create animation controller that runs indefinitely
    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // This will be adjusted dynamically
      vsync: this,
    );

    _startScrolling();
  }

  void _startScrolling() {
    // Wait for the widget to build and calculate the scroll extent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (maxScrollExtent <= 0) return;

      // Calculate duration based on scroll extent and desired speed
      final duration = Duration(
        milliseconds: (maxScrollExtent / widget.animationSpeed * 1000).round(),
      );
      
      _animationController.duration = duration;
      
      _animation = Tween<double>(
        begin: 0.0,
        end: maxScrollExtent,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ));

      _animation.addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_animation.value);
        }
      });

      _animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Reset to beginning and start again
          _scrollController.jumpTo(0.0);
          _animationController.reset();
          _animationController.forward();
        }
      });

      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildUpdateCard(MarketUpdate update) {
    return Container(
      margin: const EdgeInsets.only(right: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
        // Keeping transparent background as in original
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  update.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                update.time,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate the updates list to create seamless looping
    final duplicatedUpdates = [...widget.updates, ...widget.updates];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)?.latestMarketUpdates ?? 'Latest Market Updates',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 100.0,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(), // Disable manual scrolling
            itemCount: duplicatedUpdates.length,
            itemBuilder: (context, index) {
              return _buildUpdateCard(duplicatedUpdates[index]);
            },
          ),
        ),
      ],
    );
  }
}