import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../../repositories_impl/menu_repository_impl.dart';
import '../../repositories/menu_repository.dart';
import '../models/menu_item.dart';

// services
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

// repository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final fs = ref.read(firestoreServiceProvider);
  return MenuRepositoryImpl(fs);
});

// stream provider (realtime)
final menuItemsStreamProvider = StreamProvider.autoDispose<List<MenuItem>>((
  ref,
) {
  final repo = ref.read(menuRepositoryProvider);
  return repo.watchMenuItems();
});

// paging controller (StateNotifier)
class MenuPagingState {
  final List<MenuItem> items;
  final bool hasMore;
  final bool loading;
  final String? lastDocId;

  MenuPagingState({
    required this.items,
    required this.hasMore,
    required this.loading,
    this.lastDocId,
  });

  MenuPagingState copyWith({
    List<MenuItem>? items,
    bool? hasMore,
    bool? loading,
    String? lastDocId,
  }) {
    return MenuPagingState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      lastDocId: lastDocId ?? this.lastDocId,
    );
  }
}

class MenuPagingNotifier extends StateNotifier<MenuPagingState> {
  final MenuRepository repo;
  final int pageSize;

  MenuPagingNotifier(this.repo, {this.pageSize = 20})
    : super(MenuPagingState(items: [], hasMore: true, loading: false));

  Future<void> loadNextPage() async {
    if (state.loading || !state.hasMore) return;
    state = state.copyWith(loading: true);
    try {
      final items = await repo.fetchPage(
        limit: pageSize,
        startAfterDocId: state.lastDocId,
      );
      final hasMore = items.length == pageSize;
      final lastId = items.isNotEmpty ? items.last.id : state.lastDocId;
      state = state.copyWith(
        items: [...state.items, ...items],
        hasMore: hasMore,
        loading: false,
        lastDocId: lastId,
      );
    } catch (e) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  void reset() =>
      state = MenuPagingState(items: [], hasMore: true, loading: false);
}

final menuPagingProvider =
    StateNotifierProvider<MenuPagingNotifier, MenuPagingState>((ref) {
      final repo = ref.read(menuRepositoryProvider);
      return MenuPagingNotifier(repo, pageSize: 20);
    });
