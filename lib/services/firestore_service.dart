import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class FirestoreService {
  final _notesCollection = FirebaseFirestore.instance.collection('notes');

  Stream<List<Note>> getNotes(String userId) {
    return _notesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Note.fromJson(doc.id, doc.data()))
        .toList());
  }

  Future<String> addNote(String text, String uid, List<String> tags) async {
    final docRef = await _notesCollection.add({
      'text': text,
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
      'userId': uid,
    });
    return docRef.id;
  }

  Future<void> updateNote(String id, String text, {List<String> tags = const []}) async {
    await _notesCollection.doc(id).update({
      'text': text,
      'tags': tags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }

  Future<Note?> getNote(String id) async {
    final doc = await _notesCollection.doc(id).get();
    if (doc.exists) {
      return Note.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  Future<bool> noteExists(String id) async {
    final doc = await _notesCollection.doc(id).get();
    return doc.exists;
  }
}
