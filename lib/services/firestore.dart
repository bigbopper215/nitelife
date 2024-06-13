import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  //final CollectionReference notes = 
    //FirebaseFirestore.instance.collection('notes');

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addNote(Map<String, dynamic> noteData) async {
    noteData.removeWhere((key, value) => value == null);
    await _db.collection('notes').add(noteData);
  }

   Future<void> updateNote(String docID, Map<String, dynamic> noteData) async {
    noteData.removeWhere((key, value) => value == null);
    await _db.collection('notes').doc(docID).update(noteData);
  }

  Stream<QuerySnapshot> getNotesStream() {
    return _db.collection('notes').snapshots();
  }

  Future<void> deleteNote(String docID) async {
    await _db.collection('notes').doc(docID).delete();
  }

}