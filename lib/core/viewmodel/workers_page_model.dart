import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/core/viewmodel/BaseModel.dart';
import 'package:shram/locator.dart';

class WorkersPageModel extends BaseModel {
  final WorkersService _workersService = locator<WorkersService>();

  Future<ResultType> _addMultipleWorkers(List<Worker> workers) async {
    try {
      await _workersService.addMultipleWorkers(workers);
      return ResultType.SUCCESSFUL;
    } catch (err) {
      return ResultType.ERROR;
    }
  }

  Future<bool> checkInternetConnection() async {
    return await _workersService.checkInternetConnection();
  }

  Stream<List<DocumentSnapshot>> getWorkersDocumentStream() {
    return _workersService.workerStream;
  }
}
