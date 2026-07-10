import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/song_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/utils/helpers.dart';
import '../player/player_screen.dart';

/// Home screen for Echo Player
class HomeScreen extends StatefulWidget {
  final List<Song> songs;

  const HomeScreen({super.key, required this.songs});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Song> _songs;
  List<Song> _filteredSongs = [];
  String _searchQuery = '';
  bool _isLoadingSongs = false;

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.songs);
    _filteredSongs = List.from(_songs);
    _isLoadingSongs = false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSongs = List.from(_songs);
      } else {
        final normalizedQuery = Helpers.normalizeForSearch(query);
        _filteredSongs = _songs.where((song) {
          final title = Helpers.normalizeForSearch(song.title);
          final artist = Helpers.normalizeForSearch(song.artist);
          return title.contains(normalizedQuery) ||
              artist.contains(normalizedQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final hasCurrentSong = audioProvider.currentSong != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppTheme.backgroundColor,
                  elevation: 0,
                  title: const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  centerTitle: true,
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: EchoTextField(
                      controller: _searchController,
                      hint: 'Search songs, artists...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textTertiary,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),

                // All Songs Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchQuery.isEmpty ? 'All Songs' : 'Search Results',
                          style: const TextStyle(
                            fontSize: AppConstants.largeFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickAudioFiles,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add Songs'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Songs List
                if (_isLoadingSongs)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.defaultPadding),
                      child: EchoLoading(message: 'Loading songs...'),
                    ),
                  )
                else if (_filteredSongs.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyState(
                      title: 'No Songs Found',
                      subtitle: _searchQuery.isEmpty
                          ? 'Tap "Add Songs" to select audio files'
                          : 'Try a different search term',
                      icon: Icons.music_note,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildSongTile(_filteredSongs[index]),
                      childCount: _filteredSongs.length,
                    ),
                  ),

                // Bottom padding for mini player
                if (hasCurrentSong)
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),

          // Mini Player
          if (hasCurrentSong) _buildMiniPlayer(audioProvider),
        ],
      ),
    );
  }

  void _deleteSong(Song song) {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      setState(() {
        _songs.removeAt(index);
        _filteredSongs = List.from(_songs);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${song.title} removed')));
    }
  }

  Future<void> _pickAudioFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null) return;

      final newSongs = <Song>[];
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;

        final fileName = file.name.replaceAll(RegExp(r'\.[^/.]+$'), '');
        final title = fileName;
        final artist = 'Unknown Artist';
        final album = 'Unknown Album';

        final song = Song(
          id: path,
          title: title,
          artist: artist,
          album: album,
          duration: '0',
          data: path,
          dateAdded: DateTime.now().millisecondsSinceEpoch,
        );
        newSongs.add(song);
      }

      if (newSongs.isEmpty) return;

      setState(() {
        _songs.addAll(newSongs);
        _filteredSongs = List.from(_songs);
      });
    } catch (e) {
      debugPrint('Error picking audio files: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
      }
    }
  }

  Widget _buildSongTile(Song song) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final isPlaying =
            audioProvider.currentSong?.id == song.id && audioProvider.isPlaying;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 4,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
              child: _buildAlbumArt(song),
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isPlaying ? AppTheme.primaryColor : AppTheme.textPrimary,
              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist,
            style: const TextStyle(color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                song.formattedDuration,
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: AppConstants.smallFontSize,
                ),
              ),
              IconButton(
                icon: Icon(
                  context.watch<FavoritesProvider>().isFavorite(song.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: context.watch<FavoritesProvider>().isFavorite(song.id)
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  context.read<FavoritesProvider>().toggleFavorite(song.id);
                },
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                onPressed: () {
                  final index = _songs.indexWhere((s) => s.id == song.id);
                  if (isPlaying) {
                    audioProvider.playPause();
                  } else {
                    audioProvider.setPlaylist(_songs, initialIndex: index);
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                  size: 24,
                ),
                onPressed: () => _deleteSong(song),
              ),
            ],
          ),
          onTap: () {
            final index = _songs.indexWhere((s) => s.id == song.id);
            audioProvider.setPlaylist(_songs, initialIndex: index);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => PlayerScreen(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
              ),
            );
          },
        );
      },
    );
  }

  /// Build album art placeholder.
  Widget _buildAlbumArt(Song song) {
    return const Icon(Icons.music_note, color: AppTheme.textTertiary);
  }

  /// Build a mini player bar at the bottom of the home screen.
  Widget _buildMiniPlayer(AudioProvider audioProvider) {
    final song = audioProvider.currentSong!;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => PlayerScreen(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Row(
              children: [
                // Album Art
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(width: 12),
                // Song Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppConstants.mediumFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppConstants.smallFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Previous
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 28,
                  color: AppTheme.textPrimary,
                  onPressed: () => audioProvider.skipPrevious(),
                ),
                // Play/Pause
                IconButton(
                  icon: Icon(
                    audioProvider.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  iconSize: 36,
                  color: AppTheme.primaryColor,
                  onPressed: () => audioProvider.playPause(),
                ),
                // Next
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 28,
                  color: AppTheme.textPrimary,
                  onPressed: () => audioProvider.skipNext(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
