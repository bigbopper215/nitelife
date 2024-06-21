import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> upvoteEvent(String docID) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference documentReference = notesCollection.doc(docID);
    DocumentReference voteReference = documentReference.collection('votes').doc(userID);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot voteSnapshot = await transaction.get(voteReference);
      DocumentSnapshot eventSnapshot = await transaction.get(documentReference);

      if (eventSnapshot.exists) {
        int upvotes = (eventSnapshot.data() as Map<String, dynamic>)['upvotes'] ?? 0;
        int downvotes = (eventSnapshot.data() as Map<String, dynamic>)['downvotes'] ?? 0;

        if (voteSnapshot.exists) {
          int currentVote = (voteSnapshot.data() as Map<String, dynamic>)['vote'];

          if (currentVote == 1) {
            // User is removing their upvote
            transaction.update(documentReference, {'upvotes': upvotes - 1});
            transaction.delete(voteReference);
          } else if (currentVote == -1) {
            // User is switching from downvote to upvote
            transaction.update(documentReference, {
              'upvotes': upvotes + 1,
              'downvotes': downvotes - 1,
            });
            transaction.update(voteReference, {'vote': 1});
          }
        } else {
          // User is upvoting for the first time
          transaction.update(documentReference, {'upvotes': upvotes + 1});
          transaction.set(voteReference, {'vote': 1});
        }
      }
    });
  }

  Future<void> downvoteEvent(String docID) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference documentReference = notesCollection.doc(docID);
    DocumentReference voteReference = documentReference.collection('votes').doc(userID);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot voteSnapshot = await transaction.get(voteReference);
      DocumentSnapshot eventSnapshot = await transaction.get(documentReference);

      if (eventSnapshot.exists) {
        int upvotes = (eventSnapshot.data() as Map<String, dynamic>)['upvotes'] ?? 0;
        int downvotes = (eventSnapshot.data() as Map<String, dynamic>)['downvotes'] ?? 0;

        if (voteSnapshot.exists) {
          int currentVote = (voteSnapshot.data() as Map<String, dynamic>)['vote'];

          if (currentVote == -1) {
            // User is removing their downvote
            transaction.update(documentReference, {'downvotes': downvotes - 1});
            transaction.delete(voteReference);
          } else if (currentVote == 1) {
            // User is switching from upvote to downvote
            transaction.update(documentReference, {
              'upvotes': upvotes - 1,
              'downvotes': downvotes + 1,
            });
            transaction.update(voteReference, {'vote': -1});
          }
        } else {
          // User is downvoting for the first time
          transaction.update(documentReference, {'downvotes': downvotes + 1});
          transaction.set(voteReference, {'vote': -1});
        }
      }
    });
  }

}