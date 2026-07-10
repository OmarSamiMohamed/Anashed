import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

/// Now Playing screen for Echo Player
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Timer? _sleepTimer;
  int _sleepTimerMinutes = 0;

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          final currentSong = audioProvider.currentSong;

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.backgroundColor,
                      AppTheme.surfaceColor.withValues(alpha: 0.5),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, audioProvider),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Column(
                          children: [
                            _buildAlbumArt(currentSong),
                            const SizedBox(height: AppConstants.largePadding),
                            _buildSongInfo(currentSong),
                            const SizedBox(height: AppConstants.largePadding),
                            _buildProgressBar(audioProvider),
                            const SizedBox(height: AppConstants.largePadding),
                            _buildControls(audioProvider),
                            const SizedBox(height: AppConstants.defaultPadding),
                            _buildExtraControls(audioProvider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AudioProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 32,
            color: AppTheme.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'NOW PLAYING',
            style: TextStyle(
              fontSize: AppConstants.smallFontSize,
              color: AppTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.queue_music),
            iconSize: 24,
            color: AppTheme.textPrimary,
            onPressed: () => _showQueueDialog(context, audioProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(Song? song) {
    if (song == null) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        child: const Icon(
          Icons.music_note,
          size: 80,
          color: AppTheme.textTertiary,
        ),
      );
    }

    return Hero(
      tag: 'album_art',
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.music_note,
          size: 80,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSongInfo(Song? song) {
    return Column(
      children: [
        Text(
          song?.title ?? 'Unknown',
          style: const TextStyle(
            fontSize: AppConstants.extraLargeFontSize,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          song?.artist ?? 'Unknown Artist',
          style: const TextStyle(
            fontSize: AppConstants.largeFontSize,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProgressBar(AudioProvider audioProvider) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: Colors.white24,
            thumbColor: AppTheme.primaryColor,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: audioProvider.position.inSeconds.toDouble(),
            max: audioProvider.duration.inSeconds.toDouble().clamp(
              1,
              double.infinity,
            ),
            onChanged: (value) {
              audioProvider.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Helpers.formatDuration(audioProvider.position),
                style: const TextStyle(
                  fontSize: AppConstants.smallFontSize,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                Helpers.formatDuration(audioProvider.duration),
                style: const TextStyle(
                  fontSize: AppConstants.smallFontSize,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(AudioProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 40,
          color: AppTheme.textPrimary,
          onPressed: () => audioProvider.skipPrevious(),
        ),
        // Play/Pause
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: AppTheme.backgroundColor,
            ),
            iconSize: 40,
            onPressed: () => audioProvider.playPause(),
          ),
        ),
        // Next
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 40,
          color: AppTheme.textPrimary,
          onPressed: () => audioProvider.skipNext(),
        ),
      ],
    );
  }

  Widget _buildExtraControls(AudioProvider audioProvider) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final currentSong = audioProvider.currentSong;
        final isFavorite =
            currentSong != null && favoritesProvider.isFavorite(currentSong.id);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Repeat
            _buildRepeatButton(audioProvider),
            // Like
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
              iconSize: 28,
              onPressed: () {
                if (currentSong != null) {
                  favoritesProvider.toggleFavorite(currentSong.id);
                }
              },
            ),
            // Shuffle
            _buildShuffleButton(audioProvider),
            // Speed
            IconButton(
              icon: Text(
                '${audioProvider.speed}x',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: audioProvider.speed != 1.0
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
              ),
              onPressed: () => _showSpeedDialog(context, audioProvider),
            ),
            // Sleep Timer
            IconButton(
              icon: Icon(
                _sleepTimerMinutes > 0 ? Icons.timer : Icons.timer_outlined,
                color: _sleepTimerMinutes > 0
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
              iconSize: 28,
              onPressed: () => _showSleepTimerDialog(context, audioProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRepeatButton(AudioProvider audioProvider) {
    IconData icon;
    Color color;

    switch (audioProvider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = AppTheme.textSecondary;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = AppTheme.primaryColor;
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = AppTheme.primaryColor;
        break;
    }

    return IconButton(
      icon: Icon(icon, size: 28, color: color),
      onPressed: () => audioProvider.toggleRepeat(),
    );
  }

  Widget _buildShuffleButton(AudioProvider audioProvider) {
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        size: 28,
        color: audioProvider.isShuffled
            ? AppTheme.primaryColor
            : AppTheme.textSecondary,
      ),
      onPressed: () => audioProvider.toggleShuffle(),
    );
  }

  void _showQueueDialog(BuildContext context, AudioProvider audioProvider) {
    final playlist = audioProvider.playlist;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Queue',
              style: TextStyle(
                fontSize: AppConstants.largeFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (playlist.isEmpty)
              const Center(child: Text('No songs in queue'))
            else
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: playlist.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final song = playlist[index];
                    final isCurrentSong =
                        audioProvider.currentSong?.id == song.id;
                    return ListTile(
                      leading: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrentSong
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: TextStyle(
                          color: isCurrentSong
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(song.artist),
                      onTap: () {
                        audioProvider.setPlaylist(
                          playlist,
                          initialIndex: index,
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog(BuildContext context, AudioProvider audioProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Playback Speed',
              style: TextStyle(
                fontSize: AppConstants.largeFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...Helpers.playbackSpeedOptions.map((speed) {
              final isSelected = audioProvider.speed == speed;
              return ListTile(
                title: Text('${speed}x'),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  audioProvider.setSpeed(speed);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerDialog(
    BuildContext context,
    AudioProvider audioProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sleep Timer',
                  style: TextStyle(
                    fontSize: AppConstants.largeFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (_sleepTimerMinutes > 0)
                  TextButton(
                    onPressed: () {
                      _cancelSleepTimer();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...Helpers.sleepTimerOptions.map((minutes) {
              final isSelected = _sleepTimerMinutes == minutes;
              return ListTile(
                title: Text(
                  minutes >= 60
                      ? '${minutes ~/ 60} hour${minutes ~/ 60 > 1 ? 's' : ''}'
                      : '$minutes minutes',
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  _startSleepTimer(minutes, audioProvider);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _startSleepTimer(int minutes, AudioProvider audioProvider) {
    _sleepTimer?.cancel();
    _sleepTimerMinutes = minutes;
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      audioProvider.pause();
      _sleepTimerMinutes = 0;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep timer ended. Playback paused.')),
        );
      }
    });
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sleep timer set for $minutes minutes')),
    );
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerMinutes = 0;
    setState(() {});
  }
}
