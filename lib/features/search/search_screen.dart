import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../stores/widgets/store_card.dart';
import 'providers/search_provider.dart';

/// Search screen for finding stores and products
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  static const int _debounceMilliseconds = 1000; // 1 second

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Called when search text changes (debounced)
  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    final query = _searchController.text.trim();

    // Clear results if query is empty
    if (query.isEmpty) {
      ref.read(searchProvider.notifier).clearSearch();
      return;
    }

    // Start new timer
    _debounceTimer = Timer(
      Duration(milliseconds: _debounceMilliseconds),
      () => ref.read(searchProvider.notifier).performSearch(query),
    );
  }

  /// Execute search with a specific query
  void _searchWithQuery(String query) {
    _searchController.text = query;
    // The listener will trigger the search automatically
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar', style: AppTypography.h3),
        actions: [
          if (searchState.recentSearches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Borrar historial',
              onPressed: () => ref.read(searchProvider.notifier).clearRecentSearches(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Buscar tiendas por nombre o ubicación...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.persianIndigo,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.persianIndigo,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Content area
          Expanded(
            child: _buildContent(searchState),
          ),
        ],
      ),
    );
  }

  /// Build the main content area based on search state
  Widget _buildContent(SearchState searchState) {
    // Show loading indicator
    if (searchState.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando tiendas...'),
          ],
        ),
      );
    }

    // Show error
    if (searchState.searchError != null && searchState.searchError!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                searchState.searchError!,
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(searchProvider.notifier).retry(_searchController.text),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Show search results
    if (searchState.hasSearched && searchState.searchResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '${searchState.searchResults.length} resultado${searchState.searchResults.length == 1 ? '' : 's'} encontrado${searchState.searchResults.length == 1 ? '' : 's'}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchState.searchResults.length,
              itemBuilder: (context, index) {
                final store = searchState.searchResults[index];
                return StoreCard(
                  store: store,
                  onTap: () {
                    context.push('/store/${store.id}');
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    // Show "no results" message
    if (searchState.hasSearched && searchState.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron tiendas',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta con otros términos de búsqueda',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show default state (recent searches and suggestions)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Filters / Suggestions
          Text('Sugerencias', style: AppTypography.h4),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Comida rápida'),
              _buildSuggestionChip('Farmacia'),
              _buildSuggestionChip('Supermercado'),
              _buildSuggestionChip('Ropa'),
              _buildSuggestionChip('Tecnología'),
              _buildSuggestionChip('Hogar'),
            ],
          ),

          if (searchState.recentSearches.isNotEmpty) ...[
            const SizedBox(height: 32),

            // Recent Searches Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Búsquedas recientes', style: AppTypography.h4),
                TextButton(
                  onPressed: () => ref.read(searchProvider.notifier).clearRecentSearches(),
                  child: Text(
                    'Borrar todo',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.persianIndigo,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Recent Searches List
            ...searchState.recentSearches.map((search) => _buildRecentSearchItem(search)),
          ],
        ],
      ),
    );
  }

  /// Build a suggestion chip
  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.persianIndigo,
      ),
      backgroundColor: AppColors.persianIndigo.withValues(alpha: 0.1),
      side: BorderSide(
        color: AppColors.persianIndigo.withValues(alpha: 0.3),
      ),
      onPressed: () => _searchWithQuery(label),
    );
  }

  /// Build a recent search item
  Widget _buildRecentSearchItem(String search) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history, color: AppColors.textTertiary),
      title: Text(search, style: AppTypography.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use this search
          IconButton(
            icon: const Icon(Icons.north_west, size: 20),
            color: AppColors.textTertiary,
            tooltip: 'Buscar',
            onPressed: () => _searchWithQuery(search),
          ),
          // Remove from history
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textTertiary,
            tooltip: 'Eliminar',
            onPressed: () => ref.read(searchProvider.notifier).removeFromRecentSearches(search),
          ),
        ],
      ),
      onTap: () => _searchWithQuery(search),
    );
  }
}
