import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plaza_menu/core/providers/auth_provider.dart';
import 'package:plaza_menu/core/providers/core_providers.dart';
import 'admin_menu_form.dart';

class AdminMenuScreen extends ConsumerWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuItemsStreamProvider);
    final authCtrl = ref.read(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Menù'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
            onPressed: () async {
              await authCtrl.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: menuAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text('Nessun prodotto. Tocca "+ Aggiungi piatto".'),
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final item = items[idx];
                final dim = item.available ? 1.0 : 0.45;
                return Opacity(
                  opacity: dim,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: item.imageUrl.isNotEmpty
                            ? Image.network(item.imageUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey[200]),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('€ ${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: item.available,
                          onChanged: (v) async {
                            final repo = ref.read(menuRepositoryProvider);
                            await repo.updateMenuItem(
                              item.copyWith(available: v),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black54),
                          tooltip: 'Modifica',
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => AdminMenuForm(menuItem: item),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black54),
                          tooltip: 'Elimina',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Conferma'),
                                content: Text('Eliminare "${item.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Annulla'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Elimina'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final repo = ref.read(menuRepositoryProvider);
                              await repo.deleteMenuItem(item.id);
                              if (item.imagePath != null &&
                                  item.imagePath!.isNotEmpty) {
                                try {
                                  await ref
                                      .read(storageServiceProvider)
                                      .deleteImageByPath(item.imagePath!);
                                } catch (e) {
                                  // ignore
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Errore: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            showDialog(context: context, builder: (_) => const AdminMenuForm()),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi piatto'),
      ),
    );
  }
}
