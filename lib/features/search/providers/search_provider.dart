import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../stores/models/store.dart';
import '../../stores/services/store_service.dart';

/// State class for search screen
class SearchState {
  final List<Store> searchResults;
  final bool isSearching;
  final bool hasSearched;
  final String? searchError;
  final List<String> recentSearches;

  const SearchState({
    this.searchResults = const [],
    this.isSearching = false,
    this.hasSearched = false,
    this.searchError,
    this.recentSearches = const [],
  });

  SearchState copyWith({
    List<Store>? searchResults,
    bool? isSearching,
    bool? hasSearched,
    String? searchError,
    List<String>? recentSearches,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      hasSearched: hasSearched ?? this.hasSearched,
      searchError: searchError,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  SearchState clearError() {
    return copyWith(searchError: '');
  }

  SearchState clearResults() {
    return copyWith(
      searchResults: [],
      hasSearched: false,
      searchError: '',
    );
  }
}

/// Notifier class for search functionality
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState()) {
    _loadRecentSearches();
  }

  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  /// Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];
      state = state.copyWith(recentSearches: searches);
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  /// Save recent searches to SharedPreferences
  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentSearchesKey, state.recentSearches);
    } catch (e) {
      print('Error saving recent searches: $e');
    }
  }

  /// Perform search with the given query
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      state = state.clearResults();
      return;
    }

    state = state.copyWith(
      isSearching: true,
      searchError: '',
      hasSearched: true,
    );

    try {
      final result = await StoreService.searchStores(
        query: query,
        skip: 0,
        limit: 20,
      );

      if (result.success) {
        state = state.copyWith(
          searchResults: result.stores,
          isSearching: false,
        );

        // Add to recent searches
        _addToRecentSearches(query);
      } else {
        state = state.copyWith(
          searchError: result.error,
          searchResults: [],
          isSearching: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        searchError: 'Error al buscar: ${e.toString()}',
        searchResults: [],
        isSearching: false,
      );
    }
  }

  /// Add a search query to recent searches
  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;

    final updatedSearches = List<String>.from(state.recentSearches);

    // Remove if already exists
    updatedSearches.remove(query);

    // Add to beginning
    updatedSearches.insert(0, query);

    // Keep only max items
    if (updatedSearches.length > _maxRecentSearches) {
      updatedSearches.removeRange(_maxRecentSearches, updatedSearches.length);
    }

    state = state.copyWith(recentSearches: updatedSearches);
    _saveRecentSearches();
  }

  /// Remove a search query from recent searches
  void removeFromRecentSearches(String query) {
    final updatedSearches = List<String>.from(state.recentSearches);
    updatedSearches.remove(query);
    state = state.copyWith(recentSearches: updatedSearches);
    _saveRecentSearches();
  }

  /// Clear all recent searches
  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
    _saveRecentSearches();
  }

  /// Clear search results
  void clearSearch() {
    state = state.clearResults();
  }

  /// Retry the last search
  void retry(String query) {
    performSearch(query);
  }
}

/// Provider for search functionality
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);
