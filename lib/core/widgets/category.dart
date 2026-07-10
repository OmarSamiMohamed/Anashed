import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatefulWidget {
  final String songName;
  final String imagePath;
  final String songPath;

  const CategoryItem({
    super.key,
    required this.songName,
    required this.imagePath,
    required this.songPath,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  late final AudioPlayer _audioPlayer;

  static _CategoryItemState? currentPlaying;

  bool _isPlaying = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }

      if (currentPlaying == this) {
        currentPlaying = null;
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (currentPlaying != null && currentPlaying != this) {
      await currentPlaying!._audioPlayer.stop();

      if (currentPlaying!.mounted) {
        currentPlaying!.setState(() {
          currentPlaying!._isPlaying = false;
          currentPlaying!._position = Duration.zero;
        });
      }
    }

    currentPlaying = this;

    await _audioPlayer.play(AssetSource(widget.songPath));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    widget.imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    widget.songName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _togglePlayPause,
                  iconSize: 46,
                  color: const Color(0xFFF59E0B),
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFF59E0B),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFFF59E0B),
              ),
              child: Slider(
                min: 0,
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds == 0
                    ? 1
                    : _duration.inSeconds.toDouble(),
                onChanged: (value) async {
                  await _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatTime(_position),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  formatTime(_duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
