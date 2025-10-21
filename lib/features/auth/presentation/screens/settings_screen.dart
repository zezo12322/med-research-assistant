import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../providers/auth_provider.dart';
import '../../../projects/providers/projects_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricsEnabled = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadSettings();
  }

  Future<void> _checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable && isDeviceSupported;
        });
      }
    } catch (e) {
      debugPrint('Biometric check error: $e');
    }
  }

  Future<void> _loadSettings() async {
    final authNotifier = ref.read(authProvider.notifier);
    final enabled = await authNotifier.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricsEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value && !_isBiometricAvailable) {
      _showErrorSnackBar('Biometric authentication is not available');
      return;
    }

    if (value) {
      // Test biometric authentication before enabling
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Enable biometric authentication',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );

        if (!authenticated) {
          _showErrorSnackBar('Biometric authentication failed');
          return;
        }
      } catch (e) {
        _showErrorSnackBar('Error: ${e.toString()}');
        return;
      }
    }

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.setBiometricEnabled(value);
    
    if (mounted) {
      setState(() {
        _biometricsEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Biometric authentication enabled' : 'Biometric authentication disabled',
          ),
        ),
      );
    }
  }

  Future<void> _changePin() async {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPinController,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (currentPinController.text.length != 4 ||
                  newPinController.text.length != 4 ||
                  confirmPinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 4 digits')),
                );
                return;
              }

              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New PINs do not match')),
                );
                return;
              }

              // Verify current PIN
              final authNotifier = ref.read(authProvider.notifier);
              final isValid = await authNotifier.verifyPin(currentPinController.text);
              
              if (!isValid) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Current PIN is incorrect')),
                  );
                }
                return;
              }

              // Set new PIN
              await authNotifier.setPin(newPinController.text);
              
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN changed successfully')),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all projects, entries, and form data. '
          'This action cannot be undone!\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Double confirmation
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Final Warning'),
        content: const Text(
          'ALL YOUR DATA WILL BE PERMANENTLY DELETED!\n\n'
          'This includes:\n'
          '• All projects\n'
          '• All patient entries\n'
          '• All form fields\n'
          '• All images\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Delete Everything'),
          ),
        ],
      ),
    );

    if (doubleConfirmed != true) return;

    try {
      final repository = ref.read(projectsRepositoryProvider);
      await repository.deleteAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showAbout() async {
    showAboutDialog(
      context: context,
      applicationName: 'Med Research Assistant',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.medical_services, size: 48),
      children: [
        const Text(
          'A professional medical research data collection application.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Custom form builder\n'
          '• Secure data storage\n'
          '• Image capture\n'
          '• CSV export\n'
          '• Biometric authentication\n'
          '• Offline support',
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2025 Med Research Assistant\n'
          'All rights reserved.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Security Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'SECURITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            subtitle: Text(
              _isBiometricAvailable
                  ? (_biometricsEnabled ? 'Enabled' : 'Disabled')
                  : 'Not available on this device',
            ),
            trailing: Switch(
              value: _biometricsEnabled,
              onChanged: _isBiometricAvailable ? _toggleBiometrics : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change PIN'),
            subtitle: const Text('Update your security PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changePin,
          ),
          const Divider(),

          // Data Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'DATA MANAGEMENT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all projects and entries'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearAllData,
          ),
          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAbout,
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Developer'),
            subtitle: const Text('Built with Flutter'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Developer Info'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Built with:'),
                      SizedBox(height: 8),
                      Text('• Flutter 3.35.6'),
                      Text('• Dart 3.9.2'),
                      Text('• Isar Database'),
                      Text('• Riverpod'),
                      Text('• Material Design 3'),
                      SizedBox(height: 16),
                      Text('Clean Architecture'),
                      Text('Offline-first approach'),
                      Text('End-to-end encryption'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.medical_services,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Med Research Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Professional Medical Data Collection',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
