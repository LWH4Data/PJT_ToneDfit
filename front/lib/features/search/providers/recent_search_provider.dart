import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recent_search_service.dart';

/// RecentSearch Service Provider
final recentSearchServiceProvider = Provider<RecentSearchService>((ref) {
  return RecentSearchService();
});

/// RecentSearch State Notifier
class RecentSearchNotifier extends AsyncNotifier<List<String>> {
  static const int _max = 30;

  @override
  Future<List<String>> build() async {
    final service = ref.read(recentSearchServiceProvider);
    return await service.load();
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    final service = ref.read(recentSearchServiceProvider);
    final currentItems = state.hasValue ? state.value! : <String>[];
    
    final newItems = List<String>.from(currentItems);
    newItems.remove(q);
    newItems.insert(0, q);
    
    if (newItems.length > _max) {
      newItems.removeRange(_max, newItems.length);
    }
    
    await service.save(newItems);
    state = AsyncValue.data(newItems);
  }

  Future<void> remove(String query) async {
    final service = ref.read(recentSearchServiceProvider);
    final currentItems = state.hasValue ? state.value! : <String>[];
    
    final newItems = List<String>.from(currentItems);
    newItems.remove(query);
    
    await service.save(newItems);
    state = AsyncValue.data(newItems);
  }

  Future<void> clear() async {
    final service = ref.read(recentSearchServiceProvider);
    await service.save([]);
    state = const AsyncValue.data([]);
  }
}

/// RecentSearch Provider
final recentSearchProvider = AsyncNotifierProvider<RecentSearchNotifier, List<String>>(
  RecentSearchNotifier.new,
);




