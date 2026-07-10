import 'package:flutter/foundation.dart';
import '../models/song_model.dart';
import '../core/services/storage_service.dart';

/// Favorites provider for managing favorite songs
class FavoritesProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<String> _favoriteIds = [];
  bool _isLoading = false;

  // Getters
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  int get favoritesCount => _favoriteIds.length;

  /// Initialize the favorites provider
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteIds = _storageService.getFavorites();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Check if a song is favorited
  bool isFavorite(String songId) {
    return _favoriteIds.contains(songId);
  }

  /// Add a song to favorites
  Future<bool> addFavorite(String songId) async {
    if (_favoriteIds.contains(songId)) return true;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _storageService.addFavorite(songId);
      if (success) {
        _favoriteIds.add(songId);
      }
      return success;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove a song from favorites
  Future<bool> removeFavorite(String songId) async {
    if (!_favoriteIds.contains(songId)) return true;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _storageService.removeFavorite(songId);
      if (success) {
        _favoriteIds.remove(songId);
      }
      return success;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String songId) async {
    if (isFavorite(songId)) {
      return removeFavorite(songId);
    } else {
      return addFavorite(songId);
    }
  }

  /// Filter songs to only show favorites
  List<Song> filterFavorites(List<Song> songs) {
    return songs.where((song) => _favoriteIds.contains(song.id)).toList();
  }

  /// Clear all favorites
  Future<bool> clearAllFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final favorites = List<String>.from(_favoriteIds);
      for (final id in favorites) {
        await _storageService.removeFavorite(id);
      }
      _favoriteIds.clear();
      return true;
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
