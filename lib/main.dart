import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';
import 'services/device_id_service.dart';
import 'utils/app_state.dart';
import 'screens/share_code_screen.dart';
import 'screens/enter_code_screen.dart';
import 'screens/movie_selection_screen.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final deviceIdService = DeviceIdService(prefs);

  runApp(MovieNightApp(
      deviceIdService: deviceIdService, prefs: prefs)); // run the app
}

class MovieNightApp extends StatelessWidget {
  final DeviceIdService deviceIdService; // device id service instance
  final SharedPreferences prefs; // shared preferences instance

  const MovieNightApp(
      {super.key,
      required this.deviceIdService,
      required this.prefs}); // constructor

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(prefs), // provide app state
      child: MaterialApp(
        title: 'Movie Night', // app title
        theme: AppTheme.theme, // custom theme
        home: WelcomeScreen(
            deviceIdService: deviceIdService), // set welcome screen as home
        routes: {
          '/share-code': (context) =>
              const ShareCodeScreen(), // route for share code screen
          '/enter-code': (context) =>
              const EnterCodeScreen(), // route for enter code screen
          '/movie-selection': (context) =>
              const MovieSelectionScreen(), // route for movie selection screen
        },
      ),
    );
  }
}
