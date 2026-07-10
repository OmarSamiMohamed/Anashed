import 'dart:math';

/// Utility helper functions for Echo Player
class Helpers {
  Helpers._();

  /// Format duration to MM:SS or HH:MM:SS format
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration with custom separator
  static String formatDurationCustom(
    Duration duration, {
    String separator = ':',
  }) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return [
        hours,
        minutes,
        seconds,
      ].map((v) => v.toString().padLeft(2, '0')).join(separator);
    }
    return [
      minutes,
      seconds,
    ].map((v) => v.toString().padLeft(2, '0')).join(separator);
  }

  /// Parse duration string back to Duration
  static Duration parseDuration(String durationString) {
    final parts = durationString.split(':');
    if (parts.length == 2) {
      return Duration(
        minutes: int.parse(parts[0]),
        seconds: int.parse(parts[1]),
      );
    } else if (parts.length == 3) {
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
    }
    return Duration.zero;
  }

  /// Format number with commas (e.g., 1,000)
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Truncate string with ellipsis
  static String truncateString(String str, int maxLength) {
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength - 3)}...';
  }

  /// Generate a random color from a list of predefined colors
  static String generateRandomColor() {
    final colors = [
      '#F59E0B',
      '#3B82F6',
      '#10B981',
      '#EF4444',
      '#8B5CF6',
      '#EC4899',
      '#06B6D4',
      '#84CC16',
    ];
    return colors[Random().nextInt(colors.length)];
  }

  /// Check if a string is null or empty
  static bool isNullOrEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// Normalize string for search (lowercase, remove special chars)
  static String normalizeForSearch(String str) {
    return str.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  /// Calculate progress percentage
  static double calculateProgress(Duration position, Duration duration) {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Debounce function for search
  static Duration get debounceDuration => const Duration(milliseconds: 300);

  /// Get sleep timer options in minutes
  static List<int> get sleepTimerOptions => [
    5,
    10,
    15,
    20,
    30,
    45,
    60,
    90,
    120,
  ];

  /// Get playback speed options
  static List<double> get playbackSpeedOptions => [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  /// Convert milliseconds to seconds
  static int msToSeconds(int milliseconds) => milliseconds ~/ 1000;

  /// Convert seconds to milliseconds
  static int secondsToMs(int seconds) => seconds * 1000;
}
