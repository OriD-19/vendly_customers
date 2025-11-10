import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../stores/models/store.dart';
import '../stores/services/store_service.dart';
import '../stores/widgets/store_card.dart';

/// Search screen for finding stores and products
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  // Search state
  List<Store> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _searchError;
  
  // Recent searches
  List<String> _recentSearches = [];
  
  static const int _debounceMilliseconds = 1000; // 1 second
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      if (mounted) {
        setState(() {
          _recentSearches = searches;
        });
      }
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  /// Save recent searches to SharedPreferences
  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, _recentSearches);
    } catch (e) {
      print('Error saving recent searches: $e');
    }
  }

  /// Add a search query to recent searches
  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      // Remove if already exists
      _recentSearches.remove(query);
      
      // Add to beginning
      _recentSearches.insert(0, query);
      
      // Keep only max items
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }
    });

    _saveRecentSearches();
  }

  /// Remove a search query from recent searches
  void _removeFromRecentSearches(String query) {
    setState(() {
      _recentSearches.remove(query);
    });
    _saveRecentSearches();
  }

  /// Clear all recent searches
  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
    _saveRecentSearches();
  }

  /// Called when search text changes (debounced)
  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    final query = _searchController.text.trim();

    // Clear results if query is empty
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _hasSearched = false;
        _searchError = null;
      });
      return;
    }

    // Start new timer
    _debounceTimer = Timer(
      Duration(milliseconds: _debounceMilliseconds),
      () => _performSearch(query),
    );
  }

  /// Perform the actual search
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _hasSearched = true;
    });

    try {
      final result = await StoreService.searchStores(
        query: query,
        skip: 0,
        limit: 20,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _searchResults = result.stores;
          _isSearching = false;
        });

        // Add to recent searches
        _addToRecentSearches(query);
      } else {
        setState(() {
          _searchError = result.error;
          _searchResults.clear();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _searchError = 'Error al buscar: ${e.toString()}';
        _searchResults.clear();
        _isSearching = false;
      });
    }
  }

  /// Execute search with a specific query
  void _searchWithQuery(String query) {
    _searchController.text = query;
    // The listener will trigger the search automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar', style: AppTypography.h3),
        actions: [
          if (_recentSearches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Borrar historial',
              onPressed: _clearRecentSearches,
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
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// Build the main content area based on search state
  Widget _buildContent() {
    // Show loading indicator
    if (_isSearching) {
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
    if (_searchError != null) {
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
                _searchError!,
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _performSearch(_searchController.text),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Show search results
    if (_hasSearched && _searchResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '${_searchResults.length} resultado${_searchResults.length == 1 ? '' : 's'} encontrado${_searchResults.length == 1 ? '' : 's'}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final store = _searchResults[index];
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
    if (_hasSearched && _searchResults.isEmpty) {
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

          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: 32),

            // Recent Searches Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Búsquedas recientes', style: AppTypography.h4),
                TextButton(
                  onPressed: _clearRecentSearches,
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
            ..._recentSearches.map((search) => _buildRecentSearchItem(search)),
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
            onPressed: () => _removeFromRecentSearches(search),
          ),
        ],
      ),
      onTap: () => _searchWithQuery(search),
    );
  }
}
