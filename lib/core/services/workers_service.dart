import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/services.dart';

class WorkersService extends Services {
  List<DocumentSnapshot> documentList;

  BehaviorSubject<List<DocumentSnapshot>> workerController;
  BehaviorSubject<List<Map<String, Object>>> workerFavouriteController;

  WorkersService() {
    workerController = BehaviorSubject<List<DocumentSnapshot>>();
    workerFavouriteController = BehaviorSubject<List<Map<String, Object>>>();
    // firestore.enablePersistence().catchError((err) => print(err));
  }
  Stream<List<DocumentSnapshot>> get workerStream => workerController.stream;
  Stream<List<Map<String, Object>>> get workerFavouriteStream =>
      workerFavouriteController.stream;

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
      documentList = result.docs;

      return ResultType.SUCCESSFUL;
    } catch (err) {
      // error fetching the data
      return ResultType.ERROR;
    }
  }

  Future<ResultType> fetchFirstWorkersListBasedOnCategory(
      Categories cat) async {
    try {
      var result = await workersRef
          .where('skillType', isEqualTo: cat.name)
          .limit(integer.fetch_size)
          .get()
          .timeout(Duration(seconds: integer.fetch_timeout));
      print('lol');
      documentList = result.docs;

      workerController.sink.add(documentList);
      return ResultType.SUCCESSFUL;
    } catch (err) {
      // error fetching the data
      print(err);
      workerController.addError(err);
      return ResultType.ERROR;
    }
  }

  Future<ResultType> fetchNextWorkersList(Categories cat) async {
    try {
      print('NEXT START');
      var result = await workersRef
          .where('skillType', isEqualTo: cat.name)
          .startAfterDocument(documentList[documentList.length - 1])
          .limit(integer.fetch_size)
          .get();
      print('NEXT SUCCESS');
      documentList.addAll(result.docs);
      workerController.sink.add(documentList);
      return ResultType.SUCCESSFUL;
    } catch (err) {
      print('NEXT ERROR');
      workerController.addError(err);
      return ResultType.UNSUCCESSFUL;
    }
  }

  Future fetchFavourites() async {
    firestore.runTransaction((transaction) async {
      var result = await userCollectionRef
          .doc(firebaseUser.uid)
          .collection('Favourites')
          .orderBy('addTime', descending: true)
          .get();
      result.docs.forEach((doc) async {
        var workerDocs = await workersRef
            .where('id', isEqualTo: doc.data()['workerId'])
            .get();

        // merge the lists ...
        List<Map<String, Object>> finalList = [];
        for (var userDoc in result.docs) {
          var doc = workerDocs.docs.firstWhere(
              (element) => userDoc.data()['workerId'] == element.data()['id']);
          if (doc != null) {
            finalList.add({
              'addTime': userDoc.data()['addTime'],
              'worker': Worker.fromJson(doc.data())
            });
          }
        }
        workerFavouriteController.sink.add(finalList);
      });
    }).timeout(Duration(seconds: integer.fetch_timeout));
  }

  Future toggleFavourite(DocumentSnapshot workerDocument) async {
    Worker worker = Worker.fromJson(workerDocument.data());
    PersonOfInterest personOfInterest =
        new PersonOfInterest(workerId: worker.id, addTime: Timestamp.now());
    if (worker.popularity == null) {
      worker.popularity = [];
    }
    worker.popularity.add(Timestamp.now());
    firestore.runTransaction((transaction) async {
      final existingFavourite =  await userCollectionRef
          .doc(firebaseUser.uid)
          .collection('Favourites')
          .where('workerId', isEqualTo: worker.id)
          .get();
      if(existingFavourite.)
      await userCollectionRef
          .doc(firebaseUser.uid)
          .collection('Favourites')
          .add(personOfInterest.toMap());
      await workersRef
          .doc(workerDocument.id)
          .update({'popularity': worker.popularity});
    }).timeout(Duration(seconds: integer.update_timeout));
  }

  Future addMultipleFavourite(List<DocumentSnapshot> workerDocuments) async {}

  void dispose() {
    workerController.close();
    workerFavouriteController.close();
  }
}
