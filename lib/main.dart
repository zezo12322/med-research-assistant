import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/lock_screen.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar Database
  await IsarService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: MedResearchApp(),
    ),
  );
}

class MedResearchApp extends ConsumerWidget {
  const MedResearchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Med Research Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AppLifecycleManager(child: LockScreen()),
    );
  }
}

// Global lifecycle manager that locks the app when it goes to background
class AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;
  
  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('🔐 App Lifecycle Manager Started');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 App Lifecycle: $state');
    
    // Lock when app goes to background
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive) {
      print('🔒 Locking app - going to background');
      
      // Logout to require authentication again
      ref.read(authProvider.notifier).logout();
    }
    
    // When app comes back to foreground, check if authenticated
    if (state == AppLifecycleState.resumed) {
      print('👋 App resumed - checking auth state');
      final authState = ref.read(authProvider);
      
      if (!authState.isAuthenticated && mounted) {
        print('🔐 Not authenticated - showing lock screen');
        // Navigate to lock screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LockScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
