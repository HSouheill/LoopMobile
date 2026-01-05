import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '/services/listing_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/report_dialog.dart';
import 'package:video_player/video_player.dart';
import '../../environment.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../models/chat.dart';
import '../chat/chat_conversation_page.dart';
import '../../services/agent_service.dart';
import '../../widgets/recommended_agents_widget.dart';
import '../agents/single_agent_page.dart';
import 'listing_media_gallery_page.dart';
import '../../widgets/listing_widgets/featured_listings_widget.dart';

class SingleListingPage extends StatefulWidget {
  final PropertyListing listing;

  const SingleListingPage({super.key, required this.listing});

  @override
  State<SingleListingPage> createState() => _SingleListingPageState();
}

class _SingleListingPageState extends State<SingleListingPage> {
  PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isExpanded = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoHasError = false;
  List<PropertyListing> _relatedListings = [];
  bool _isLoadingRelated = false;

  String get _ownerDisplayName {
    if (widget.listing.ownerFirstName != null && widget.listing.ownerLastName != null) {
      return '${widget.listing.ownerFirstName} ${widget.listing.ownerLastName}';
    } else if (widget.listing.ownerFirstName != null) {
      return widget.listing.ownerFirstName!;
    } else if (widget.listing.ownerEmail != null) {
      return widget.listing.ownerEmail!;
    }
    return widget.listing.agentName;
  }
  
  String? get _ownerPhone {
    return widget.listing.ownerPhone ?? widget.listing.contactPhone;
  }

  // Check if a URL is a video
  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // Get all images from the listing (including video thumbnail)
  List<String> get _allImages {
    List<String> mediaItems = [];
    
    // Add all images
    if (widget.listing.images != null && widget.listing.images!.isNotEmpty) {
      mediaItems.addAll(widget.listing.images!);
    } else {
      // Fallback to main image if no additional images
      mediaItems.add(widget.listing.imageUrl);
    }
    
    // Add video as image (if video exists)
    if (widget.listing.video != null && widget.listing.video!.isNotEmpty) {
      // Video URL is already fully constructed (e.g., http://localhost:3000/api/assets/filename.mp4)
      mediaItems.add(widget.listing.video!);
    }
    
    return mediaItems;
  }

  int get _mediaCount => _allImages.length;
  int get _videoCount => _allImages.where(_isVideoUrl).length;
  int get _photoCount => _mediaCount - _videoCount;

  String get _formattedPrice {
    if (widget.listing.priceValue != null) {
      final currency = widget.listing.currency ?? 'USD';
      final price = widget.listing.priceValue;
      final formatter = NumberFormat.currency(symbol: currency == 'USD' ? '\$' : currency);
      return formatter.format(price);
    }
    return widget.listing.price;
  }

  // Build owner profile image URL
  String? get _ownerProfileImageUrl {
    if (widget.listing.ownerProfileImage == null || widget.listing.ownerProfileImage!.isEmpty) {
      return null;
    }
    final image = widget.listing.ownerProfileImage!;
    // If it's already a full URL, return as is
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    // Build full URL
    return '${Environment.apiUrl}assets/$image';
  }

  String _formattedDate(BuildContext context) {
    if (widget.listing.createdAt != null) {
      return DateFormat('EEEE, d MMMM yyyy').format(widget.listing.createdAt!);
    }
    final l10n = AppLocalizations.of(context);
    return l10n?.dateNotAvailable ?? 'Date not available';
  }

  String get _propertyCode {
    return widget.listing.id;
  }

  // -------------------- Helpers --------------------
  String _normalizeForTel(String raw) {
    if (raw.isEmpty) return '';
    // remove spaces and common formatting characters (keep + if present)
    String s = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // convert leading 00 to +
    if (s.startsWith('00')) {
      s = '+${s.substring(2)}';
    }

    // If it doesn't start with + and starts with 0 -> assume local Lebanese number
    if (!s.startsWith('+')) {
      if (s.startsWith('0')) {
        s = '+961${s.substring(1)}';
      } else {
        // no leading 0 or +: assume Lebanese (change if you want a different default)
        s = '+961$s';
      }
    }

    return s;
  }

  String _normalizeForWhatsApp(String raw) {
    if (raw.isEmpty) return '';
    // remove everything except digits
    String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');

    // if starts with 00 -> drop it
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    // if starts with 0 -> replace with country code 961 (Lebanon)
    if (digits.startsWith('0')) {
      digits = '961${digits.substring(1)}';
    }

    // if it doesn't start with country code (961), assume Lebanon
    if (!digits.startsWith('961')) {
      digits = '961$digits';
    }

    return digits;
  }

  // -------------------- Updated call method --------------------
  Future<void> _makeCall() async {
    final phoneNumber = _ownerPhone;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final String tel = _normalizeForTel(phoneNumber);
    final Uri phoneUri = Uri(scheme: 'tel', path: tel);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.platformDefault);
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.couldNotMakePhoneCall ?? 'Could not make call')),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.couldNotMakePhoneCallAgent ?? 'Error making call: $e')),
      );
    }
  }

  // -------------------- Updated WhatsApp method --------------------
  Future<void> _openWhatsApp() async {
    final phoneNumber = _ownerPhone;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final String waNumber = _normalizeForWhatsApp(phoneNumber);

    // Try opening the native app first
    final Uri appUri = Uri.parse('whatsapp://send?phone=$waNumber');

    // Fallback: web wa.me
    final Uri webUri = Uri.parse('https://wa.me/$waNumber');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.couldNotOpenWhatsApp ?? 'Could not open WhatsApp')),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.errorOpeningWhatsApp(e.toString()) ?? 'Error opening WhatsApp: $e')),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        listingId: widget.listing.id,
        listingTitle: widget.listing.title,
      ),
    );
  }

  Future<void> _startChat() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final l10n = AppLocalizations.of(context);
      final token = AuthService.token;
      if (token == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.pleaseLoginToStartChatAgent ?? 'Please log in to start a chat')),
        );
        return;
      }

      // Get owner ID from the listing
      final ownerId = widget.listing.ownerId;
      if (ownerId == null || ownerId.isEmpty) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner information not available')),
        );
        return;
      }

      // First, try to get existing chat with the owner
      Chat? existingChat = await ChatService.getChatWithUser(token, ownerId);
      
      Chat? chat = existingChat;
      
      // If no existing chat, create a new one
      if (chat == null) {
        chat = await ChatService.createChat(
          token: token,
          otherUserId: ownerId,
        );
      }

      Navigator.pop(context); // Close loading dialog

      if (chat != null) {
        // Navigate to chat conversation page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationPage(
              chat: chat!,
              otherParticipantName: _ownerDisplayName,
              otherParticipantImage: _ownerProfileImageUrl,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.failedToStartChatAgent ?? 'Failed to start chat. Please try again.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _viewProfile() async {
    try {
      // Get owner ID from the listing
      final ownerId = widget.listing.ownerId;
      if (ownerId == null || ownerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner information not available')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch agent data using the new endpoint
      final responseData = await AgentService.getAgentById(ownerId);
      
      Navigator.pop(context); // Close loading dialog

      // The response has a 'user' key containing the actual user data
      final userData = responseData['user'];
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid response format from server')),
        );
        return;
      }

      // Convert the fetched data to Agent object
      final agent = Agent.fromJson(userData);

      // Navigate to single agent page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SingleAgentPage(agent: agent),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    
    setState(() {
      _isVideoInitialized = false;
      _videoHasError = false;
    });
    
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _videoHasError = false;
        });
        _videoController!.setLooping(true);
        _videoController!.play();
      }).catchError((error) {
        setState(() {
          _isVideoInitialized = false;
          _videoHasError = true;
        });
      });
  }

  @override
  void initState() {
    super.initState();
    // Initialize video player if the first media item is a video
    if (_allImages.isNotEmpty && _isVideoUrl(_allImages[0])) {
      _initializeVideoPlayer(_allImages[0]);
    }
    // Load related listings
    _loadRelatedListings();
  }

  Future<void> _loadRelatedListings() async {
    setState(() {
      _isLoadingRelated = true;
    });

    try {
      final response = await ListingService.getSimilarListings(widget.listing.id);
      if (mounted) {
        setState(() {
          _relatedListings = response.listings;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
    
    // Check if the current page is a video
    if (index < _allImages.length && _isVideoUrl(_allImages[index])) {
      _initializeVideoPlayer(_allImages[index]);
    } else {
      // Pause and dispose video if switching away from video
      if (_videoController != null) {
        _videoController!.pause();
        _videoController!.dispose();
        _videoController = null;
        setState(() {
          _isVideoInitialized = false;
          _videoHasError = false;
        });
      }
    }
  }

  void _openGallery(int initialIndex) {
    if (_allImages.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingMediaGalleryPage(
          mediaUrls: _allImages,
          initialIndex: initialIndex,
          title: widget.listing.title,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Slider AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image/Video PageView
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _allImages.length,
                    itemBuilder: (context, index) {
                      final mediaUrl = _allImages[index];
                      final isVideo = _isVideoUrl(mediaUrl);
                      
                      // Display video player or image
                      if (isVideo) {
                        // This is a video item
                        if (_currentImageIndex == index) {
                          // Current page is a video - show video player
                          if (_videoHasError) {
                            // Error state for video
                            return Container(
                              color: Colors.black,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Failed to load video',
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Check console for URL',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _initializeVideoPlayer(mediaUrl);
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (_isVideoInitialized && _videoController != null) {
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
                                  // Video player filling the space
                                  SizedBox.expand(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _videoController!.value.size.width,
                                        height: _videoController!.value.size.height,
                                        child: VideoPlayer(_videoController!),
                                      ),
                                    ),
                                  ),
                                  // Play button overlay (only show when paused)
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
                          } else {
                            // Loading state for video
                            return Container(
                              color: Colors.black,
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );
                          }
                        } else {
                          // Not current page but is video - show placeholder
                          return Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          );
                        }
                      } else {
                        // Display image
                        return GestureDetector(
                          onTap: () => _openGallery(index),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Image.asset(
                                    'assets/Watermark.png',
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  
                  // Media counter
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _videoCount > 0
                            ? '$_photoCount photos · $_videoCount video${_videoCount > 1 ? 's' : ''}'
                            : '$_photoCount photos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // Navigation arrows
                  if (_allImages.length > 1) ...[
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_currentImageIndex < _allImages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Title & Location overlay at bottom of image
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.listing.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.listing.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return IconButton(
                    icon: const Icon(Icons.flag, color: Colors.transparent, size: 0),
                    onPressed: _showReportDialog,
                    tooltip: l10n?.reportListing ?? 'Report this listing',
                  );
                }
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Price
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formattedPrice,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          // const SizedBox(height: 8),
                          // Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     const Icon(Icons.person, size: 18, color: Colors.green),
                          //     const SizedBox(width: 6),
                          //     Text(
                          //       _ownerDisplayName,
                          //       style: const TextStyle(
                          //         color: Colors.green,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Owner Card Section
                    if (widget.listing.ownerRole != null || 
                        widget.listing.ownerFirstName != null || 
                        widget.listing.ownerCompanyName != null)
                      _buildOwnerCard(),
                    
                    const SizedBox(height: 32),
                    
                    // Property Details Section - Table-like design
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header outside the table
                        Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return Text(
                                  l10n?.propertyDetails ?? 'Property Details',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Property details table with alternating backgrounds
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: _buildPropertyDetailsTable(context),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Description Section
                    if (widget.listing.description != null && widget.listing.description!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context);
                                    return Text(
                                      l10n?.description ?? 'Description',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.listing.description!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                height: 1.5,
                              ),
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded ? null : TextOverflow.ellipsis,
                            ),
                            if (widget.listing.description!.length > 150) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                },
                                child: Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context);
                                    return Text(
                                      _isExpanded ? (l10n?.readLess ?? 'Read Less') : (l10n?.readMore ?? 'Read More'),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    );
                                  }
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Amenities Section (if available)
                    if (widget.listing.amenityList != null && widget.listing.amenityList!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_outline, color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context);
                                    return Text(
                                      l10n?.amenitiesLabel ?? 'Amenities',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: widget.listing.amenityList!.map((amenity) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    _formatAmenityName(amenity),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Related Listings Section
                    if (_isLoadingRelated || _relatedListings.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.home_work_outlined, color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context);
                                    return Text(
                                      l10n?.relatedListings ?? 'Related Listings',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isLoadingRelated)
                              const SizedBox(
                                height: 330,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_relatedListings.isEmpty)
                              const SizedBox(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    'No related listings found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 330,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _relatedListings.length,
                                  itemBuilder: (context, index) {
                                    final listing = _relatedListings[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: PropertyListingCard(listing: listing),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    if (_isLoadingRelated || _relatedListings.isNotEmpty)
                      const SizedBox(height: 32),
                    
                    // Property Code and Listed Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _propertyCode));
                            final l10n = AppLocalizations.of(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n?.propertyCodeCopied ?? 'Property code copied to clipboard')),
                            );
                          },
                          child: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context);
                              return RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                  children: [
                                    TextSpan(
                                      text: l10n?.propertyCodeLabel ?? 'Property Code: ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: _propertyCode,
                                    ),
                                    const TextSpan(text: ' '),
                                    const WidgetSpan(
                                      child: Icon(Icons.copy, size: 16, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                        ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              children: [
                                TextSpan(
                                  text: l10n?.listedDateLabel ?? 'Listed Date: ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: _formattedDate(context),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Contact Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _makeCall,
                            icon: const Icon(Icons.phone, color: Colors.white),
                            label: Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return Text(l10n?.callButton ?? 'Call', style: const TextStyle(color: Colors.white));
                              }
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openWhatsApp,
                            icon: const Icon(Icons.message, color: Colors.white),
                            label: Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return Text(l10n?.whatsAppButton ?? 'WhatsApp', style: const TextStyle(color: Colors.white));
                              }
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Report Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showReportDialog,
                        icon: const Icon(Icons.flag, color: Colors.transparent, size: 0),
                        label: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            return Text(l10n?.reportListing ?? 'Report this listing', style: const TextStyle(color: Colors.red));
                          }
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildPropertyDetailsTable(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    List<Map<String, String>> details = [];
    
    // Size
    if (widget.listing.size != null) {
      details.add({
        'label': 'Size',
        'value': l10n?.sizeLabel(widget.listing.size.toString()) ?? '${widget.listing.size} sqm',
      });
    }
    
    // Bedrooms and Bathrooms
    String roomInfo = '';
    if (widget.listing.bedrooms != null && widget.listing.bathrooms != null) {
      roomInfo = l10n?.bedroomsBathrooms(widget.listing.bedrooms.toString(), widget.listing.bathrooms.toString()) ?? '${widget.listing.bedrooms} Bedrooms, ${widget.listing.bathrooms} Bathrooms';
    } else if (widget.listing.bedrooms != null) {
      roomInfo = l10n?.bedroomsOnly(widget.listing.bedrooms.toString()) ?? '${widget.listing.bedrooms} Bedrooms';
    } else if (widget.listing.bathrooms != null) {
      roomInfo = l10n?.bathroomsOnly(widget.listing.bathrooms.toString()) ?? '${widget.listing.bathrooms} Bathrooms';
    }
    if (roomInfo.isNotEmpty) {
      details.add({
        'label': 'Rooms',
        'value': roomInfo,
      });
    }
    
    // Property type
    if (widget.listing.type != null) {
      details.add({
        'label': l10n?.typeLabel ?? 'Type',
        'value': widget.listing.type!.toUpperCase(),
      });
    }
    
    // Floor
    if (widget.listing.floor != null) {
      details.add({
        'label': l10n?.floorLabel ?? 'Floor',
        'value': widget.listing.floor.toString(),
      });
    }
    
    // Condition
    if (widget.listing.condition != null) {
      details.add({
        'label': l10n?.conditionLabel ?? 'Condition',
        'value': widget.listing.condition!.toUpperCase(),
      });
    }
    
    // Building age
    if (widget.listing.buildingAge != null) {
      details.add({
        'label': 'Building Age',
        'value': l10n?.buildingAgeLabel(widget.listing.buildingAge.toString()) ?? '${widget.listing.buildingAge} years',
      });
    }
    
    // Papers
    if (widget.listing.papers != null) {
      details.add({
        'label': l10n?.papersLabel ?? 'Papers',
        'value': _formatPapers(widget.listing.papers!),
      });
    }
    
    // Furnishing
    if (widget.listing.furnishing != null) {
      details.add({
        'label': 'Furnishing',
        'value': _formatFurnishing(widget.listing.furnishing!),
      });
    }
    
    // Listing type
    if (widget.listing.listingFor != null) {
      String listingForText = widget.listing.listingFor!.toUpperCase();
      // Add paymentFrequency in brackets for rent listings
      if (widget.listing.listingFor!.toLowerCase() == 'rent' && 
          widget.listing.paymentFrequency != null && 
          widget.listing.paymentFrequency!.isNotEmpty) {
        String paymentFreq = widget.listing.paymentFrequency!.toLowerCase();
        // Capitalize first letter for display
        paymentFreq = paymentFreq[0].toUpperCase() + paymentFreq.substring(1);
        listingForText += ' ($paymentFreq)';
      }
      details.add({
        'label': l10n?.availableForLabel ?? 'Available for',
        'value': listingForText,
      });
    }
    
    // Available from
    if (widget.listing.availableFrom != null) {
      final availableDate = DateFormat('MMMM yyyy').format(widget.listing.availableFrom!);
      details.add({
        'label': 'Available from',
        'value': availableDate,
      });
    }
    
    // Build rows with alternating backgrounds
    return details.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> detail = entry.value;
      bool isEven = index % 2 == 0;
      bool isFirst = index == 0;
      bool isLast = index == details.length - 1;
      
      return _buildPropertyDetailRow(
        detail['label']!,
        detail['value']!,
        isEven: isEven,
        isFirst: isFirst,
        isLast: isLast,
      );
    }).toList();
  }
  
  Widget _buildPropertyDetailRow(String label, String value, {bool isEven = false, bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(12) : Radius.zero,
          topRight: isFirst ? const Radius.circular(12) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(12) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCard() {
    final isAgentCompany = widget.listing.ownerRole == 'agent-company';
    final isAgentIndividual = widget.listing.ownerRole == 'agent-individual';
    final hasCompanyName = widget.listing.ownerCompanyName != null && 
                          widget.listing.ownerCompanyName!.isNotEmpty;
    
    // Determine the heading text based on role
    String headingText;
    if (isAgentCompany) {
      headingText = 'Listed by agency';
    } else if (isAgentIndividual) {
      headingText = 'Listed by agent';
    } else {
      headingText = 'Listed by individual';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Owner information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Listed by agency", "Listed by agent", or "Listed by individual" heading
                Text(
                  headingText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Company name (if agent-company) or Agent name
                if (isAgentCompany && hasCompanyName)
                  Text(
                    widget.listing.ownerCompanyName!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  )
                else if (widget.listing.ownerFirstName != null || widget.listing.ownerLastName != null)
                  Text(
                    _ownerDisplayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Verified Business badge (if agent-company and has companyName)
                if (isAgentCompany && hasCompanyName)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Verified Business',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Agent name (if agent-company, show below company)
                if (isAgentCompany && hasCompanyName && 
                    (widget.listing.ownerFirstName != null || widget.listing.ownerLastName != null)) ...[
                  const SizedBox(height: 8),
                  Text(
                    _ownerDisplayName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Chat button and See profile link in a row
                Row(
                  children: [
                    // Chat button
                    GestureDetector(
                      onTap: _startChat,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // "See profile" link
                    GestureDetector(
                      onTap: _viewProfile,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'See profile',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Right side - Profile image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _ownerProfileImageUrl != null
                ? Image.network(
                    _ownerProfileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatAmenityName(String amenity) {
    // Convert camelCase to readable format
    String formatted = amenity.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    
    // Capitalize first letter and handle special cases
    formatted = formatted.trim();
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }
    
    // Handle special cases
    formatted = formatted.replaceAll('24 7', '24/7');
    formatted = formatted.replaceAll('A C', 'AC');
    
    return formatted;
  }
  
  String _formatPapers(String papers) {
    switch (papers.toLowerCase()) {
      case 'title_deed':
        return 'Title Deed';
      case 'contract':
        return 'Contract';
      case 'permit':
        return 'Building Permit';
      default:
        return papers.toUpperCase();
    }
  }
  
  String _formatFurnishing(String furnishing) {
    switch (furnishing.toLowerCase()) {
      case 'unfurnished':
        return 'Unfurnished';
      case 'semi_furnished':
        return 'Semi-Furnished';
      case 'fully_furnished':
        return 'Fully Furnished';
      default:
        return furnishing.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
    }
  }
}