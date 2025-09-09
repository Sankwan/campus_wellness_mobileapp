import 'package:flutter/material.dart';
import 'dart:async';
import '../models/meditation_model.dart';
import '../theme.dart';
import '../services/audio_service.dart';
import '../widgets/toast.dart';

class MeditationPlayerScreen extends StatefulWidget {
  final MeditationModel meditation;

  const MeditationPlayerScreen({
    super.key,
    required this.meditation,
  });

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen>
    with TickerProviderStateMixin {
  bool isPlaying = false;
  bool isPreparing = true;
  bool showSoundSelector = false;
  int currentSeconds = 0;
  int totalSeconds = 0;
  Timer? _timer;
  Timer? _prepareTimer;
  int prepareCountdown = 5;
  
  late AnimationController _breatheController;
  late AnimationController _rippleController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _rippleAnimation;
  
  final AudioService _audioService = AudioService.instance;
  AmbientSoundType _selectedSound = AmbientSoundType.none;

  @override
  void initState() {
    super.initState();
    totalSeconds = widget.meditation.duration * 60;
    
    // Initialize audio service
    _audioService.initialize();
    
    // Initialize animations
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _breatheAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    // Start preparation phase
    _startPreparation();
  }

  void _startPreparation() {
    _prepareTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prepareCountdown > 1) {
        setState(() {
          prepareCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          isPreparing = false;
        });
        _startMeditation();
      }
    });
  }

  void _startMeditation() {
    setState(() {
      isPlaying = true;
    });
    
    _breatheController.repeat(reverse: true);
    _startRippleEffect();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSeconds < totalSeconds) {
        setState(() {
          currentSeconds++;
        });
      } else {
        _completeMeditation();
      }
    });
  }

  void _startRippleEffect() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && isPlaying) {
        _rippleController.forward().then((_) {
          _rippleController.reset();
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _togglePlayPause() async {
    setState(() {
      isPlaying = !isPlaying;
    });
    
    if (isPlaying) {
      // Resume meditation
      _breatheController.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (currentSeconds < totalSeconds) {
          setState(() {
            currentSeconds++;
          });
        } else {
          _completeMeditation();
        }
      });
      
      // Resume ambient sound if there was one playing
      if (_selectedSound != AmbientSoundType.none) {
        await _audioService.resume();
      }
    } else {
      // Pause meditation
      _breatheController.stop();
      _timer?.cancel();
      
      // Pause ambient sound
      await _audioService.pause();
    }
  }

  void _completeMeditation() {
    _timer?.cancel();
    _breatheController.stop();
    _audioService.stop(); // Stop ambient sound
    
    setState(() {
      isPlaying = false;
    });
    
    ToastService.showSuccess(
      context: context,
      title: 'Session Complete! 🎉',
      description: 'Great job completing your ${widget.meditation.duration}-minute meditation',
    );
    
    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Well Done! 🎉',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You completed ${widget.meditation.title}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.meditation.duration} minutes of mindfulness',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Rating stars could be added here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _prepareTimer?.cancel();
    _breatheController.dispose();
    _rippleController.dispose();
    _audioService.stop(); // Stop any playing sounds
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return WillPopScope(
      onWillPop: () async {
        // Stop audio when back button is pressed
        await _audioService.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              // Stop audio when leaving the screen
              _audioService.stop();
              Navigator.of(context).pop();
            },
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
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                AppTheme.primaryGreen.withOpacity(0.1),
                Colors.black,
              ],
            ),
          ),
          child: Column(
            children: [
              // Preparation or main content
              Expanded(
                child: isPreparing 
                    ? _buildPreparationPhase()
                    : _buildMeditationPhase(),
              ),
              
              // Controls
              if (!isPreparing) _buildControls(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreparationPhase() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get Ready',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Find a comfortable position',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryGreen,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                prepareCountdown.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Starting in $prepareCountdown...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationPhase() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress indicator
              Text(
                _formatTime(totalSeconds - currentSeconds),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: currentSeconds / totalSeconds,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Breathing animation
              Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple effect
                  AnimatedBuilder(
                    animation: _rippleAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 200 + (_rippleAnimation.value * 100),
                        height: 200 + (_rippleAnimation.value * 100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(
                              0.5 - (_rippleAnimation.value * 0.5),
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  // Main breathing circle
                  AnimatedBuilder(
                    animation: _breatheAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breatheAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primaryGreen.withOpacity(0.7),
                                AppTheme.primaryGreen.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  // Center dot
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Breathing instruction
              AnimatedBuilder(
                animation: _breatheController,
                builder: (context, child) {
                  String instruction;
                  if (_breatheController.value < 0.5) {
                    instruction = 'Breathe In';
                  } else {
                    instruction = 'Breathe Out';
                  }
                  return Text(
                    instruction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ambient Sound Selection
          if (showSoundSelector) _buildSoundSelector(),
          
          // Main control row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Sound button
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedSound != AmbientSoundType.none 
                      ? AppTheme.primaryGreen.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedSound != AmbientSoundType.none 
                        ? AppTheme.primaryGreen
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      showSoundSelector = !showSoundSelector;
                    });
                  },
                  icon: Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              
              // Play/Pause button
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              
              // Time adjustment button
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: IconButton(
                  onPressed: _showTimeAdjustment,
                  icon: const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          
          // Current ambient sound indicator
          if (_selectedSound != AmbientSoundType.none)
            const SizedBox(height: 16),
          if (_selectedSound != AmbientSoundType.none)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AudioService.getSoundDisplayName(_selectedSound),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  //Sound selector widget
  Widget _buildSoundSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ambient Sounds',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AudioService.getAllSoundTypes().map((soundType) {
              final isSelected = _selectedSound == soundType;
              final displayName = AudioService.getSoundDisplayName(soundType);
              
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedSound = soundType;
                    showSoundSelector = false; // Auto-close selector
                  });
                  
                  try {
                    await _audioService.playAmbientSound(soundType);
                    if (soundType != AmbientSoundType.none) {
                      ToastService.showInfo(
                        context: context,
                        title: '♪ Now Playing',
                        description: displayName,
                      );
                    }
                  } catch (e) {
                    ToastService.showError(
                      context: context,
                      title: 'Audio Error',
                      description: 'Failed to play selected sound',
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryGreen.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryGreen
                          : Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        soundType == AmbientSoundType.none 
                            ? Icons.volume_off
                            : Icons.music_note,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  void _showTimeAdjustment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Adjust Session Time',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${widget.meditation.duration} minutes',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [5, 10, 15, 20, 30, 45].map((minutes) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      totalSeconds = minutes * 60;
                      currentSeconds = 0;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: minutes == widget.meditation.duration
                          ? AppTheme.primaryGreen
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: minutes == widget.meditation.duration
                            ? AppTheme.primaryGreen
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${minutes}m',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
