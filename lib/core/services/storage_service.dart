import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../models/playlist_model.dart';

/// Storage service for Echo Player
/// Handles all local data persistence using SharedPreferences
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==================== FAVORITES ====================

  /// Get all favorite song IDs
  List<String> getFavorites() {
    return prefs.getStringList(AppConstants.favoritesKey) ?? [];
  }

  /// Check if a song is favorited
  bool isFavorite(String songId) {
    final favorites = getFavorites();
    return favorites.contains(songId);
  }

  /// Add a song to favorites
  Future<bool> addFavorite(String songId) async {
    final favorites = getFavorites();
    if (!favorites.contains(songId)) {
      favorites.add(songId);
    }
    return prefs.setStringList(AppConstants.favoritesKey, favorites);
  }

  /// Remove a song from favorites
  Future<bool> removeFavorite(String songId) async {
    final favorites = getFavorites();
    favorites.remove(songId);
    return prefs.setStringList(AppConstants.favoritesKey, favorites);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String songId) async {
    if (isFavorite(songId)) {
      return removeFavorite(songId);
    } else {
      return addFavorite(songId);
    }
  }

  // ==================== PLAYLISTS ====================

  /// Get all playlists
  List<Playlist> getPlaylists() {
    final playlistsJson = prefs.getStringList(AppConstants.playlistsKey) ?? [];
    return playlistsJson.map((json) => Playlist.fromJson(json)).toList();
  }

  /// Get a playlist by ID
  Playlist? getPlaylist(String playlistId) {
    final playlists = getPlaylists();
    try {
      return playlists.firstWhere((p) => p.id == playlistId);
    } catch (_) {
      return null;
    }
  }

  /// Save a playlist
  Future<bool> savePlaylist(Playlist playlist) async {
    final playlists = getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);

    if (index >= 0) {
      playlists[index] = playlist;
    } else {
      playlists.add(playlist);
    }

    final playlistsJson = playlists.map((p) => p.toJson()).toList();
    return prefs.setStringList(AppConstants.playlistsKey, playlistsJson);
  }

  /// Delete a playlist
  Future<bool> deletePlaylist(String playlistId) async {
    final playlists = getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    final playlistsJson = playlists.map((p) => p.toJson()).toList();
    return prefs.setStringList(AppConstants.playlistsKey, playlistsJson);
  }

  /// Rename a playlist
  Future<bool> renamePlaylist(String playlistId, String newName) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return false;

    final updatedPlaylist = playlist.copyWith(name: newName);
    return savePlaylist(updatedPlaylist);
  }

  // ==================== RECENTLY PLAYED ====================

  /// Get recently played song IDs
  List<String> getRecentlyPlayed() {
    return prefs.getStringList(AppConstants.recentlyPlayedKey) ?? [];
  }

  /// Add a song to recently played
  Future<bool> addRecentlyPlayed(String songId) async {
    final recentlyPlayed = getRecentlyPlayed();

    recentlyPlayed.remove(songId);
    recentlyPlayed.insert(0, songId);

    if (recentlyPlayed.length > AppConstants.maxRecentlyPlayed) {
      recentlyPlayed.removeRange(
        AppConstants.maxRecentlyPlayed,
        recentlyPlayed.length,
      );
    }

    return prefs.setStringList(AppConstants.recentlyPlayedKey, recentlyPlayed);
  }

  /// Clear recently played
  Future<bool> clearRecentlyPlayed() async {
    return prefs.remove(AppConstants.recentlyPlayedKey);
  }

  // ==================== LAST PLAYED ====================

  /// Get last played song ID
  String? getLastPlayedSongId() {
    return prefs.getString(AppConstants.lastPlayedSongKey);
  }

  /// Save last played song
  Future<bool> saveLastPlayedSong(String songId) async {
    return prefs.setString(AppConstants.lastPlayedSongKey, songId);
  }

  /// Get last played position in milliseconds
  int getLastPlayedPosition() {
    return prefs.getInt(AppConstants.lastPositionKey) ?? 0;
  }

  /// Save last played position
  Future<bool> saveLastPlayedPosition(int positionMs) async {
    return prefs.setInt(AppConstants.lastPositionKey, positionMs);
  }

  // ==================== SETTINGS ====================

  /// Get playback speed setting
  double getPlaybackSpeed() {
    return prefs.getDouble('playback_speed') ??
        AppConstants.defaultPlaybackSpeed;
  }

  /// Set playback speed setting
  Future<bool> setPlaybackSpeed(double speed) async {
    return prefs.setDouble('playback_speed', speed);
  }

  /// Get repeat mode setting
  int getRepeatMode() {
    return prefs.getInt('repeat_mode') ?? 0;
  }

  /// Set repeat mode setting
  Future<bool> setRepeatMode(int mode) async {
    return prefs.setInt('repeat_mode', mode);
  }

  /// Get shuffle mode setting
  bool getShuffleMode() {
    return prefs.getBool('shuffle_mode') ?? false;
  }

  /// Set shuffle mode setting
  Future<bool> setShuffleMode(bool enabled) async {
    return prefs.setBool('shuffle_mode', enabled);
  }

  /// Get dark mode setting
  bool getDarkMode() {
    return prefs.getBool('dark_mode') ?? true;
  }

  /// Set dark mode setting
  Future<bool> setDarkMode(bool enabled) async {
    return prefs.setBool('dark_mode', enabled);
  }
}
