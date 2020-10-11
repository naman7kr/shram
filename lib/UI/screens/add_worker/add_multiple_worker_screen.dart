import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/utilities/service_exception.dart';
import 'package:shram/UI/utilities/utils.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/viewmodel/workers_page_model.dart';

class AddMultipleScreen extends StatefulWidget {
  static const String routeName = '/add-multiple-workers';

  @override
  _AddMultipleScreenState createState() => _AddMultipleScreenState();
}

class _AddMultipleScreenState extends State<AddMultipleScreen> {
  PlatformFile file;
  List<List<dynamic>> csvTable;
  List<Worker> uploadableList = [];
  List<Map<String, Object>> errorList = [];
  bool _isProcessing = false;
  bool _isProcessingComplete = false;
  bool _isLogsOpen = false;
  bool _isLoading = false;
  bool _isUploading = false;
  int uploadingPercentage = 0;
  bool _isUploadingComplete = false;

  List<Map<String, Object>> uploadErrorList = [];
  Future _loadCSV() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null) {
        file = result.files.first;
        setState(() {});
        final File csvFile = new File(file.path);
        var data = await csvFile.readAsString();
        csvTable = CsvToListConverter().convert(data);
        print(csvTable.length);
        setState(() {
          _isProcessing = true;
        });
        processCSV(csvTable);
        setState(() {
          _isProcessing = false;
        });
        _isProcessingComplete = true;
        // print(file.name);
        // rint(file.bytes);
        // print(file.size);
        // print(file.extension);
        // print(file.path);
      }
    } catch (err) {
      Fluttertoast.showToast(
          msg: "File parsing error. Check format",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        file = null;
      });
    }
  }

  void processCSV(List<List<dynamic>> csvData) {
    errorList.clear();
    uploadableList.clear();
    HashMap<String, Map<String, String>> phoneMap = HashMap();
    HashMap<String, Map<String, String>> aadharMap = HashMap();
    for (var i = 1; i < csvData.length; i++) {
      bool hasError = false;
      var row = csvData[i];
      if (row.length != 7) {
        hasError = true;
        errorList.add({
          'row': i + 1,
          'column': -1,
          'msg': 'Number of Columns not equal to 7'
        });
        continue;
      }
      Worker worker = Worker();
      worker.name = row[1];
      if (worker.name.isEmpty || Utils.isNumeric(worker.name.trim())) {
        hasError = true;
        errorList.add({
          'row': i + 1,
          'column': 2,
          'msg': 'Name is either empty or is numeric'
        });
        continue;
      }
      if (row[2] == null || row[2].toString().trim().isEmpty) {
        hasError = true;
        errorList
            .add({'row': i + 1, 'column': 3, 'msg': 'Phone number is Empty'});
      }
      if (!Utils.isNumeric(row[2].toString().trim()) ||
          row[2].toString().trim().length != 10) {
        hasError = true;
        errorList
            .add({'row': i + 1, 'column': 3, 'msg': 'Phone number is invalid'});
        continue;
      }

      worker.phoneNumber = row[2].toString();
      if (!phoneMap.containsKey(worker.phoneNumber)) {
        phoneMap.putIfAbsent(
            worker.phoneNumber, () => {'row': '${i + 1}', 'column': '3'});
      } else {
        // already contains phone number
        hasError = true;
        errorList.add({
          'row': i + 1,
          'column': 3,
          'msg':
              'Phone number same as at line: ${phoneMap[worker.phoneNumber]['row']}'
        });
        continue;
      }
      if (row[3] == null || row[3].toString().isEmpty) {
        if (!Utils.isNumeric(row[3].toString().trim()) ||
            row[3].toString().trim().length != 12) {
          hasError = true;
          errorList.add(
              {'row': i + 1, 'column': 3, 'msg': 'Aadhar number is invalid'});
          continue;
        }
      }
      worker.aadhar = row[3].toString();
      if (!aadharMap.containsKey(worker.aadhar)) {
        aadharMap.putIfAbsent(
            worker.aadhar, () => {'row': '${i + 1}', 'column': '4'});
      } else {
        // already contains aadhar number
        hasError = true;
        errorList.add({
          'row': i + 1,
          'column': 4,
          'msg':
              'Aadhar number same as at line: ${aadharMap[worker.aadhar]['row']}'
        });
        continue;
      }
      if (row[4] == null || row[4].toString().isEmpty) {
        hasError = true;
        errorList.add({'row': i + 1, 'column': 5, 'msg': 'Address is Empty'});
        continue;
      }
      worker.address = row[4];
      if (row[5] == null || row[5].toString().isEmpty) {
        hasError = true;
        errorList.add({'row': i + 1, 'column': 6, 'msg': 'isSkilled is Empty'});
        continue;
      }
      if (row[5].toString().toLowerCase().compareTo('TRUE'.toLowerCase()) ==
              0 ||
          row[5].toString().toLowerCase().compareTo('FALSE'.toLowerCase()) ==
              0) {
        worker.isSkilled =
            row[5].toString().toLowerCase().compareTo('TRUE'.toLowerCase()) ==
                0;
      } else {
        hasError = true;
        errorList.add({'row': i + 1, 'column': 6, 'msg': 'invalid syntax'});
        continue;
      }
      if (row[6] == null || row[6].toString().isEmpty) {
        hasError = true;
        errorList.add(
            {'row': i + 1, 'column': 7, 'msg': 'SkillType cannot be empty'});
        continue;
      }

      worker.skillType = row[6];
      if (worker.isSkilled) {
        if (Constants.skilledCategories
            .where((w) => w.name.compareTo(worker.skillType) == 0)
            .isEmpty) {
          hasError = true;
          errorList.add(
              {'row': i + 1, 'column': 7, 'msg': 'SkillType is not found'});
          continue;
        }
      } else {
        if (Constants.unskilledCategories
            .where((w) => w.name.compareTo(worker.skillType) == 0)
            .isEmpty) {
          hasError = true;
          print(Constants.unskilledCategories[0].name);
          print(worker.skillType);
          errorList.add({
            'row': i + 1,
            'column': 7,
            'msg': 'Unskilled SkillType is not found'
          });
          continue;
        }
      }
      if (!hasError) {
        print(worker.toString());
        uploadableList.add(worker);
      } else {
        // handle error
      }
    }
    print(errorList.toString());
  }

  List<Widget> getList(List<Map<String, Object>> list, {isErrorList = true}) {
    if (isErrorList) {
      return [
        ...list
            .map((e) => Text('Row:' +
                e['row'].toString() +
                ' Col:' +
                e['column'].toString() +
                ' msg:' +
                e['msg']))
            .toList()
      ];
    } else {
      return [...list.map((e) => Text('msg:' + e['msg'])).toList()];
    }
  }

  Future _upload(WorkersPageModel model) async {
    setState(() {
      uploadingPercentage = 0;
      _isLoading = true;
      _isUploading = true;
      _isUploadingComplete = false;
    });
    if (await model.checkInternetConnection()) {
      uploadErrorList.clear();

      for (int i = 0; i < uploadableList.length; i++) {
        try {
          await model.addWorker(uploadableList[i]);
        } on ServiceException catch (err) {
          uploadErrorList.add({
            'msg':
                'Phone: ${uploadableList[i].phoneNumber} or Aadhar ${uploadableList[i].aadhar} already exists'
          });
        } catch (err) {
          uploadErrorList.add({'msg': err.toString()});
        }
        setState(() {
          uploadingPercentage = ((i + 1) * 100.0) ~/ uploadableList.length;
        });
      }
      setState(() {
        _isLoading = false;
        _isUploading = false;
        _isUploadingComplete = true;
      });
      Fluttertoast.showToast(
          msg: uploadableList.length - uploadErrorList.length != 0
              ? "Uploading complete"
              : "Uploading Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Check internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        uploadingPercentage = 0;
        _isLoading = false;
        _isUploading = false;
        _isUploadingComplete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<WorkersPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Add Multiple Workers'),
          ),
          body: Background(
            imageLocation: string.default_background,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: file == null
                                        ? BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black, width: 1))
                                        : BoxDecoration(),
                                    child: file != null
                                        ? Image.asset(
                                            string.csv_image,
                                            fit: BoxFit.cover,
                                          )
                                        : InkWell(
                                            onTap: _loadCSV,
                                            child: Center(
                                              child: Text(
                                                'Upload CSV',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(file != null ? file.name : ''),
                                  ),
                                ],
                              ),
                              Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: Container(
                                  child: RaisedButton(
                                    onPressed: _loadCSV,
                                    child: Text('Load CSV'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _isProcessingComplete
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        child: Text(
                                            'Workers ready to be uploaded: ${uploadableList.length}')),
                                    Container(
                                      child:
                                          Text('Errors: ${errorList.length}'),
                                    ),
                                    Container(
                                      child: errorList.length != 0
                                          ? RaisedButton(
                                              child: Text(_isLogsOpen
                                                  ? 'Hide Errors'
                                                  : 'Show Errors'),
                                              onPressed: () {
                                                if (_isLogsOpen) {
                                                  setState(() {
                                                    _isLogsOpen = false;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isLogsOpen = true;
                                                  });
                                                }
                                              },
                                            )
                                          : Container(),
                                    ),
                                    errorList.length == 0
                                        ? Text('No Errors')
                                        : _isLogsOpen
                                            ? Container(
                                                padding: EdgeInsets.all(8),
                                                height: 150,
                                                color: Colors.white,
                                                child: ListView(
                                                  children: getList(errorList),
                                                ),
                                              )
                                            : Container()
                                  ],
                                ),
                              )
                            : Container(),
                        _isProcessingComplete && uploadableList.isNotEmpty
                            ? RaisedButton(
                                onPressed: () {
                                  _upload(model);
                                },
                                child: Text('UploadAll'),
                              )
                            : Container(),
                        _isUploadingComplete && uploadErrorList.isNotEmpty
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Successful Uploads: ${uploadableList.length - uploadErrorList.length}'),
                                      Text(
                                          'Errors in Uploads: ${uploadErrorList.length}'),
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        height: 150,
                                        color: Colors.white,
                                        child: ListView(
                                          children: getList(uploadErrorList,
                                              isErrorList: false),
                                        ),
                                      ),
                                    ]),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                _isProcessing || _isLoading
                    ? Container(
                        color: Colors.black54,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 20,
                            ),
                            _isUploading
                                ? Text(
                                    '$uploadingPercentage %',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.greenAccent),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        );
      },
    );
  }
}
