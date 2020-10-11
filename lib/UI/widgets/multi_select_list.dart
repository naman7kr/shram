import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:shram/UI/screens/add_worker/add_single_screen.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/favourite_item.dart';
import 'package:shram/UI/widgets/worker_item.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/locator.dart';

class MultiSelectList extends StatefulWidget {
  final MultiSelectController _multiSelectController;
  final List<Worker> _workerList;
  final List<String> _workerDocId;
  final UserType userType;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Function _callback;
  final bool isFavouriteList;

  MultiSelectList(this._multiSelectController, this._workerList,
      this._workerDocId, this.userType, this._scaffoldKey, this._callback,
      {this.isFavouriteList = false});

  @override
  _MultiSelectListState createState() => _MultiSelectListState();
}

class _MultiSelectListState extends State<MultiSelectList> {
  WorkersService _workersService;

  bool _isFirstTime = true;
  int _initialLength = 0;

  @override
  void initState() {
    super.initState();

    if (widget._workerList != null) {
      _initialLength = widget._workerList.length;
      setState(() {
        widget._multiSelectController.set(widget._workerList.length);
      });
    }
    init();
  }

  @override
  void didChangeDependencies() {
    if (_isFirstTime) {
      _isFirstTime = false;
      // init();
    }
    super.didChangeDependencies();
  }

  void init() async {
    print('KNOCK KNOCK');
    _workersService = locator<WorkersService>();
  }

  Future removeFavourite(Worker worker, String id, String content) async {
    try {
      Scaffold.of(context).hideCurrentSnackBar();

      Worker deletedWorker = worker;
      String deletedId = id;
      String firebaseUid = FirebaseAuth.instance.currentUser.uid;
      var index = widget._workerList.indexWhere((w) => w.id == worker.id);
      if (index >= 0 && index < widget._workerList.length) {
        if (widget._workerList[index].usersInterested == null) {
          widget._workerList[index].usersInterested = [];
        }
        widget._workerList[index].usersInterested
            .removeWhere((uid) => uid.compareTo(firebaseUid) == 0);
        if (widget.isFavouriteList) {
          widget._workerList.removeAt(index);
          widget._workerDocId.removeAt(index);
        }
      }
      setState(() {});

      if (await _workersService.checkInternetConnection()) {
        try {
          worker = await _workersService.removeFavourite(worker, id);

          if (content.isNotEmpty) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(content),
                duration: Duration(
                  seconds: integer.snackbar_duration,
                ),
                action: SnackBarAction(
                    label: 'UNDO',
                    textColor: Colors.blue,
                    onPressed: () {
                      addFavourite(deletedWorker, deletedId, '', pos: index);
                    })));
          }
        } catch (err) {
          // please try again later
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('There is some problem connecting to server'),
              duration: Duration(
                seconds: integer.snackbar_duration,
              ),
              action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.blue,
                  onPressed: () {
                    removeFavourite(deletedWorker, deletedId, content);
                  })));

          if (widget.isFavouriteList) {
            setState(() {
              if (index > widget._workerList.length) {
                widget._workerList.add(deletedWorker);
                widget._workerDocId.add(deletedId);
              } else {
                widget._workerList.insert(index, deletedWorker);
                widget._workerDocId.insert(index, deletedId);
              }

              print(widget._workerList.length);
            });
          }
          if (widget._workerList[index].usersInterested == null) {
            widget._workerList[index].usersInterested = [];
          }
          widget._workerList[index].usersInterested.add(firebaseUid);

          setState(() {});
        }
      } else {
        // no internet connection
        print(widget._workerList.length);

        if (widget.isFavouriteList) {
          setState(() {
            if (index > widget._workerList.length) {
              widget._workerList.add(deletedWorker);
              widget._workerDocId.add(deletedId);
            } else {
              widget._workerList.insert(index, deletedWorker);
              widget._workerDocId.insert(index, deletedId);
            }

            print(widget._workerList.length);
          });
        }
        if (widget._workerList[index].usersInterested == null) {
          widget._workerList[index].usersInterested = [];
        }
        widget._workerList[index].usersInterested.add(firebaseUid);

        setState(() {});
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Please check your internet connection'),
            duration: Duration(
              seconds: integer.snackbar_duration,
            ),
            action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.blue,
                onPressed: () {
                  removeFavourite(deletedWorker, deletedId, content);
                })));
      }
    } catch (err) {}
  }

  Future addFavourite(Worker worker, String id, String content,
      {pos = -1}) async {
    try {
      Scaffold.of(context).hideCurrentSnackBar();
      String firebaseUid = FirebaseAuth.instance.currentUser.uid;
      var index = widget._workerList.indexWhere((w) {
        print(w.id);
        print(worker.id);
        return w.id.compareTo(worker.id) == 0;
      });

      setState(() {
        if (widget._workerList[index].usersInterested == null) {
          widget._workerList[index].usersInterested = [];
        }
        print(widget._workerList[index].usersInterested.toString());
        widget._workerList[index].usersInterested.add(firebaseUid);
      });

      if (pos != -1 && widget.isFavouriteList) {
        setState(() {
          widget._workerList.insert(pos, worker);
          widget._workerDocId.insert(pos, id);
        });
        // print(
        //     'Length After adding: ' + widget._workerList.length.toString());

      }

      if (await _workersService.checkInternetConnection()) {
        try {
          // print('Length Before adding: ' + widget._workerList.length.toString());
          await _workersService.addFavourite(worker, id);
          if (content.isNotEmpty) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(content),
                duration: Duration(
                  seconds: integer.snackbar_duration,
                ),
                action: SnackBarAction(
                    label: 'UNDO',
                    textColor: Colors.blue,
                    onPressed: () {
                      removeFavourite(worker, id, content);
                    })));
            setState(() {});
          }
        } catch (err) {
          // please try again later
          print(err);
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('There is some problem connecting to server'),
              duration: Duration(
                seconds: integer.snackbar_duration,
              ),
              action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.blue,
                  onPressed: () {
                    addFavourite(worker, id, content);
                  })));
          if (widget._workerList[index].usersInterested == null) {
            widget._workerList[index].usersInterested = [];
          }
          widget._workerList[index].usersInterested
              .removeWhere((uid) => firebaseUid == uid);
          if (pos != -1 && widget.isFavouriteList) {
            widget._workerList.removeAt(pos);
            widget._workerDocId.removeAt(pos);
          }
          setState(() {});
        }
      } else {
        // no internet connection
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Please check your internet connection'),
            duration: Duration(
              seconds: integer.snackbar_duration,
            ),
            action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.blue,
                onPressed: () {
                  addFavourite(worker, id, content);
                })));
        if (widget._workerList[index].usersInterested == null) {
          widget._workerList[index].usersInterested = [];
        }
        widget._workerList[index].usersInterested
            .removeWhere((uid) => firebaseUid == uid);
        if (pos != -1 && widget.isFavouriteList) {
          widget._workerList.removeAt(pos);
          widget._workerDocId.removeAt(pos);
        }
        setState(() {});
        if (widget._workerList[index].usersInterested == null) {
          widget._workerList[index].usersInterested = [];
        }
        widget._workerList[index].usersInterested
            .removeWhere((uid) => firebaseUid == uid);
        if (pos != -1 && widget.isFavouriteList) {
          widget._workerList.removeAt(pos);
          widget._workerDocId.removeAt(pos);
        }
        setState(() {});
      }
    } catch (err) {
      print(err);
    }
  }

  Future removeWorker(String docId, Worker worker) async {
    try {
      Worker deletedWorker = worker;
      String deletedDocId = docId;
      print('COMIN');
      var index = widget._workerList.indexWhere((w) => w.id == worker.id);
      if (index >= 0 && index < widget._workerList.length) {
        widget._workerList.removeAt(index);
        widget._workerDocId.removeAt(index);
      }
      setState(() {});
      if (await _workersService.checkInternetConnection()) {
        try {
          await _workersService.removeWorker(docId, worker);
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Worker Deleted'),
              duration: Duration(
                seconds: integer.snackbar_duration,
              ),
              action: SnackBarAction(
                  label: 'UNDO',
                  textColor: Colors.blue,
                  onPressed: () {
                    // add deleted worker
                    addWorker(worker, docId, index);
                  })));
        } catch (err) {
          if (index > widget._workerList.length) {
            widget._workerList.add(deletedWorker);
            widget._workerDocId.add(deletedDocId);
          } else {
            widget._workerList.insert(index, deletedWorker);
            widget._workerDocId.insert(index, deletedDocId);
          }
          setState(() {});
        }
        // delete the worker

      } else {
        // no internet connection error
        if (index > widget._workerList.length) {
          widget._workerList.add(deletedWorker);
          widget._workerDocId.add(deletedDocId);
        } else {
          widget._workerList.insert(index, deletedWorker);
          widget._workerDocId.insert(index, deletedDocId);
        }
        setState(() {});

        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Please check your internet connection'),
            duration: Duration(
              seconds: integer.snackbar_duration,
            ),
            action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.blue,
                onPressed: () {
                  removeWorker(deletedDocId, deletedWorker);
                })));
      }
    } catch (err) {
      print(err);
    }
  }

  Future addWorker(Worker worker, String docId, int index) async {
    try {
      if (await _workersService.checkInternetConnection()) {
        await _workersService.addWorker(worker, docId: docId);
        if (index > widget._workerList.length) {
          widget._workerList.add(worker);
          widget._workerDocId.add(docId);
        } else {
          widget._workerList.insert(index, worker);
          widget._workerDocId.insert(index, docId);
        }
        setState(() {});
      } else {
        // failed to add
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Please check your internet connection'),
            duration: Duration(
              seconds: integer.snackbar_duration,
            ),
            action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.blue,
                onPressed: () {
                  addWorker(worker, docId, index);
                })));
      }
    } catch (err) {
      print(err);
    }
  }

  void updateWorker(String docId, Worker worker) async {
    try {
      var result = await Navigator.of(context).pushNamed(AddSingle.routeName,
          arguments: {'docId': docId, 'worker': worker});

      if (result != null) {
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Updated Successfully'),
          duration: Duration(seconds: integer.snackbar_duration),
        ));
        widget._callback();
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget._workerList.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, i) => MultiSelectItem(
              isSelecting: null,
              // widget._multiSelectController.isSelecting,
              onSelected: null,
              //  () {
              //   widget._callback();
              //   setState(() {
              //     widget._multiSelectController.toggle(i);
              //   });
              // },
              child: Container(
                decoration: widget._multiSelectController.isSelected(i)
                    ? BoxDecoration(color: Colors.grey[300])
                    : BoxDecoration(),
                child: WorkerItem(
                    worker: widget._workerList[i],
                    workerDocId: widget._workerDocId[i],
                    isSelecting: widget._multiSelectController.isSelecting,
                    isSelected: widget._multiSelectController.isSelected(i),
                    addFavourite: addFavourite,
                    removeFavourite: removeFavourite,
                    removeWorker: removeWorker,
                    updateWorker: updateWorker,
                    isFavouriteList: widget.isFavouriteList,
                    userType: widget.userType,
                    key: ValueKey(widget._workerDocId[i])),
              ),
            ));
  }
}
