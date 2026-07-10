import 'dart:convert';

/// Represents a playlist in Echo Player
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? coverImage;
  final List<String> songIds; // Store song IDs for persistence
  final DateTime createdAt;
  final DateTime updatedAt;
  final int playCount;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverImage,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.playCount = 0,
  });

  /// Create a Playlist from a map
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? 'Untitled Playlist',
      description: map['description'],
      coverImage: map['coverImage'],
      songIds: List<String>.from(map['songIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
      playCount: map['playCount'] ?? 0,
    );
  }

  /// Create a Playlist from JSON string
  factory Playlist.fromJson(String source) =>
      Playlist.fromMap(json.decode(source));

  /// Convert Playlist to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'songIds': songIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'playCount': playCount,
    };
  }

  /// Convert Playlist to JSON string
  String toJson() => json.encode(toMap());

  /// Get the number of songs in the playlist
  int get songCount => songIds.length;

  /// Check if the playlist is empty
  bool get isEmpty => songIds.isEmpty;

  /// Check if the playlist is not empty
  bool get isNotEmpty => songIds.isNotEmpty;

  /// Create a copy of the playlist with updated fields
  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImage,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? playCount,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  /// Add a song to the playlist (returns new playlist with added song)
  Playlist addSong(String songId) {
    if (songIds.contains(songId)) return this;
    return copyWith(songIds: [...songIds, songId], updatedAt: DateTime.now());
  }

  /// Remove a song from the playlist (returns new playlist without the song)
  Playlist removeSong(String songId) {
    return copyWith(
      songIds: songIds.where((id) => id != songId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Check if a song is in the playlist
  bool containsSong(String songId) {
    return songIds.contains(songId);
  }

  /// Get index of a song in the playlist
  int getSongIndex(String songId) {
    return songIds.indexOf(songId);
  }

  /// Create a default playlist
  factory Playlist.defaultPlaylist({
    required String name,
    String? description,
  }) {
    return Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, songCount: $songCount)';
  }
}
