import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plaza_menu/core/models/menu_item.dart';
import 'package:plaza_menu/core/services/firestore_service.dart';
import '../repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final FirestoreService _fs;
  static const _collection = 'menu_items';

  MenuRepositoryImpl(this._fs);

  @override
  Stream<List<MenuItem>> watchMenuItems() {
    return _fs
        .streamCollection(_collection)
        .map(
          (list) =>
              list.map((m) => MenuItem.fromMap(m, m['id'] as String)).toList(),
        );
  }

  @override
  Future<MenuItem?> getMenuItemById(String id) async {
    final data = await _fs.getDocument(_collection, id);
    if (data == null) return null;
    return MenuItem.fromMap(data, data['id'] as String);
  }

  @override
  Future<void> addMenuItem(MenuItem item) async {
    await _fs.addDocument(_collection, item.toMap());
  }

  @override
  Future<void> updateMenuItem(MenuItem item) async {
    await _fs.setDocument(_collection, item.id, item.toMap());
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    await _fs.deleteDocument(_collection, id);
  }

  @override
  Future<List<MenuItem>> fetchPage({
    int limit = 20,
    String? startAfterDocId,
  }) async {
    QuerySnapshot snap;
    if (startAfterDocId == null) {
      snap = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('name')
          .limit(limit)
          .get();
    } else {
      final startDoc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(startAfterDocId)
          .get();
      snap = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('name')
          .startAfterDocument(startDoc)
          .limit(limit)
          .get();
    }
    return snap.docs
        .map(
          (d) => MenuItem.fromMap({...d.data() as Map<String, dynamic>}, d.id),
        )
        .toList();
  }
}
