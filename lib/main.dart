import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/services/auth_service.dart';
import 'features/cart/providers/cart_bloc.dart';
import 'features/cart/providers/cart_event.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication state from storage
  await AuthService.initialize();
  
  runApp(
    // BlocProvider at top level (doesn't rebuild on theme change)
    BlocProvider(
      create: (context) => CartBloc()..add(const LoadCart()),
      child: const ProviderScope(child: VendlyApp()),
    ),
  );
}

class VendlyApp extends ConsumerWidget {
  const VendlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Vendly Customer',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Use theme from provider
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
