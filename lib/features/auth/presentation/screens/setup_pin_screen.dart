import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../projects/presentation/screens/projects_list_screen.dart';

class SetupPinScreen extends ConsumerStatefulWidget {
  const SetupPinScreen({super.key});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showConfirm = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _setupPin() async {
    if (_pinController.text.length < 4) {
      setState(() {
        _errorMessage = 'PIN must be at least 4 digits';
      });
      return;
    }

    if (!_showConfirm) {
      setState(() {
        _showConfirm = true;
        _errorMessage = '';
      });
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _errorMessage = 'PINs do not match';
        _confirmPinController.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await ref.read(authProvider.notifier).setPin(_pinController.text);

    if (mounted) {
      if (success) {
        // Auto-authenticate after setting PIN
        ref.read(authProvider.notifier).verifyPin(_pinController.text);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProjectsListScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to set PIN. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Icon
              Icon(
                Icons.security,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Secure Your Data',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Create a PIN to protect patient information',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              
              // PIN Input
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '••••••',
                  labelText: _showConfirm ? 'PIN' : 'Create PIN',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  counterText: '',
                ),
                enabled: !_showConfirm,
                onSubmitted: (_) => _setupPin(),
              ),
              
              // Confirm PIN Input
              if (_showConfirm) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(
                    hintText: '••••••',
                    labelText: 'Confirm PIN',
                    counterText: '',
                  ),
                  onSubmitted: (_) => _setupPin(),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Setup Button
              ElevatedButton(
                onPressed: _isLoading ? null : _setupPin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_showConfirm ? 'Confirm' : 'Continue'),
              ),
              
              const SizedBox(height: 32),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, 
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Use a PIN you can remember\n'
                      '• Minimum 4 digits required\n'
                      '• Keep your PIN confidential\n'
                      '• This protects sensitive patient data',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
