import 'dart:convert';

/// Represents a song/audio file in the Echo Player
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String data; // File path
  final String? albumArt; // Album art path or URI
  final int dateAdded;
  final int playCount;
  final DateTime? lastPlayed;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.data,
    this.albumArt,
    required this.dateAdded,
    this.playCount = 0,
    this.lastPlayed,
  });

  /// Create a Song from a map (for JSON deserialization)
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      duration: map['duration'] ?? '0',
      data: map['data'] ?? '',
      albumArt: map['albumArt'],
      dateAdded: map['dateAdded'] ?? DateTime.now().millisecondsSinceEpoch,
      playCount: map['playCount'] ?? 0,
      lastPlayed: map['lastPlayed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastPlayed'])
          : null,
    );
  }

  /// Create a Song from JSON string
  factory Song.fromJson(String source) => Song.fromMap(json.decode(source));

  /// Convert Song to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'data': data,
      'albumArt': albumArt,
      'dateAdded': dateAdded,
      'playCount': playCount,
      'lastPlayed': lastPlayed?.millisecondsSinceEpoch,
    };
  }

  /// Convert Song to JSON string
  String toJson() => json.encode(toMap());

  /// Get duration as Duration object
  Duration get durationAsDuration {
    try {
      final ms = int.tryParse(duration) ?? 0;
      return Duration(milliseconds: ms);
    } catch (_) {
      return Duration.zero;
    }
  }

  /// Get formatted duration string (MM:SS or HH:MM:SS)
  String get formattedDuration {
    final durationObj = durationAsDuration;
    final hours = durationObj.inHours;
    final minutes = durationObj.inMinutes.remainder(60);
    final seconds = durationObj.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Create a copy of the song with updated fields
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? duration,
    String? data,
    String? albumArt,
    int? dateAdded,
    int? playCount,
    DateTime? lastPlayed,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      data: data ?? this.data,
      albumArt: albumArt ?? this.albumArt,
      dateAdded: dateAdded ?? this.dateAdded,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  /// Check if two songs are equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, album: $album)';
  }
}

/// Empty song constant
const Song emptySong = Song(
  id: '',
  title: '',
  artist: '',
  album: '',
  duration: '0',
  data: '',
  dateAdded: 0,
);
