import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/subjects.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/utilities/service_exception.dart';
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

  Future addWorker(Worker worker, {String docId = ''}) async {
    return firestore.runTransaction((tx) async {
      // check if phone number or aadhar already exists...
      var existingWorkerBasedOnPhone = await workersRef
          .where('phoneNumber', isEqualTo: worker.phoneNumber)
          .get();

      if (existingWorkerBasedOnPhone.size != 0) {
        //throw worker exists exception
        // print('YO');
        throw ServiceException('Worker already exists');
      } else {
        // proceed to adding worker
        //add search heads
        worker.searchName = [];
        worker.searchPhone = [];

        for (int i = 1; i < worker.name.length + 1; i++) {
          worker.searchName.add(worker.name.substring(0, i).toLowerCase());
        }
        for (int i = 1; i < worker.phoneNumber.length + 1; i++) {
          worker.searchPhone
              .add(worker.phoneNumber.substring(0, i).toLowerCase());
        }

        // get auto generated id

        if (worker.id == null || worker.id.isEmpty) {
          DocumentSnapshot counterDoc = await workersIdCounterRef.get();

          if (counterDoc.exists) {
            worker.id = 'W${counterDoc.data()['count']}';
            await workersIdCounterRef
                .update({'count': FieldValue.increment(1)});
          } else {
            worker.id = 'W1';
            await workersIdCounterRef.set({'count': 2});
          }
        } else {
          print(worker.id);
        }
        // add worker
        if (docId == null || docId.isEmpty)
          await workersRef.doc().set(worker.toMap());
        else
          await workersRef.doc(docId).set(worker.toMap());
        // increment worker counter
        var workerCountRes = await workersCounterRef.get();
        if (workerCountRes.exists) {
          await workersCounterRef.update({'count': FieldValue.increment(1)});
        } else {
          await workersCounterRef.set({'count': 1});
        }

        // increment category counter
        var catCountRes = await categoryCounterRef.doc(worker.skillType).get();
        if (catCountRes == null || !catCountRes.exists) {
          await categoryCounterRef.doc(worker.skillType).set({'count': 1});
        } else {
          await categoryCounterRef
              .doc(worker.skillType)
              .update({'count': FieldValue.increment(1)});
        }
      }
    });
  }

  Future<ResultType> addMultipleWorkers(List<Worker> workers) async {
    try {
      // print('Saving');
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

      // print('LOL');
      return ResultType.SUCCESSFUL;
    } catch (err) {
      print(err);
      return ResultType.ERROR;
    }
  }

  Future updateWorker(String docId, Worker worker) async {
    return await workersRef.doc(docId).update(worker.toMap());
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
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;
    QuerySnapshot result;
    if (isOther) {
      result = await workersRef
          .orderBy('name')
          .where('isOther', isEqualTo: true)
          .limit(integer.fetch_size)
          .get()
          .timeout(Duration(seconds: integer.fetch_timeout));
    } else {
      result = await workersRef
          .orderBy('name')
          .where('skillType', isEqualTo: cat.name.toLowerCase())
          .limit(integer.fetch_size)
          .get()
          .timeout(Duration(seconds: integer.fetch_timeout));
    }
    // print('lol');
    workerDocList = result.docs;
    return workerDocList;
  }

  Future fetchNextWorkersList(Categories cat) async {
    // print('NEXT START');
    bool isOther = false;
    if (cat.name.compareTo('Others') == 0) isOther = true;
    QuerySnapshot result;
    if (isOther) {
      result = await workersRef
          .orderBy('name')
          .where('isOther', isEqualTo: true)
          .startAfterDocument(workerDocList[workerDocList.length - 1])
          .limit(integer.fetch_size)
          .get()
          .timeout(Duration(seconds: integer.fetch_timeout));
    } else {
      result = await workersRef
          .orderBy('name')
          .where('skillType', isEqualTo: cat.name)
          .startAfterDocument(workerDocList[workerDocList.length - 1])
          .limit(integer.fetch_size)
          .get();
    }
    // print('NEXT SUCCESS');
    workerDocList.addAll(result.docs);
    return workerDocList;
  }

  Future<List<Map<String, Object>>> fetchFavourites() async {
    return firestore
        .runTransaction<List<Map<String, Object>>>((transaction) async {
      var result = await userCollectionRef
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('Favourites')
          .orderBy('addedOn', descending: true)
          .get();
      // print(result.docs.length);

      if (result.docs != null) {
        List<Map<String, Object>> resultList = [];
        for (var doc in result.docs) {
          Interests personOfInterest = Interests.fromMap(doc.data());
          var resultWorker =
              await workersRef.doc(personOfInterest.workerDocRef).get();
          // print(resultWorker.data());
          if (resultWorker.exists) {
            resultList.add({
              'addedOn': personOfInterest.addedOn,
              'workerDoc': resultWorker
            });
          }
        }

        favourites = resultList;
        // print('Length of Fav:' + favourites.length.toString());
        return favourites;
      } else {
        // print('returning null');
        return null;
      }
    }).timeout(Duration(seconds: integer.fetch_timeout));
  }

  Future<Worker> removeFavourite(Worker worker, String id) async {
    return firestore.runTransaction((transaction) async {
      var documents = await userCollectionRef
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('Favourites')
          .where('workerDocRef', isEqualTo: id)
          .get();

      await documents.docs.first.reference.delete();
      List<String> uids = worker.usersInterested;
      uids.removeWhere(
          (uid) => uid.compareTo(FirebaseAuth.instance.currentUser.uid) == 0);

      await workersRef.doc(id).update({'usersInterested': uids});

      worker.usersInterested = uids;
      return worker;
    });
  }

  Future<Worker> addFavourite(Worker worker, String id) async {
    return firestore.runTransaction((transaction) async {
      Timestamp addTime = Timestamp.now();
      Interests interests = new Interests(workerDocRef: id, addedOn: addTime);
      List<String> uids = worker.usersInterested;
      if (uids == null) {
        uids = [];
      }
      uids.add(FirebaseAuth.instance.currentUser.uid);

      await userCollectionRef
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('Favourites')
          .add(interests.toMap());

      await workersRef.doc(id).update({'usersInterested': uids});
      worker.usersInterested = uids;

      DocumentSnapshot resultWorker = await workersRef.doc(id).get();
      if (favourites == null) favourites = [];
      favourites.add({'addedOn': addTime, 'workerDoc': resultWorker});
      // print('LOL');

      return worker;
    });
  }

  Future<Map<String, Object>> getOverviewData() {
    return firestore.runTransaction<Map<String, Object>>((transaction) async {
      var userCountResult = await userCounterRef.get();
      var userCountValue;
      var workerCountValue;
      // get user counts
      if (userCountResult.exists) {
        userCountValue = userCountResult.data()['count'];
      } else {
        userCountValue = 0;
      }

      // get workers count
      var workerCountResult = await workersCounterRef.get();
      if (workerCountResult.exists) {
        workerCountValue = workerCountResult.data()['count'];
      } else {
        workerCountValue = 0;
      }

      // get categories count
      List<QueryDocumentSnapshot> categoryCountValues;
      var categoryCountResult = await categoryCounterRef.get();
      if (categoryCountResult != null) {
        categoryCountValues = categoryCountResult.docs;
      } else {
        categoryCountValues = null;
      }
      Map<String, Object> result = {
        'user': userCountValue,
        'worker': workerCountValue,
        'category': categoryCountValues
      };
      return result;
    });
  }

  Future removeWorker(String docId, Worker worker) async {
    return firestore.runTransaction((transaction) async {
      Map<String, dynamic> deletedMap = worker.toMap();
      deletedMap.putIfAbsent('deletedOn', () => Timestamp.now());
      await deletedRef.add(deletedMap);

      var docToBeDeleted = await workersRef.doc(docId).get();
      if (docToBeDeleted.exists) {
        docToBeDeleted.reference.delete();
      }
      // decrement worker counter
      await workersCounterRef.update({'count': FieldValue.increment(-1)});
      // decrement category counter

      await categoryCounterRef
          .doc(worker.skillType)
          .update({'count': FieldValue.increment(-1)});
    }).timeout(Duration(seconds: integer.remove_timeout));
  }
  // Future addMultipleFavourites(List<DocumentSnapshot> workerDocuments) async {
  //   firestore.runTransaction((transaction) async {
  //     workerDocuments.forEach((document) {
  //       addFavourite(document);
  //     });
  //   });
  // }

  // Future removeMultipleFavourites(
  //     List<DocumentSnapshot> workerDocuments) async {
  //   firestore.runTransaction((transaction) async {
  //     workerDocuments.forEach((document) {
  //       removeFavourite(document);
  //     });
  //   });
  // }

  void dispose() {}
}
