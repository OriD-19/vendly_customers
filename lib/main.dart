import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/services/auth_service.dart';
import 'features/cart/providers/cart_bloc.dart';
import 'features/cart/providers/cart_event.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication state from storage
  await AuthService.initialize();
  
  runApp(const ProviderScope(child: VendlyApp()));
}

class VendlyApp extends StatelessWidget {
  const VendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc()..add(const LoadCart()),
      child: MaterialApp.router(
        title: 'Vendly Customer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
