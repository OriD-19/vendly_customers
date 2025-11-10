import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_provider.dart';

/// Theme toggle widget - shows current theme and allows switching
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = themeNotifier.isDarkMode(context);

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: isDark ? Colors.amber : AppColors.persianIndigo,
      ),
      tooltip: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
      onPressed: () {
        themeNotifier.toggleTheme();
      },
    );
  }
}

/// Theme selector bottom sheet - shows all theme options
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ThemeSelector(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Tema de la aplicación',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona tu tema preferido',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Light mode option
          _ThemeOption(
            icon: Icons.light_mode,
            title: 'Modo Claro',
            subtitle: 'Fondo blanco, ideal para el día',
            isSelected: currentThemeMode == ThemeMode.light,
            onTap: () {
              themeNotifier.setLightMode();
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 12),

          // Dark mode option
          _ThemeOption(
            icon: Icons.dark_mode,
            title: 'Modo Oscuro',
            subtitle: 'Fondo oscuro, ideal para la noche',
            isSelected: currentThemeMode == ThemeMode.dark,
            onTap: () {
              themeNotifier.setDarkMode();
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 12),

          // System mode option
          _ThemeOption(
            icon: Icons.brightness_auto,
            title: 'Automático',
            subtitle: 'Sigue la configuración del sistema',
            isSelected: currentThemeMode == ThemeMode.system,
            onTap: () {
              themeNotifier.setSystemMode();
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Individual theme option tile
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.persianIndigo
                : (isDark ? Colors.white24 : AppColors.borderColor),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.persianIndigo.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.persianIndigo
                    : (isDark ? Colors.white12 : AppColors.surfaceSecondary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.persianIndigo),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.persianIndigo
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.persianIndigo,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple switch-style theme toggle
class ThemeSwitch extends ConsumerWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = themeNotifier.isDarkMode(context);

    return SwitchListTile(
      value: isDark,
      onChanged: (_) => themeNotifier.toggleTheme(),
      title: Text(
        'Modo oscuro',
        style: AppTypography.bodyLarge,
      ),
      subtitle: Text(
        isDark ? 'Activado' : 'Desactivado',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      secondary: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: isDark ? Colors.amber : AppColors.persianIndigo,
      ),
    );
  }
}
