import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Search screen for finding stores and products
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buscar',
          style: AppTypography.h3,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar tiendas, productos...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Filters
            Text(
              'Filtros rápidos',
              style: AppTypography.h4,
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              children: [
                _FilterChip('Comida rápida'),
                _FilterChip('Ofertas'),
                _FilterChip('Cerca de ti'),
                _FilterChip('Mejor valoradas'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Searches
            Text(
              'Búsquedas recientes',
              style: AppTypography.h4,
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: [
                  _RecentSearchItem('Pizza italiana'),
                  _RecentSearchItem('Farmacia 24h'),
                  _RecentSearchItem('Ropa deportiva'),
                  _RecentSearchItem('Supermercado'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _FilterChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (bool selected) {},
      labelStyle: AppTypography.labelSmall,
    );
  }

  Widget _RecentSearchItem(String search) {
    return ListTile(
      leading: const Icon(Icons.history, color: AppColors.textTertiary),
      title: Text(
        search,
        style: AppTypography.bodyMedium,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.north_west, color: AppColors.textTertiary),
        onPressed: () {
          _searchController.text = search;
        },
      ),
      onTap: () {
        _searchController.text = search;
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}