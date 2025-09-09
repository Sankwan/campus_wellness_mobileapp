import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/meditation_model.dart';
import '../theme.dart';
import '../widgets/toast.dart';

class YouTubeMeditationPlayer extends StatefulWidget {
  final MeditationModel meditation;

  const YouTubeMeditationPlayer({
    super.key,
    required this.meditation,
  });

  @override
  State<YouTubeMeditationPlayer> createState() => _YouTubeMeditationPlayerState();
}

class _YouTubeMeditationPlayerState extends State<YouTubeMeditationPlayer> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  void _initializePlayer() {
    // Extract video ID from YouTube URL or use provided youtubeId
    String? videoId;
    
    // Debug logging
    print('YouTubeMeditationPlayer: Initializing with meditation:');
    print('- Title: ${widget.meditation.title}');
    print('- YouTubeId: ${widget.meditation.youtubeId}');
    print('- AudioUrl: ${widget.meditation.audioUrl}');
    
    if (widget.meditation.youtubeId != null && widget.meditation.youtubeId!.isNotEmpty) {
      videoId = widget.meditation.youtubeId;
      print('- Using provided YouTubeId: $videoId');
    } else if (widget.meditation.audioUrl != null && 
               widget.meditation.audioUrl!.isNotEmpty &&
               (widget.meditation.audioUrl!.contains('youtube.com') || 
                widget.meditation.audioUrl!.contains('youtu.be'))) {
      videoId = YoutubePlayer.convertUrlToId(widget.meditation.audioUrl!);
      print('- Extracted YouTubeId from URL: $videoId');
    }
    
    if (videoId == null || videoId.isEmpty) {
      print('- ERROR: No valid video ID found');
      // Show error and go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastService.showError(
          context: context,
          title: 'Invalid Video',
          description: 'Unable to load YouTube video. No valid video ID found.',
        );
        Navigator.of(context).pop();
      });
      return;
    }
    
    print('- Initializing YouTube player with videoId: $videoId');
    
    try {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false, // Disable captions to avoid issues
          controlsVisibleAtStart: true,
          useHybridComposition: true, // Better performance on Android
          forceHD: false,
          startAt: 0,
        ),
      );
      
      _controller.addListener(_onPlayerStateChange);
      
      print('- YouTube controller initialized successfully');
    } catch (e) {
      print('- ERROR: Failed to initialize YouTube controller: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastService.showError(
          context: context,
          title: 'Player Error',
          description: 'Failed to initialize video player: $e',
        );
        Navigator.of(context).pop();
      });
    }
  }
  
  void _onPlayerStateChange() {
    if (!mounted) return;
    
    final value = _controller.value;
    print('YouTube Player State Changed:');
    print('- PlayerState: ${value.playerState}');
    print('- IsFullScreen: ${value.isFullScreen}');
    print('- HasError: ${value.hasError}');
    
    if (value.hasError) {
      print('- Error: ${value.errorCode}');
      ToastService.showError(
        context: context,
        title: 'Playback Error',
        description: 'Video playback encountered an error. Please try again.',
      );
    }
    
    if (value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = value.isFullScreen;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.meditation.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          // YouTube Player - Simplified
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppTheme.primaryGreen,
            onReady: () {
              print('YouTube Player is ready in meditation player!');
            },
            onEnded: (metadata) {
              print('Video ended: $metadata');
            },
          ),
          
          // Video Information and Controls
          _buildVideoInfo(),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Expanded(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Title and Metadata
            Text(
              widget.meditation.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.meditation.duration} min',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.category,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.meditation.category,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGreen,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppTheme.primaryGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.meditation.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            if (widget.meditation.description.isNotEmpty) ...[
              Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.meditation.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addToFavorites,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addToFavorites() {
    ToastService.showSuccess(
      context: context,
      title: 'Added to Favorites',
      description: '${widget.meditation.title} has been saved to your favorites',
    );
  }

  void _shareVideo() {
    ToastService.showInfo(
      context: context,
      title: 'Share',
      description: 'Sharing functionality will be implemented soon',
    );
  }
}
