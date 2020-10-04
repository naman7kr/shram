import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/services.dart';

class WorkersService extends Services {
  List<DocumentSnapshot> workerDocList = [];

  List<Map<String, Object>> favourites = [];

  WorkersService() {
    // firestore.enablePersistence().catchError((err) => print(err));
  }

  Future<void> addWorker(Worker worker) async {
    firestore.runTransaction((tx) async {
      DocumentSnapshot counterDoc = await workersCounterRef.get();
      if (counterDoc.exists) {
        worker.id = 'W${counterDoc.data()['count']}';
        await workersRef.doc().set(worker.toMap());
      } else {
        print('No counter doc exists in db');
      }
    });
  }

  Future<ResultType> addMultipleWorkers(List<Worker> workers) async {
    try {
      print('Saving');
      firestore.runTransaction((tx) async {
        for (var worker in workers) {
          DocumentSnapshot counterDoc = await workersCounterRef.get();
          if (counterDoc.exists) {
            worker.id = 'W${counterDoc.data()['count']}';
            await workersRef.doc().set(worker.toMap());
            await workersCounterRef.update({'count': FieldValue.increment(1)});
          } else {
            print('No counter doc exists in db');
          }
        }
      });

      print('LOL');
      return ResultType.SUCCESSFUL;
    } catch (err) {
      print(err);
      return ResultType.ERROR;
    }
  }

  Future<ResultType> getAllWorkers() async {
    try {
      var result = await workersRef.get();
      workerDocList = result.docs;

      return ResultType.SUCCESSFUL;
    } catch (err) {
      // error fetching the data
      return ResultType.ERROR;
    }
  }

  Future<List<DocumentSnapshot>> fetchFirstWorkersListBasedOnCategory(
      Categories cat) async {
    var result = await workersRef
        .where('skillType', isEqualTo: cat.name)
        .limit(integer.fetch_size)
        .get()
        .timeout(Duration(seconds: integer.fetch_timeout));
    print('lol');
    workerDocList = result.docs;
    return workerDocList;
  }

  Future fetchNextWorkersList(Categories cat) async {
    print('NEXT START');
    var result = await workersRef
        .where('skillType', isEqualTo: cat.name)
        .startAfterDocument(workerDocList[workerDocList.length - 1])
        .limit(integer.fetch_size)
        .get();
    print('NEXT SUCCESS');
    workerDocList.addAll(result.docs);
    return workerDocList;
  }

  Future fetchFavourites() async {
    firestore.runTransaction((transaction) async {
      var result = await userCollectionRef
          .doc(firebaseUser.uid)
          .collection('Favourites')
          .orderBy('addedOn', descending: true)
          .get();
      if (result.docs != null) {
        List<Map<String, Object>> resultList = [];
        result.docs.forEach((doc) async {
          Interests personOfInterest = Interests.fromMap(doc.data());
          var resultWorker =
              await workersRef.doc(personOfInterest.workerDocRef).get();

          resultList.add(
              {'addedOn': personOfInterest.addedOn, 'workerDoc': resultWorker});
        });
        favourites.addAll(resultList);
      }
    }).timeout(Duration(seconds: integer.fetch_timeout));
  }

  Future removeFavourite(DocumentSnapshot workerSnapshot) async {
    firestore.runTransaction((transaction) async {
      var documents = await userCollectionRef
          .doc(firebaseUser.uid)
          .collection('Favourites')
          .where('workerDocRef', isEqualTo: workerSnapshot.id)
          .get();

      await documents.docs.first.reference.delete();
      List<String> uids = workerSnapshot.data()['usersInterested'];
      uids.removeWhere((uid) => uid.compareTo(firebaseUser.uid) == 0);
      await workersRef.doc(workerSnapshot.id).update({'usersInterested': uids});
      favourites.removeWhere((favMap) =>
          (favMap['workerDoc'] as DocumentSnapshot) == workerSnapshot);
    });
  }

  Future addFavourite(DocumentSnapshot workerSnapshot) async {
    firestore.runTransaction((transaction) async {
      Timestamp addTime = Timestamp.now();
      Interests interests =
          new Interests(workerDocRef: workerSnapshot.id, addedOn: addTime);
      List<String> uids = workerSnapshot.data()['usersInterested'];
      if (uids == null) {
        uids = [];
      }
      uids.add(firebaseUser.uid);
      await userCollectionRef
          .doc(firebaseUser.uid)
          .collection('Favourites')
          .add(interests.toMap());
      await workersRef.doc(workerSnapshot.id).update({'usersInterested': uids});
      DocumentSnapshot resultWorker =
          await workersRef.doc(workerSnapshot.id).get();
      favourites.add({'addedOn': addTime, 'workerDoc': resultWorker});
    });
  }

  Future addMultipleFavourites(List<DocumentSnapshot> workerDocuments) async {
    firestore.runTransaction((transaction) async {
      workerDocuments.forEach((document) {
        addFavourite(document);
      });
    });
  }

  Future removeMultipleFavourites(
      List<DocumentSnapshot> workerDocuments) async {
    firestore.runTransaction((transaction) async {
      workerDocuments.forEach((document) {
        removeFavourite(document);
      });
    });
  }

  void dispose() {}
}
