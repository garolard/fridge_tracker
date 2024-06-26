import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fridge_tracker/screens/items_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  final timezone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezone));

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('ic_stat_app_icon');
  const initializationSettings = InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(initializationSettings);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF009963),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFA1824A),
      onSecondary: Color(0xFFF5F0E5),
      error: Color(0xFFe85656),
      onError: Color(0xFFFFFFFF),
      background: Color(0xFFFCFBF8),
      onBackground: Color(0xFF1C170D),
      surface: Color(0xFFF5F0E5),
      onSurface: Color(0xFFA1824A),
    );
    return MaterialApp(
      title: 'Fridge Tracker',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: GoogleFonts.beVietnamProTextTheme(),
        scaffoldBackgroundColor: colorScheme.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(colorScheme.primary),
            foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      home: const ItemsScreen(),
    );
  }
}
