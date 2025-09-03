import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AmbientSoundType {
  none,
  rainforest,
  ocean,
  whitenoise,
  lofi,
  binauralbeats,
  fireplace,
  birds,
}

class AmbientSoundOption {
  final AmbientSoundType type;
  final String name;
  final String description;
  final String assetPath;
  final String icon;
  final bool isPremium;

  const AmbientSoundOption({
    required this.type,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.icon,
    this.isPremium = false,
  });
}

class AmbientSoundService extends ChangeNotifier {
  static final AmbientSoundService _instance = AmbientSoundService._internal();
  factory AmbientSoundService() => _instance;
  AmbientSoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  AmbientSoundType _currentSound = AmbientSoundType.none;
  double _volume = 0.6;
  bool _isPlaying = false;

  AmbientSoundType get currentSound => _currentSound;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

//Will add sounds later to the assets folder and update the paths
  static const List<AmbientSoundOption> availableSounds = [
    AmbientSoundOption(
      type: AmbientSoundType.none,
      name: 'None',
      description: 'Silent meditation',
      assetPath: '',
      icon: '🔇',
    ),
    AmbientSoundOption(
      type: AmbientSoundType.rainforest,
      name: 'Rainforest',
      description: 'Gentle rain and forest sounds',
      assetPath: 'sounds/rainforest.mp3',
      icon: '🌧️',
    ),
    AmbientSoundOption(
      type: AmbientSoundType.ocean,
      name: 'Ocean Waves',
      description: 'Calming ocean waves',
      assetPath: 'sounds/ocean_waves.mp3',
      icon: '🌊',
    ),
    AmbientSoundOption(
      type: AmbientSoundType.whitenoise,
      name: 'White Noise',
      description: 'Consistent background noise',
      assetPath: 'sounds/white_noise.mp3',
      icon: '⚪',
    ),
    AmbientSoundOption(
      type: AmbientSoundType.lofi,
      name: 'Lo-fi Beats',
      description: 'Relaxing lo-fi music',
      assetPath: 'sounds/lofi_beats.mp3',
      icon: '🎵',
    ),
    AmbientSoundOption(
      type: AmbientSoundType.binauralbeats,
      name: 'Binaural Beats',
      description: 'Alpha wave frequencies',
      assetPath: 'sounds/binaural_beats.mp3',
      icon: '🧠',
      isPremium: true,
    ),
    AmbientSoundOption(
      type: AmbientSoundType.fireplace,
      name: 'Fireplace',
      description: 'Cozy crackling fire',
      assetPath: 'sounds/fireplace.mp3',
      icon: '🔥',
    ),
    AmbientSoundOption(
      type: AmbientSoundType.birds,
      name: 'Forest Birds',
      description: 'Peaceful bird songs',
      assetPath: 'sounds/forest_birds.mp3',
      icon: '🐦',
    ),
  ];

  static AmbientSoundOption getSoundOption(AmbientSoundType type) {
    return availableSounds.firstWhere(
      (sound) => sound.type == type,
      orElse: () => availableSounds.first,
    );
  }

  Future<void> playSound(AmbientSoundType soundType) async {
    try {
      await stop();
      
      if (soundType == AmbientSoundType.none) {
        _currentSound = soundType;
        _isPlaying = false;
        notifyListeners();
        return;
      }

      final soundOption = getSoundOption(soundType);
      
      // For demo purposes, we'll use a fallback URL-based sound
      // In production, we would probably have to use local asset files
      String audioSource = '';
      
      switch (soundType) {
        case AmbientSoundType.rainforest:
          // Using a placeholder rain sound URL - we will replace with local assets later on
          audioSource = 'https://www.soundjay.com/misc/sounds/rain-01.mp3';
          break;
        case AmbientSoundType.ocean:
          audioSource = 'https://www.soundjay.com/misc/sounds/ocean-wave-1.mp3';
          break;
        case AmbientSoundType.whitenoise:
          audioSource = 'https://www.soundjay.com/misc/sounds/white-noise-1.mp3';
          break;
        case AmbientSoundType.lofi:
          // Using placeholder - in production, we will use local assets
          audioSource = 'https://example.com/lofi-track.mp3';
          break;
        default:
          // We will use locally generated tones or silence for other types
          break;
      }

      if (audioSource.isNotEmpty) {
        await _audioPlayer.setSourceUrl(audioSource);
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.resume();
        
        _currentSound = soundType;
        _isPlaying = true;
        notifyListeners();
      } else {
        // For sounds without URLs, we will create a local tone or use asset
        await _playLocalAsset(soundOption.assetPath);
      }
    } catch (e) {
      debugPrint('Error playing ambient sound: $e');
      // Fallback to silence if sound fails
      _currentSound = AmbientSoundType.none;
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> _playLocalAsset(String assetPath) async {
    try {
      // For now, we'll simulate local assets
      // In production, we will add actual sound files to assets/sounds/
      
      // Generate a simple tone for demonstration
      _currentSound = _currentSound;
      _isPlaying = true;
      notifyListeners();
      
      // TODO: Implement actual local asset loading when assets are added
      debugPrint('Playing local asset: $assetPath');
    } catch (e) {
      debugPrint('Error playing local asset: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentSound != AmbientSoundType.none) {
      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSound = AmbientSoundType.none;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    super.dispose();
  }
}
