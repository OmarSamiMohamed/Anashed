import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission service for Echo Player
/// Handles all runtime permission requests for audio access.
///
/// Android 13+ (API 33+): Uses READ_MEDIA_AUDIO (via Permission.audio)
/// Android 12 and below: Uses READ_EXTERNAL_STORAGE (via Permission.storage)
///
/// permission_handler automatically maps Permission.audio to the correct
/// platform-specific permission based on the device's Android version.
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// The current permission status
  PermissionStatus _audioPermissionStatus = PermissionStatus.denied;

  /// Whether audio permission has been granted
  bool get isGranted => _audioPermissionStatus.isGranted;

  /// Whether permission was permanently denied
  bool get isPermanentlyDenied => _audioPermissionStatus.isPermanentlyDenied;

  /// Check if audio/storage permission is granted
  Future<bool> hasAudioPermission() async {
    final status = await Permission.audio.status;
    _audioPermissionStatus = status;
    return status.isGranted;
  }

  /// Request the appropriate audio permission based on Android version.
  /// On Android 13+: Permission.audio maps to READ_MEDIA_AUDIO
  /// On Android 12 and below: Permission.audio maps to READ_EXTERNAL_STORAGE
  Future<bool> requestAudioPermissions() async {
    // First try the audio permission (works on Android 13+)
    var status = await Permission.audio.request();

    // If audio permission is not available or denied on older Android,
    // fall back to storage permission
    if (status.isDenied && defaultTargetPlatform == TargetPlatform.android) {
      status = await Permission.storage.request();
    }

    _audioPermissionStatus = status;
    return status.isGranted;
  }

  /// Check if permissions are permanently denied
  Future<bool> isPermissionPermanentlyDenied() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      var status = await Permission.audio.status;
      if (status.isPermanentlyDenied) return true;
      status = await Permission.storage.status;
      return status.isPermanentlyDenied;
    }
    final status = await Permission.audio.status;
    return status.isPermanentlyDenied;
  }
}
