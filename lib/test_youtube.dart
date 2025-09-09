import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Simple test page to verify YouTube integration works
class TestYouTubePage extends StatefulWidget {
  const TestYouTubePage({super.key});

  @override
  State<TestYouTubePage> createState() => _TestYouTubePageState();
}

class _TestYouTubePageState extends State<TestYouTubePage> {
  late YoutubePlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Test with a known working video ID
    const videoId = 'YRPh_GaiL8s'; // Dr. Andrew Weil 4-7-8 breathing
    
    print('TestYouTubePage: Initializing with videoId: $videoId');
    
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
      ),
    );
    
    _controller.addListener(_onPlayerStateChange);
  }
  
  void _onPlayerStateChange() {
    if (!mounted) return;
    
    final value = _controller.value;
    print('TestYouTubePage Player State Changed:');
    print('- PlayerState: ${value.playerState}');
    print('- IsReady: ${value.isReady}');
    print('- HasError: ${value.hasError}');
    
    if (value.hasError) {
      print('- Error: ${value.errorCode}');
    }
    
    if (value.isReady != _isReady) {
      setState(() {
        _isReady = value.isReady;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Player Test'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // YouTube Player
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            onReady: () {
              print('YouTube Player is ready!');
            },
            onEnded: (metadata) {
              print('Video ended: $metadata');
            },
          ),
          
          // Status and Controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${_isReady ? "Ready" : "Loading..."}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Video: Dr. Andrew Weil 4-7-8 Breathing Technique',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Video ID: YRPh_GaiL8s',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _controller.play();
                        },
                        child: const Text('Play'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          _controller.pause();
                        },
                        child: const Text('Pause'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isReady)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading YouTube player...'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
