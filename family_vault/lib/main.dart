import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/encryption_service.dart';
import 'data/services/storage_service.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/vault_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait + both landscape orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialise services in order
  await StorageService.instance.init();
  await EncryptionService.instance.init();
  await AuthService.instance.init();

  runApp(const FamilyVaultApp());
}

class FamilyVaultApp extends StatelessWidget {
  const FamilyVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VaultProvider()),
      ],
      child: MaterialApp(
        title: 'Family Vault',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const _RootNavigator(),
      ),
    );
  }
}

/// Listens to auth state and switches between login and home.
class _RootNavigator extends StatelessWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
