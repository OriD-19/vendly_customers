import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

/// Onboarding screen with 4 steps showcasing Vendly features
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Descubre tiendas increíbles',
      description:
          'Explora una amplia variedad de tiendas locales y encuentra exactamente lo que necesitas, todo en un solo lugar.',
      imagePath: 'assets/images/onboarding/browse_stores.png',
      backgroundColor: AppColors.mauve.withOpacity(0.1),
    ),
    OnboardingPage(
      title: 'Paga sin complicaciones',
      description:
          'Realiza pagos seguros y rápidos con múltiples métodos de pago. Sin colas, sin esperas.',
      imagePath: 'assets/images/onboarding/easy_payments.png',
      backgroundColor: AppColors.persianIndigo.withOpacity(0.1),
    ),
    OnboardingPage(
      title: 'Rastrea tus entregas',
      description:
          'Mantente informado con el seguimiento en tiempo real de todos tus pedidos desde la tienda hasta tu puerta.',
      imagePath: 'assets/images/onboarding/track_delivery.png',
      backgroundColor: AppColors.russianViolet.withOpacity(0.1),
    ),
    OnboardingPage(
      title: 'Personaliza tu experiencia',
      description:
          'Ajusta tus preferencias, guarda tus tiendas favoritas y recibe recomendaciones personalizadas.',
      imagePath: 'assets/images/onboarding/preferences.png',
      backgroundColor: AppColors.indigo.withOpacity(0.1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.aliceBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _goToHome(),
                    child: Text(
                      'Saltar',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),

            // Page indicators and navigation
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Navigation buttons
                  Row(
                    children: [
                      // Previous button
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Anterior'),
                          ),
                        ),

                      if (_currentPage > 0)
                        const SizedBox(width: AppTheme.spacingM),

                      // Next/Get Started button
                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _goToHome();
                            }
                          },
                          child: Text(
                            _currentPage < _pages.length - 1
                                ? 'Siguiente'
                                : 'Comenzar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.persianIndigo
            : AppColors.textTertiary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _goToHome() {
    context.go(AppRouter.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingXL),

          // Illustration container
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: page.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Center(child: _buildIllustration(page.imagePath)),
            ),
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Text content
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  page.title,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spacingM),

                Text(
                  page.description,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(String imagePath) {
    // For now, we'll use placeholder icons
    // In a real app, you'd load the actual images from assets
    final Map<String, IconData> illustrationIcons = {
      'assets/images/onboarding/browse_stores.png': Icons.storefront_rounded,
      'assets/images/onboarding/easy_payments.png': Icons.payment_rounded,
      'assets/images/onboarding/track_delivery.png':
          Icons.local_shipping_rounded,
      'assets/images/onboarding/preferences.png': Icons.tune_rounded,
    };

    final Map<String, Color> illustrationColors = {
      'assets/images/onboarding/browse_stores.png': AppColors.mauve,
      'assets/images/onboarding/easy_payments.png': AppColors.persianIndigo,
      'assets/images/onboarding/track_delivery.png': AppColors.russianViolet,
      'assets/images/onboarding/preferences.png': AppColors.indigo,
    };

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: illustrationColors[imagePath]!.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        illustrationIcons[imagePath]!,
        size: 80,
        color: illustrationColors[imagePath]!,
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}
