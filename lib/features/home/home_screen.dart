import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Home screen - Main landing page
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Vendly',
              style: AppTypography.h3.copyWith(
                color: AppColors.persianIndigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _WelcomeSection(),
            
            SizedBox(height: 24),
            
            // Categories Section
            _CategoriesSection(),
            
            SizedBox(height: 24),
            
            // Featured Stores
            _FeaturedStoresSection(),
            
            SizedBox(height: 24),
            
            // Promotions
            _PromotionsSection(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola!',
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre productos increíbles de tus tiendas favoritas',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.restaurant, 'name': 'Comida'},
      {'icon': Icons.local_grocery_store, 'name': 'Market'},
      {'icon': Icons.local_pharmacy, 'name': 'Farmacia'},
      {'icon': Icons.checkroom, 'name': 'Ropa'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: AppTypography.h3,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categories.map((category) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mauve.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: AppColors.persianIndigo,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: AppTypography.labelSmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeaturedStoresSection extends StatelessWidget {
  const _FeaturedStoresSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiendas destacadas',
              style: AppTypography.h3,
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todas',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.persianIndigo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.store,
                          size: 32,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tienda ${index + 1}',
                      style: AppTypography.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PromotionsSection extends StatelessWidget {
  const _PromotionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promociones especiales',
          style: AppTypography.h3,
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              '🎉 Ofertas del día',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}