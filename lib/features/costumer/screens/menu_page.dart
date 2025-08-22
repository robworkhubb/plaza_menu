import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plaza_menu/features/costumer/widgets/product_card.dart';
import '../../../core/providers/core_providers.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> categories = ['Tutte'];
  String selected = 'Tutte';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll listener for paging (when not using stream)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        // load next page if using paging
        final notifier = ref.read(menuPagingProvider.notifier);
        notifier.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupTabs(List items) {
    final set = <String>{};
    for (final e in items) {
      set.add((e as dynamic).categoryId as String);
    }
    categories = ['Tutte', ...set];
    // Ensure selected remains valid
    if (!categories.contains(selected)) {
      selected = 'Tutte';
    }
    // Only (re)create the controller when the number of tabs changes
    if (_tabController == null || _tabController!.length != categories.length) {
      _tabController?.dispose();
      _tabController = TabController(length: categories.length, vsync: this);
      _tabController!.addListener(() {
        if (!mounted) return;
        setState(() {
          selected = categories[_tabController!.index];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuItemsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Il nostro menù')),
      body: menuAsync.when(
        data: (items) {
          _setupTabs(items);
          final filtered = selected == 'Tutte'
              ? items
              : items.where((e) => e.categoryId == selected).toList();

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 52,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TabBar(
                          controller: _tabController!,
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(color: Colors.black, width: 2),
                          ),
                          tabs: categories
                              .map((c) => Tab(child: Text(c)))
                              .toList(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final item = filtered[idx];
                    return ProductCard(item: item);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
      ),
    );
  }
}
