import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/http_helper.dart';

// main widget for the share code screen
class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  bool isLoading = true; // indicates if data is still loading
  String? code; // stores the code to be shared
  String? error; // stores any error message

  @override
  void initState() {
    super.initState();
    _startSession(); // start session when widget is initialized
  }

  // function to start a session and fetch the code
  Future<void> _startSession() async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final deviceId = appState.deviceId;
      final response = await HttpHelper.startSession(deviceId);

      if (mounted) {
        setState(() {
          code = response['data']['code']; // set the fetched code
          appState.setSessionId(
              response['data']['session_id']); // update session id in app state
          isLoading = false; // data loading is complete
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to start session! Please try again.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Share Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        color: Colors.blue[50],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator() // show loading indicator
                else if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(
                        color: Colors.red), // show error message
                  )
                else ...[
                  const Text(
                    'Share this code with your friend:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    code!,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/movie-selection'); // navigate to movie selection screen
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[900],
                    ),
                    child: const Text('Start Picking Movies'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
