import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/auth_guard.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Widget that requires authentication to display content
/// Shows login prompt if user is not authenticated
class AuthRequired extends StatelessWidget {
  final Widget child;
  final String? message;
  final bool showPlaceholder;

  const AuthRequired({
    super.key,
    required this.child,
    this.message,
    this.showPlaceholder = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthGuard.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final isAuthenticated = snapshot.data ?? false;

        if (!isAuthenticated) {
          if (showPlaceholder) {
            return _LoginPrompt(message: message);
          } else {
            return const SizedBox.shrink();
          }
        }

        return child;
      },
    );
  }
}

/// Login prompt widget shown when user is not authenticated
class _LoginPrompt extends StatelessWidget {
  final String? message;

  const _LoginPrompt({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mauve.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.persianIndigo,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Iniciar Sesión',
              style: AppTypography.h2.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message ?? 'Debes iniciar sesión para acceder a esta sección',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.persianIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Iniciar Sesión'),
              ),
            ),
            const SizedBox(height: 12),

            // Register Link
            TextButton(
              onPressed: () => context.go('/register'),
              child: Text(
                '¿No tienes cuenta? Regístrate',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.persianIndigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Button that requires authentication before executing action
class AuthRequiredButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? authMessage;
  final ButtonStyle? style;

  const AuthRequiredButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.authMessage,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final hasAuth = await AuthGuard.requireAuth(
          context,
          message: authMessage,
        );
        if (hasAuth) {
          onPressed();
        }
      },
      style: style,
      child: child,
    );
  }
}

/// IconButton that requires authentication before executing action
class AuthRequiredIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String? authMessage;
  final String? tooltip;

  const AuthRequiredIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.authMessage,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final hasAuth = await AuthGuard.requireAuth(
          context,
          message: authMessage,
        );
        if (hasAuth) {
          onPressed();
        }
      },
      icon: icon,
      tooltip: tooltip,
    );
  }
}
