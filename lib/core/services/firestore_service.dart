import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamCollection(
    String path, {
    Query<Map<String, dynamic>>? query,
  }) {
    final coll = (query ?? _db.collection(path));
    return coll.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  Future<Map<String, dynamic>?> getDocument(String path, String id) async {
    final doc = await _db.collection(path).doc(id).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  Future<DocumentReference> addDocument(
    String path,
    Map<String, dynamic> data,
  ) async {
    return await _db.collection(path).add(data);
  }

  Future<void> setDocument(
    String path,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(path).doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> updateDocument(
    String path,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(path).doc(id).update(data);
  }

  Future<void> deleteDocument(String path, String id) async {
    await _db.collection(path).doc(id).delete();
  }

  // Query helper for paging
  Future<QuerySnapshot> getQuerySnapshot(
    String path, {
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) {
    Query q = _db.collection(path).orderBy('name').limit(limit);
    if (startAfterDoc != null) q = q.startAfterDocument(startAfterDoc);
    return q.get();
  }
}
