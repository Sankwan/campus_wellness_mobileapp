import 'package:just_audio/just_audio.dart';

enum AmbientSoundType {
  none,
  breathing,
  deepFocus,
  mindfulness,
  sleep,
  song6,
  song7,
  stress,
}

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._internal();
  
  AudioService._internal();
  
  AudioPlayer? _player;
  AmbientSoundType _currentSound = AmbientSoundType.none;
  bool _isPlaying = false;
  
  AmbientSoundType get currentSound => _currentSound;
  bool get isPlaying => _isPlaying;
  
  /// Initialize the audio player
  Future<void> initialize() async {
    // Always stop and dispose previous player if it exists
    await _cleanupPlayer();
    _player = AudioPlayer();
    print('Audio player initialized');
  }
  
  /// Clean up existing player
  Future<void> _cleanupPlayer() async {
    if (_player != null) {
      try {
        await _player!.stop();
        await _player!.dispose();
        print('Previous audio player disposed');
      } catch (e) {
        print('Error disposing audio player: $e');
      }
      _player = null;
      _isPlaying = false;
      _currentSound = AmbientSoundType.none;
    }
  }
  
  /// Play an ambient sound
  Future<void> playAmbientSound(AmbientSoundType soundType) async {
    if (_player == null) await initialize();
    
    try {
      await stop(); // Stop any currently playing sound
      
      if (soundType == AmbientSoundType.none) {
        _currentSound = AmbientSoundType.none;
        return;
      }
      
      final assetPath = _getAssetPath(soundType);
      await _player!.setAsset(assetPath);
      await _player!.setLoopMode(LoopMode.one); // Loop the sound
      await _player!.play();
      
      _currentSound = soundType;
      _isPlaying = true;
    } catch (e) {
      print('Error playing ambient sound: $e');
      _currentSound = AmbientSoundType.none;
      _isPlaying = false;
    }
  }
  
  /// Stop the current ambient sound
  Future<void> stop() async {
    if (_player != null && _isPlaying) {
      await _player!.stop();
      _isPlaying = false;
    }
  }
  
  /// Pause the current ambient sound
  Future<void> pause() async {
    if (_player != null && _isPlaying) {
      await _player!.pause();
      _isPlaying = false;
    }
  }
  
  /// Resume the current ambient sound
  Future<void> resume() async {
    if (_player != null && !_isPlaying && _currentSound != AmbientSoundType.none) {
      await _player!.play();
      _isPlaying = true;
    }
  }
  
  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (_player != null) {
      await _player!.setVolume(volume.clamp(0.0, 1.0));
    }
  }
  
  /// Get the asset path for a sound type
  String _getAssetPath(AmbientSoundType soundType) {
    switch (soundType) {
      case AmbientSoundType.breathing:
        return 'assets/sounds/Breathing.mp3';
      case AmbientSoundType.deepFocus:
        return 'assets/sounds/Deepfocus.mp3';
      case AmbientSoundType.mindfulness:
        return 'assets/sounds/Mindfullness.mp3';
      case AmbientSoundType.sleep:
        return 'assets/sounds/Sleep.mp3';
      case AmbientSoundType.song6:
        return 'assets/sounds/Song6.mp3';
      case AmbientSoundType.song7:
        return 'assets/sounds/Song7.mp3';
      case AmbientSoundType.stress:
        return 'assets/sounds/Stress.mp3';
      case AmbientSoundType.none:
      default:
        return '';
    }
  }
  
  /// Get the display name for a sound type
  static String getSoundDisplayName(AmbientSoundType soundType) {
    switch (soundType) {
      case AmbientSoundType.none:
        return 'None';
      case AmbientSoundType.breathing:
        return 'Breathing';
      case AmbientSoundType.deepFocus:
        return 'Deep Focus';
      case AmbientSoundType.mindfulness:
        return 'Mindfulness';
      case AmbientSoundType.sleep:
        return 'Sleep';
      case AmbientSoundType.song6:
        return 'Calm Music 1';
      case AmbientSoundType.song7:
        return 'Calm Music 2';
      case AmbientSoundType.stress:
        return 'Stress Relief';
    }
  }
  
  /// Get all available sound types
  static List<AmbientSoundType> getAllSoundTypes() {
    return AmbientSoundType.values;
  }
  
  /// Dispose of the audio player
  Future<void> dispose() async {
    await stop();
    await _player?.dispose();
    _player = null;
  }
}
