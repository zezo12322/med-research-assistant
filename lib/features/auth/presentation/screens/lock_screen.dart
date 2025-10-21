import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../projects/presentation/screens/projects_list_screen.dart';
import 'setup_pin_screen.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricEnabled();
  }

  Future<void> _checkBiometricEnabled() async {
    final enabled = await ref.read(authProvider.notifier).isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await ref.read(authProvider.notifier).verifyPin(_pinController.text);

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProjectsListScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Incorrect PIN. Please try again.';
          _pinController.clear();
        });
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await ref.read(authProvider.notifier).authenticateWithBiometric();

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProjectsListScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Biometric authentication failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Wait for initialization to complete
    if (!authState.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing security...'),
            ],
          ),
        ),
      );
    }

    // If no PIN is set, navigate to setup screen
    if (!authState.hasPinSet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SetupPinScreen()),
          );
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo/Icon
              Icon(
                Icons.medical_services_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Med Research Assistant',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Secure Medical Data Collection',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              
              // Lock Icon
              Icon(
                Icons.lock_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 24),
              
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
                  labelText: 'Enter PIN',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  counterText: '',
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 24),
              
              // Verify PIN Button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyPin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Unlock'),
              ),
              
              // Biometric Button
              if (authState.isBiometricAvailable && _isBiometricEnabled) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _authenticateWithBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use Biometric'),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your data is encrypted and stored securely on this device',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
