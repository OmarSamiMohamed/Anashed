import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'providers/audio_provider.dart';
import 'providers/favorites_provider.dart';
import 'models/song_model.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService().init();

  // Start with empty playlist - user will add songs via file picker
  runApp(const EchoPlayerApp(songs: []));
}

/// Main app widget
class EchoPlayerApp extends StatelessWidget {
  final List<Song> songs;

  const EchoPlayerApp({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()..init()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..init()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(AppTheme.darkTheme.textTheme),
        ),
        home: HomeScreen(songs: songs),
      ),
    );
  }
}
