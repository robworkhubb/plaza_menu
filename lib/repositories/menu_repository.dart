import '../core/models/menu_item.dart';

abstract class MenuRepository {
  Stream<List<MenuItem>> watchMenuItems();
  Future<MenuItem?> getMenuItemById(String id);
  Future<void> addMenuItem(MenuItem item);
  Future<void> updateMenuItem(MenuItem item);
  Future<void> deleteMenuItem(String id);

  // Paging: load page after lastDocId (nullable)
  Future<List<MenuItem>> fetchPage({int limit = 20, String? startAfterDocId});
}
