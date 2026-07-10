/// Application constants for Echo Player
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'Echo Player';
  static const String appTagline = 'Modern Offline Audio Player';
  static const String appVersion = '1.0.0';

  // Developer Information
  static const String developerName = 'Omar Sami Mohamed';
  static const String developerEmail = 'omarsami.dev@example.com';
  static const String githubUrl = 'https://github.com/OmarSamiMohamed';
  static const String linkedInUrl = 'https://linkedin.com/in/omarsamimohamed';

  // Storage Keys
  static const String favoritesKey = 'echo_player_favorites';
  static const String playlistsKey = 'echo_player_playlists';
  static const String lastPlayedSongKey = 'echo_player_last_song';
  static const String lastPositionKey = 'echo_player_last_position';
  static const String settingsKey = 'echo_player_settings';
  static const String recentlyPlayedKey = 'echo_player_recently_played';
  static const String mostPlayedKey = 'echo_player_most_played';

  // Default Values
  static const double defaultPlaybackSpeed = 1.0;
  static const int defaultSleepTimerMinutes = 30;
  static const int maxRecentlyPlayed = 20;
  static const int maxFavoritesDisplay = 50;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultBorderRadius = 16.0;
  static const double cardBorderRadius = 20.0;
  static const double smallBorderRadius = 12.0;
  static const double largeBorderRadius = 24.0;

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Font Sizes
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 14.0;
  static const double normalFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double extraLargeFontSize = 24.0;
  static const double hugeFontSize = 32.0;
}
