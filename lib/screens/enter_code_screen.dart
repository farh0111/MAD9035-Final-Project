import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/http_helper.dart';

// stateful widget for entering a code
class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _formKey = GlobalKey<FormState>(); // key for form validation
  final _codeController = TextEditingController(); // controller for text field
  bool _isLoading = false; // loading state

  @override
  void dispose() {
    _codeController.dispose(); // dispose controller to free resources
    super.dispose();
  }

  // function to join session
  Future<void> _joinSession() async {
    if (!_formKey.currentState!.validate()) return; // validate form

    setState(() => _isLoading = true); // set loading state

    try {
      final appState =
          Provider.of<AppState>(context, listen: false); // get app state
      final deviceId = appState.deviceId; // get device id
      final response = await HttpHelper.joinSession(
          deviceId, _codeController.text); // make http request

      if (!mounted) return; // check if widget is still mounted

      if (response.containsKey('data')) {
        appState.setSessionId(response['data']['session_id']); // set session id
        Navigator.pushReplacementNamed(
            context, '/movie-selection'); // navigate to next screen
      } else {
        // handle error
      }
    } catch (e) {
      // handle exception
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // reset loading state
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter 4-Digit Code',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // allow only digits
                    LengthLimitingTextInputFormatter(4), // limit length to 4
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your code!';
                    }
                    if (value.length != 4) {
                      return 'Oops, Code must be 4 digits!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _joinSession, // disable button if loading
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(), // show loading indicator
                        )
                      : const Text('Join Session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
