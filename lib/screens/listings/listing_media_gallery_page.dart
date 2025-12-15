import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class ListingMediaGalleryPage extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  final String? title;

  const ListingMediaGalleryPage({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
    this.title,
  });

  @override
  State<ListingMediaGalleryPage> createState() => _ListingMediaGalleryPageState();
}

class _ListingMediaGalleryPageState extends State<ListingMediaGalleryPage> {
  late final PageController _pageController;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoHasError = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.mediaUrls.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.mediaUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _loadVideoIfNeeded(_currentIndex);
  }

  bool _isVideoUrl(String url) {
    const extensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    return extensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _loadVideoIfNeeded(int index) {
    if (widget.mediaUrls.isEmpty || index >= widget.mediaUrls.length) return;
    final mediaUrl = widget.mediaUrls[index];
    if (!_isVideoUrl(mediaUrl)) {
      _disposeVideo();
      return;
    }
    _initializeVideoPlayer(mediaUrl);
  }

  void _initializeVideoPlayer(String videoUrl) {
    _disposeVideo();

    setState(() {
      _isVideoInitialized = false;
      _videoHasError = false;
    });

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isVideoInitialized = true;
          _videoHasError = false;
        });
        _videoController!
          ..setLooping(true)
          ..play();
      }).catchError((_) {
        if (!mounted) return;
        setState(() {
          _isVideoInitialized = false;
          _videoHasError = true;
        });
      });
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _videoHasError = false;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _loadVideoIfNeeded(index);
  }

  @override
  void dispose() {
    _disposeVideo();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleText = widget.title ?? l10n?.gallery ?? 'Gallery';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          titleText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.mediaUrls.length,
            itemBuilder: (context, index) {
              final mediaUrl = widget.mediaUrls[index];
              final isVideo = _isVideoUrl(mediaUrl);

              if (isVideo) {
                if (_currentIndex == index) {
                  if (_videoHasError) {
                    return const Center(
                      child: Icon(Icons.error_outline, color: Colors.white, size: 48),
                    );
                  }
                  if (_isVideoInitialized && _videoController != null) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          ),
                          if (!_videoController!.value.isPlaying)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else {
                  return const Center(
                    child: Icon(Icons.videocam, color: Colors.white, size: 64),
                  );
                }
              }

              return Center(
                child: InteractiveViewer(
                  child: Image.network(
                    mediaUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, color: Colors.white, size: 48),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (widget.mediaUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.mediaUrls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

