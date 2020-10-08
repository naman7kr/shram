import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shram/UI/utilities/service_exception.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/core/viewmodel/BaseModel.dart';
import 'package:shram/locator.dart';

class WorkersPageModel extends BaseModel {
  final WorkersService _workersService = locator<WorkersService>();

  Future<ResultType> addMultipleWorkers(List<Worker> workers) async {
    try {
      await _workersService.addMultipleWorkers(workers);
      return ResultType.SUCCESSFUL;
    } catch (err) {
      return ResultType.ERROR;
    }
  }

  Future addWorker(Worker worker) async {
    try {
      await _workersService.addWorker(worker);
    } on ServiceException catch (exp) {
      
      throw exp;
    } catch (err) {
      throw err;
    }
  }

  Future<List<Map<String, Object>>> fetchFavourites() async {
    return await _workersService.fetchFavourites();
  }

  Future<bool> checkInternetConnection() async {
    return await _workersService.checkInternetConnection();
  }

  Future<List<DocumentSnapshot>> fetchFirstWorkersDocument(cat) {
    return _workersService.fetchFirstWorkersListBasedOnCategory(cat);
  }

  List<DocumentSnapshot> getWorkersDocument() {
    return _workersService.workerDocList;
  }
}
