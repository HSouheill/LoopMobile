import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

// Brand palette (matches splash + dashboards).
const Color _kNavy = Color(0xFF0B1929); // deep navy
const Color _kAccent = Colors.blue; // brand blue

bool _isVideoUrl(String url) {
  const extensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
  return extensions.any((ext) => url.toLowerCase().endsWith(ext));
}

/// Theme-styled media gallery for listing images and videos.
///
/// Opened when a user taps an image/video on the single listing page. Presents
/// an editorial masonry mosaic of the listing media; tapping any tile drops
/// into an immersive full-screen viewer (pinch-zoom + video + filmstrip).
class ListingMediaGalleryPage extends StatelessWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  final String? title;

  const ListingMediaGalleryPage({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
    this.title,
  });

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImmersiveMediaViewer(
          mediaUrls: mediaUrls,
          initialIndex: index,
          title: title,
        ),
      ),
    );
  }

  /// Repeating heights that give tiles a varied "mosaic" rhythm. Each media
  /// item picks its height by `index % _heights.length`, alternating tall/short
  /// so the two masonry columns interlock like the reference design. Index 3 is
  /// a full-width feature tile (see [build]).
  static const List<double> _heights = [230, 150, 150, 200, 175, 190];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleText = title ?? l10n?.gallery ?? 'Gallery';
    final photoCount = mediaUrls.where((u) => !_isVideoUrl(u)).length;
    final videoCount = mediaUrls.length - photoCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Airy header, styled like the reference "New Arrivals / See All".
          SliverAppBar(
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            backgroundColor:
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: _kNavy),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _kNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(photoCount, videoCount),
                  style: TextStyle(
                    color: _kNavy.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Masonry mosaic of media tiles.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            sliver: SliverToBoxAdapter(child: _buildMosaic(context)),
          ),
        ],
      ),
    );
  }

  /// Two-column masonry. Even indices go to the left column, odd to the right,
  /// each tile taking a height from [_heights] so the columns interlock. Every
  /// 6th item (index % 6 == 3) becomes a full-width feature row for rhythm.
  Widget _buildMosaic(BuildContext context) {
    const gutter = 12.0;
    final left = <Widget>[];
    final right = <Widget>[];
    var toLeft = true; // track column balance for non-feature tiles

    final children = <Widget>[];

    void flushColumns() {
      if (left.isEmpty && right.isEmpty) return;
      children.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: List.of(left))),
          const SizedBox(width: gutter),
          Expanded(child: Column(children: List.of(right))),
        ],
      ));
      left.clear();
      right.clear();
      toLeft = true;
    }

    for (var index = 0; index < mediaUrls.length; index++) {
      final height = _heights[index % _heights.length];

      // Full-width feature tile breaks the two columns.
      if (index % _heights.length == 3) {
        flushColumns();
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: gutter),
          child: _MosaicTile(
            url: mediaUrls[index],
            index: index,
            height: 200,
            onTap: () => _openViewer(context, index),
          ),
        ));
        continue;
      }

      final tile = Padding(
        padding: const EdgeInsets.only(bottom: gutter),
        child: _MosaicTile(
          url: mediaUrls[index],
          index: index,
          height: height,
          onTap: () => _openViewer(context, index),
        ),
      );
      (toLeft ? left : right).add(tile);
      toLeft = !toLeft;
    }

    flushColumns();
    return Column(children: children);
  }

  String _subtitle(int photos, int videos) {
    final parts = <String>[];
    if (photos > 0) parts.add('$photos ${photos == 1 ? 'photo' : 'photos'}');
    if (videos > 0) parts.add('$videos ${videos == 1 ? 'video' : 'videos'}');
    return parts.isEmpty ? '' : parts.join('  •  ');
  }
}

/// A single rounded media tile in the mosaic with a soft label pill.
class _MosaicTile extends StatelessWidget {
  final String url;
  final int index;
  final double height;
  final VoidCallback onTap;

  const _MosaicTile({
    required this.url,
    required this.index,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideoUrl(url);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
          fit: StackFit.expand,
          children: [
            // Media
            if (isVideo)
              Container(
                color: _kNavy,
                alignment: Alignment.center,
                child: const Icon(Icons.movie_creation_outlined,
                    color: Colors.white24, size: 40),
              )
            else
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFEDF1F5),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _kAccent),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFEDF1F5),
                  child: const Icon(Icons.broken_image_outlined,
                      color: Colors.black26, size: 32),
                ),
              ),

            // Watermark over image tiles (fills the tile).
            if (!isVideo)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.35,
                    child: Image(
                      image: AssetImage('assets/Watermark.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Play badge for video tiles.
            if (isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

// =============================================================================
// Immersive full-screen viewer (opened from a mosaic tile)
// =============================================================================

class _ImmersiveMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  final String? title;

  const _ImmersiveMediaViewer({
    required this.mediaUrls,
    required this.initialIndex,
    this.title,
  });

  @override
  State<_ImmersiveMediaViewer> createState() => _ImmersiveMediaViewerState();
}

class _ImmersiveMediaViewerState extends State<_ImmersiveMediaViewer> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _chromeVisible = true;

  VideoPlayerController? _videoController;
  String? _loadedVideoUrl; // guards against re-initializing the same video
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

  void _loadVideoIfNeeded(int index) {
    if (widget.mediaUrls.isEmpty || index >= widget.mediaUrls.length) return;
    final mediaUrl = widget.mediaUrls[index];
    if (!_isVideoUrl(mediaUrl)) {
      _disposeVideo();
      return;
    }
    // Already loaded this exact video (e.g. paged away and back) — reuse it
    // instead of tearing down and re-downloading, which is the main lag source.
    if (mediaUrl == _loadedVideoUrl && _videoController != null) {
      _videoController!.play();
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

    _loadedVideoUrl = videoUrl;
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoController = controller;
    controller.initialize().then((_) {
      if (!mounted || _videoController != controller) return;
      controller
        ..setLooping(true)
        ..play();
      setState(() {
        _isVideoInitialized = true;
        _videoHasError = false;
      });
    }).catchError((_) {
      if (!mounted || _videoController != controller) return;
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
    _loadedVideoUrl = null;
    _isVideoInitialized = false;
    _videoHasError = false;
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _loadVideoIfNeeded(index);
  }

  void _jumpTo(int index) {
    if (index == _currentIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _toggleChrome() => setState(() => _chromeVisible = !_chromeVisible);

  void _toggleVideoPlayback() {
    final controller = _videoController;
    if (controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  void dispose() {
    _disposeVideo();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.mediaUrls.length;

    return Scaffold(
      backgroundColor: _kNavy,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _toggleChrome,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 300) {
                  Navigator.of(context).maybePop();
                }
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: total,
                itemBuilder: (context, index) {
                  final mediaUrl = widget.mediaUrls[index];
                  return _isVideoUrl(mediaUrl)
                      ? _buildVideoItem(mediaUrl, index)
                      : _buildImageItem(mediaUrl);
                },
              ),
            ),
            _buildTopChrome(total),
            if (total > 1) _buildThumbnailStrip(total),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String mediaUrl) {
    // Size the stack to the image's rendered bounds so the watermark overlays
    // only the photo (not the surrounding black page). We do this by sharing
    // the same BoxFit.contain for both the photo and the watermark inside an
    // intrinsically-sized stack.
    return Center(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.network(
              mediaUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(color: _kAccent),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 120,
                height: 120,
                child: Icon(Icons.broken_image_outlined,
                    color: Colors.white38, size: 56),
              ),
            ),
            // Watermark constrained to the photo's painted bounds.
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(
                    'assets/Watermark.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItem(String mediaUrl, int index) {
    if (_currentIndex != index) {
      return const Center(
        child: Icon(Icons.play_circle_outline, color: Colors.white54, size: 72),
      );
    }

    if (_videoHasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
            const SizedBox(height: 12),
            const Text('Failed to load video',
                style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _initializeVideoPlayer(mediaUrl),
              icon: const Icon(Icons.refresh, color: _kAccent),
              label: const Text('Retry', style: TextStyle(color: _kAccent)),
            ),
          ],
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return const Center(child: CircularProgressIndicator(color: _kAccent));
    }

    final controller = _videoController!;
    return GestureDetector(
      onTap: _toggleVideoPlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio == 0
                  ? 16 / 9
                  : controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          // Simple centered play/pause overlay — no bottom scrubber bar.
          if (!controller.value.isPlaying)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.4), blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 44),
            ),
        ],
      ),
    );
  }

  Widget _buildTopChrome(int total) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        offset: _chromeVisible ? Offset.zero : const Offset(0, -1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _chromeVisible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 16,
              left: 8,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC0B1929), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    widget.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (total > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailStrip(int total) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        offset: _chromeVisible ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _chromeVisible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Container(
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 14,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xE60B1929), Colors.transparent],
              ),
            ),
            child: SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: total,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => _buildThumbnail(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    final mediaUrl = widget.mediaUrls[index];
    final isVideo = _isVideoUrl(mediaUrl);
    final isActive = index == _currentIndex;

    return GestureDetector(
      onTap: () => _jumpTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? _kAccent : Colors.white24,
            width: isActive ? 2.5 : 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: _kAccent.withOpacity(0.5), blurRadius: 8)]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isVideo)
                Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Icon(Icons.videocam_rounded,
                      color: Colors.white70, size: 22),
                )
              else
                Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white10,
                    child: const Icon(Icons.broken_image_outlined,
                        color: Colors.white38, size: 20),
                  ),
                ),
              if (!isActive) Container(color: Colors.black.withOpacity(0.35)),
              if (isVideo)
                const Center(
                  child:
                      Icon(Icons.play_circle_fill, color: _kAccent, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
