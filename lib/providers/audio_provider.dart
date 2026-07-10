import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../core/services/audio_service.dart';
import '../core/services/storage_service.dart';

/// Audio provider for managing playback state
class AudioProvider extends ChangeNotifier {
  final AudioPlaybackService _audioService = AudioPlaybackService();
  final StorageService _storageService = StorageService();

  // Current state
  Song? _currentSong;
  List<Song> _playlist = [];
  final List<Song> _queue = [];
  Duration _position = Duration.zero;
  Duration? _duration;
  PlayerState? _playerState;
  ProcessingState? _processingState;
  bool _isShuffled = false;
  LoopMode _loopMode = LoopMode.off;
  double _speed = 1.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Stream subscriptions
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<int?>? _currentIndexSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<SequenceState?>? _sequenceStateSub;

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get playlist => _playlist;
  List<Song> get queue => _queue;
  Duration get position => _position;
  Duration get duration => _duration ?? Duration.zero;
  PlayerState? get playerState => _playerState;
  ProcessingState? get processingState => _processingState;
  bool get isPlaying => _playerState?.playing ?? false;
  bool get isShuffled => _isShuffled;
  LoopMode get loopMode => _loopMode;
  double get speed => _speed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get currentIndex => _currentSong != null
      ? _playlist.indexWhere((s) => s.id == _currentSong!.id)
      : null;

  /// Initialize the audio provider
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _audioService.init();

      // Subscribe to audio service streams to update state in real-time
      _positionSub = _audioService.positionStream.listen((pos) {
        _position = pos;
        notifyListeners();
      });

      _durationSub = _audioService.durationStream.listen((dur) {
        _duration = dur;
        notifyListeners();
      });

      _playingSub = _audioService.playingStream.listen((playing) {
        notifyListeners();
      });

      _playerStateSub = _audioService.playerStateStream.listen((state) {
        _playerState = state;
        _processingState = state.processingState;

        // When playback completes naturally, update current song
        if (state.processingState == ProcessingState.completed) {
          _updateCurrentSong();
        }
        notifyListeners();
      });

      _currentIndexSub = _audioService.currentIndexStream.listen((index) {
        _updateCurrentSong();
      });

      _sequenceStateSub = _audioService.sequenceStateStream.listen((_) {
        _updateCurrentSong();
      });

      // Load saved settings
      _speed = _storageService.getPlaybackSpeed();
      _isShuffled = _storageService.getShuffleMode();
      _loopMode = LoopMode.values[_storageService.getRepeatMode()];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to initialize audio service: $e';
      notifyListeners();
    }
  }

  /// Set the playlist and optionally start playing
  Future<void> setPlaylist(
    List<Song> songs, {
    int initialIndex = 0,
    bool autoPlay = true,
  }) async {
    if (songs.isEmpty) return;

    _playlist = songs;
    _currentSong = songs[initialIndex];
    _isLoading = true;
    notifyListeners();

    try {
      await _audioService.setPlaylist(songs, initialIndex: initialIndex);

      if (autoPlay) {
        await _audioService.play();
        await _storageService.saveLastPlayedSong(_currentSong!.id);
        await _storageService.addRecentlyPlayed(_currentSong!.id);
      } else {
        await _storageService.saveLastPlayedSong(_currentSong!.id);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to set playlist: $e';
      notifyListeners();
    }
  }

  /// Play a single song
  Future<void> playSong(Song song) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _audioService.setAudioSource(song.data);
      _currentSong = song;
      await _audioService.play();
      await _storageService.saveLastPlayedSong(song.id);
      await _storageService.addRecentlyPlayed(song.id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to play song: $e';
      notifyListeners();
    }
  }

  /// Play or pause the current song
  Future<void> playPause() async {
    try {
      if (_audioService.playing) {
        await _audioService.pause();
      } else {
        await _audioService.play();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Play/Pause failed: $e';
      notifyListeners();
    }
  }

  /// Play the current song
  Future<void> play() async {
    try {
      await _audioService.play();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Play failed: $e';
      notifyListeners();
    }
  }

  /// Pause the current song
  Future<void> pause() async {
    try {
      await _audioService.pause();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Pause failed: $e';
      notifyListeners();
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioService.stop();
      _currentSong = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Stop failed: $e';
      notifyListeners();
    }
  }

  /// Skip to the next song
  Future<void> skipNext() async {
    try {
      await _audioService.skipToNext();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Skip next failed: $e';
      notifyListeners();
    }
  }

  /// Skip to the previous song
  Future<void> skipPrevious() async {
    try {
      await _audioService.skipToPrevious();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Skip previous failed: $e';
      notifyListeners();
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Seek failed: $e';
      notifyListeners();
    }
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    try {
      await _audioService.setSpeed(speed);
      _speed = speed;
      await _storageService.setPlaybackSpeed(speed);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Set speed failed: $e';
      notifyListeners();
    }
  }

  /// Toggle shuffle mode
  Future<void> toggleShuffle() async {
    try {
      await _audioService.toggleShuffle();
      _isShuffled = !_isShuffled;
      await _storageService.setShuffleMode(_isShuffled);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Toggle shuffle failed: $e';
      notifyListeners();
    }
  }

  /// Toggle repeat mode (off -> all -> one -> off)
  Future<void> toggleRepeat() async {
    try {
      await _audioService.toggleRepeat();
      _loopMode = _audioService.loopMode;
      await _storageService.setRepeatMode(_loopMode.index);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Toggle repeat failed: $e';
      notifyListeners();
    }
  }

  /// Set repeat mode
  Future<void> setRepeatMode(LoopMode mode) async {
    try {
      await _audioService.setRepeatMode(mode);
      _loopMode = mode;
      await _storageService.setRepeatMode(mode.index);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Set repeat mode failed: $e';
      notifyListeners();
    }
  }

  /// Update current song from playlist based on audio service's current index
  void _updateCurrentSong() {
    final index = _audioService.currentIndex;
    if (index != null && index >= 0 && index < _playlist.length) {
      final newSong = _playlist[index];
      if (_currentSong?.id != newSong.id) {
        _currentSong = newSong;
        _storageService.saveLastPlayedSong(_currentSong!.id);
        _storageService.addRecentlyPlayed(_currentSong!.id);
      }
    }
  }

  /// Add a song to the queue
  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
  }

  /// Remove a song from the queue at a specific index
  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear the entire queue
  void clearQueue() {
    _queue.clear();
    notifyListeners();
  }

  /// Get next songs from the playlist based on current index
  List<Song> getNextSongs({int count = 10}) {
    if (_currentSong == null || _playlist.isEmpty) return [];

    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex < 0) return [];

    return _playlist.skip(currentIndex + 1).take(count).toList();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _currentIndexSub?.cancel();
    _playerStateSub?.cancel();
    _sequenceStateSub?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
