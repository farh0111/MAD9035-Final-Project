import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/device_id_service.dart';
import '../utils/app_state.dart';
import '../utils/constants.dart';

// welcome screen widget that serves as the main entry point of app
class WelcomeScreen extends StatelessWidget {
  final DeviceIdService deviceIdService;

  const WelcomeScreen({super.key, required this.deviceIdService});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);


//uses provider package for state management through app state
    if (appState.deviceId == null) {
      deviceIdService.getDeviceId().then((id) {
        appState.setDeviceId(id);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Night',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        color: Colors.blue[50],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Movie Night!',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: Spacing.xl),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/share-code');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[900],
                  ),
                  child: const Text('Get Code to Share'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/enter-code');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[900],
                  ),
                  child: const Text('Enter Shared Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
