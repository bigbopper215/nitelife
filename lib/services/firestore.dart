import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference notesCollection = FirebaseFirestore.instance.collection('notes');
  Map<String, int> userVotes = {};
  Map<String, int> netVotesMap = {};
  User? currentUser;

  Future<void> addNote(Map<String, dynamic> noteData) async {
    await notesCollection.add(noteData);
  }

  Future<void> updateNote(String docID, Map<String, dynamic> noteData) async {
    await notesCollection.doc(docID).update(noteData);
  }

  // Gets the events by timestamp, for the new events page, 
  Stream<QuerySnapshot> getNotesStream() {
    return notesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  

  // Gets events by votes, for the popular page, pseudocode right now

  Stream<QuerySnapshot> getPopularEventsStream() {
    return notesCollection.orderBy('netvotes', descending: true).snapshots();
  }


  /*
  //Gets events by date, for the popular calendar, pseudocode right now
  I will probably need to make a helper function that sorts the events by date
  Stream<QuerySnapshot> getEventsStreamCalendar() {
    return notesCollection.orderBy('date', descending: true).snapshots();
  }
  */

  Future<void> deleteNote(String docID) async {
    await notesCollection.doc(docID).delete();
  }

  Future<void> upvoteEvent(String docID) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference documentReference = notesCollection.doc(docID);
    //DocumentReference voteReference = documentReference.collection('votes').doc(userID);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      //DocumentSnapshot voteSnapshot = await transaction.get(voteReference);
      DocumentSnapshot eventSnapshot = await transaction.get(documentReference);

      if (eventSnapshot.exists) {
        int upvotes = (eventSnapshot.data() as Map<String, dynamic>)['upvotes'] ?? 0;
        int downvotes = (eventSnapshot.data() as Map<String, dynamic>)['downvotes'] ?? 0;
        int netvotes = (eventSnapshot.data() as Map<String, dynamic>)['netvotes'] ?? 0;
        Map<String, dynamic> votes = (eventSnapshot.data() as Map<String, dynamic>)['votes'] ?? {};

        if (votes.containsKey(userID)) {
          int currentVote = votes[userID];

          if (currentVote == 1) {
            // User is removing their upvote
            transaction.update(documentReference, {
              'upvotes': upvotes - 1,
              'netvotes': netvotes - 1,
              'votes.$userID': FieldValue.delete(),
              });
              userVotes[docID] = 0;
              netVotesMap[docID] = netvotes - 1;
          } else if (currentVote == -1) {
            // User is switching from downvote to upvote
            transaction.update(documentReference, {
              'upvotes': upvotes + 1,
              'downvotes': downvotes - 1,
              'netvotes': netvotes + 2,
              'votes.$userID': 1,
            });
            userVotes[docID] = 1;
            netVotesMap[docID] = netvotes + 2;
          }
        } else {
          // User is upvoting for the first time
          transaction.update(documentReference, {
            'upvotes': upvotes + 1,
            'netvotes': netvotes + 1,
            'votes.$userID': 1,
            });
            userVotes[docID] = 1;
            netVotesMap[docID] = netvotes + 1;
        }
      }
    });
  }

  Future<void> downvoteEvent(String docID) async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference documentReference = notesCollection.doc(docID);
    //DocumentReference voteReference = documentReference.collection('votes').doc(userID);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      //DocumentSnapshot voteSnapshot = await transaction.get(voteReference);
      DocumentSnapshot eventSnapshot = await transaction.get(documentReference);

      if (eventSnapshot.exists) {
        int upvotes = (eventSnapshot.data() as Map<String, dynamic>)['upvotes'] ?? 0;
        int downvotes = (eventSnapshot.data() as Map<String, dynamic>)['downvotes'] ?? 0;
        int netvotes = (eventSnapshot.data() as Map<String, dynamic>)['netVotes'] ?? 0;
        Map<String, dynamic> votes = (eventSnapshot.data() as Map<String, dynamic>)['votes'] ?? {};


        if (votes.containsKey(userID)) {
          int currentVote = votes[userID];

          if (currentVote == -1) {
            // User is removing their downvote
            transaction.update(documentReference, {
              'downvotes': downvotes - 1,
              'netvotes': netvotes + 1,
              'votes.$userID': FieldValue.delete(),
              });
              userVotes[docID] = 0;
              netVotesMap[docID] = netvotes + 1;
          } else if (currentVote == 1) {
            // User is switching from upvote to downvote
            transaction.update(documentReference, {
              'upvotes': upvotes - 1,
              'downvotes': downvotes + 1,
              'netvotes': netvotes - 2,
              'votes.$userID': - 1,
            });
            userVotes[docID] = -1;
            netVotesMap[docID] = netvotes - 2;
          }
        } else {
          // User is downvoting for the first time
          transaction.update(documentReference, {
            'downvotes': downvotes + 1,
            'netvotes': netvotes - 1,
            'votes.$userID': - 1,
            });
            userVotes[docID] = -1;
            netVotesMap[docID] = netvotes - 1;
        }
      }
    });
  }

  Future<void> updateDocument(String docID, Map<String, dynamic> data) async {
    await notesCollection.doc(docID).update(data);
  }

  // Implementing the getDocument method
  Future<DocumentSnapshot> getDocument(String docID) async {
    return await notesCollection.doc(docID).get();
  }
}