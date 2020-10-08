import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/locator.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class WorkerItem extends StatefulWidget {
  final Worker worker;
  final String workerDocId;
  final bool isSelecting;
  final bool isSelected;
  final Function addFavourite;
  final Function removeFavourite;

  final bool isFavouriteList;

  const WorkerItem(
      {Key key,
      this.worker,
      this.workerDocId,
      this.isSelecting,
      this.isSelected,
      this.addFavourite,
      this.removeFavourite,
      this.isFavouriteList})
      : super(key: key);

  @override
  _WorkerItemState createState() => _WorkerItemState();
}

class _WorkerItemState extends State<WorkerItem> {
  bool _isExpanded = false;
  bool _isFavourite = false;
  bool _isFirstTime = true;
  bool _isUpdating = false;
  AuthenticationService _authService;
  @override
  void initState() {
    super.initState();
    _authService = locator<AuthenticationService>();
  }

  initializeValues() {
    if (widget.worker.usersInterested == null) {
      _isFavourite = false;
    } else {
      _isFavourite = widget.worker.usersInterested
          .contains(FirebaseAuth.instance.currentUser.uid);
    }
  }

  void removeFavourite({String content = 'Removed from favourites'}) {
    widget.removeFavourite(widget.worker, widget.workerDocId, content);
  }

  void addFavourite({String content = 'Added to favourites'}) {
    widget.addFavourite(widget.worker, widget.workerDocId, content);
  }

  @override
  Widget build(BuildContext context) {
    // worker = Worker.fromJson(widget.workerDocument.data());
    print('Hello');
    initializeValues();
    UserType userType = _authService.getUserType;
    // print('WTF:' + worker.name);

    return GestureDetector(
      onTap: widget.isSelecting
          ? null
          : () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Container(
          decoration: widget.isSelected
              ? BoxDecoration(color: Colors.grey[300])
              : BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        widget.worker.name[0].toUpperCase(),
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        widget.worker.name,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )),
                    widget.isFavouriteList
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: widget.isSelecting || _isUpdating
                                  ? null
                                  : () {
                                      if (_isFavourite) {
                                        removeFavourite();
                                      } else {
                                        addFavourite();
                                      }
                                    },
                              child: Icon(_isFavourite
                                  ? Icons.star
                                  : Icons.star_border),
                            )),
                    InkWell(
                      onTap: widget.isSelecting
                          ? null
                          : () {
                              if (widget.isFavouriteList) {
                                removeFavourite();
                              }
                            },
                      child: widget.isFavouriteList
                          ? Icon(Icons.delete)
                          : userType == UserType.USER
                              ? Container()
                              : Icon(Icons.edit),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 55),
                        alignment: Alignment.centerLeft,
                        child: Text(widget.worker.skillType),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(_isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down),
                        onPressed: widget.isSelecting
                            ? null
                            : () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                      ),
                    )
                  ],
                ),
                if (_isExpanded)
                  Column(
                    children: [
                      Row(
                        children: [
                          Text('Phone:'),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(widget.worker.phoneNumber),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.phone,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: widget.isSelecting
                                ? null
                                : () async {
                                    try {
                                      await UrlLauncher.launch('tel://' +
                                          '+91' +
                                          widget.worker.phoneNumber);
                                    } catch (err) {
                                      print(err);
                                    }
                                  },
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text('Address:'),
                          Expanded(
                            flex: 7,
                            child: Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(widget.worker.address),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: 10,
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Text('Aadhar:'),
                            Expanded(
                              flex: 7,
                              child: Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(widget.worker.aadhar == null
                                    ? ''
                                    : widget.worker.aadhar),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: 10,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}