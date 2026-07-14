import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/portfolio_service.dart';

/// Opens a portfolio video (stored asset filename) in a full-screen player dialog.
Future<void> showPortfolioVideoPlayer(
    BuildContext context, String filename) async {
  final url = PortfolioService.getVideoUrl(filename);
  if (url == null) return;

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => PortfolioVideoPlayerDialog(videoUrl: url),
  );
}

class PortfolioVideoPlayerDialog extends StatefulWidget {
  final String videoUrl;

  const PortfolioVideoPlayerDialog({super.key, required this.videoUrl});

  @override
  State<PortfolioVideoPlayerDialog> createState() =>
      _PortfolioVideoPlayerDialogState();
}

class _PortfolioVideoPlayerDialogState
    extends State<PortfolioVideoPlayerDialog> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        _controller.play();
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _error = e.toString());
      });
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Could not play video: $_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          else if (!_initialized)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else ...[
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio == 0
                  ? 16 / 9
                  : _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  // Tap anywhere on the frame to toggle play/pause.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    },
                    child: AnimatedOpacity(
                      opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(Icons.play_arrow,
                              color: Colors.white, size: 64),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color(0xFF0048FF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
