import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../models/song_model.dart';

/// Audio playback service for Echo Player.
/// Wraps just_audio's AudioPlayer and exposes its streams directly.
class AudioPlaybackService {
  static final AudioPlaybackService _instance =
      AudioPlaybackService._internal();
  factory AudioPlaybackService() => _instance;
  AudioPlaybackService._internal();

  final AudioPlayer _player = AudioPlayer();

  /// Direct access to the underlying AudioPlayer for advanced usage
  AudioPlayer get player => _player;

  // Streams directly from the AudioPlayer (no redundant StreamControllers)
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  // Current state getters
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get playing => _player.playing;
  int? get currentIndex => _player.currentIndex;
  bool get shuffleModeEnabled => _player.shuffleModeEnabled;
  LoopMode get loopMode => _player.loopMode;
  double get speed => _player.speed;
  SequenceState? get sequenceState => _player.sequenceState;

  /// Initialize the audio service
  Future<void> init() async {
    // Configure audio session for background playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  /// Convert a file path to a proper URI for just_audio.
  /// On Android/iOS, file paths like /storage/emulated/0/song.mp3 must be
  /// converted to file:///storage/emulated/0/song.mp3 to work with just_audio.
  Uri _filePathToUri(String filePath) {
    // If it already has a scheme, parse as-is
    if (filePath.startsWith('http://') ||
        filePath.startsWith('https://') ||
        filePath.startsWith('file://') ||
        filePath.startsWith('asset://')) {
      return Uri.parse(filePath);
    }
    // Otherwise convert the absolute file path to a file:// URI
    return Uri.file(filePath);
  }

  /// Set a single audio source from a file path
  Future<void> setAudioSource(String filePath) async {
    await _player.setAudioSource(AudioSource.uri(_filePathToUri(filePath)));
  }

  /// Set a playlist of audio sources from file paths with metadata for notifications
  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;

    final sources = songs.map((song) {
      return AudioSource.uri(_filePathToUri(song.data));
    }).toList();

    final playlist = ConcatenatingAudioSource(children: sources);
    await _player.setAudioSource(playlist, initialIndex: initialIndex);
  }

  /// Play
  Future<void> play() async {
    await _player.play();
  }

  /// Pause
  Future<void> pause() async {
    await _player.pause();
  }

  /// Toggle play/pause
  Future<void> playPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Next track
  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  /// Previous track
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Toggle shuffle
  Future<void> toggleShuffle() async {
    await _player.setShuffleModeEnabled(!_player.shuffleModeEnabled);
  }

  /// Set repeat mode
  Future<void> setRepeatMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  /// Toggle repeat (off -> all -> one -> off)
  Future<void> toggleRepeat() async {
    switch (_player.loopMode) {
      case LoopMode.off:
        await _player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await _player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  /// Dispose
  Future<void> dispose() async {
    await _player.dispose();
  }
}
