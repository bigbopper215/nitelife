import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  //final CollectionReference notes = 
    //FirebaseFirestore.instance.collection('notes');

  final CollectionReference notesCollection = FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(Map<String, dynamic> noteData) async {
    await notesCollection.add(noteData);
  }

   Future<void> updateNote(String docID, Map<String, dynamic> noteData) async {
    await notesCollection.doc(docID).update(noteData);
  }

  Stream<QuerySnapshot> getNotesStream() {
    return notesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> deleteNote(String docID) async {
    await notesCollection.doc(docID).delete();
  }

}