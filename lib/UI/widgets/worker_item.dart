import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shram/UI/screens/worker_details_screen.dart';
import 'package:shram/UI/utilities/slide_top_route.dart';
import 'package:shram/core/enums/gender.dart';
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
  final UserType userType;
  final Function addFavourite;
  final Function removeFavourite;
  final Function removeWorker;
  final Function updateWorker;

  final bool isFavouriteList;

  const WorkerItem(
      {Key key,
      this.worker,
      this.workerDocId,
      this.isSelecting,
      this.isSelected,
      this.addFavourite,
      this.removeFavourite,
      this.removeWorker,
      this.updateWorker,
      this.userType,
      this.isFavouriteList})
      : super(key: key);

  @override
  _WorkerItemState createState() => _WorkerItemState();
}

class _WorkerItemState extends State<WorkerItem> {
  bool _isExpanded = false;
  bool _isFavourite = false;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
  }

  Future initializeValues() async {
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

  void removeWorker() {
    widget.removeWorker(widget.workerDocId, widget.worker);
  }

  @override
  Widget build(BuildContext context) {
    // worker = Worker.fromJson(widget.workerDocument.data());
    print('Hello');
    initializeValues();
    print(widget.userType);
    // print('WTF:' + worker.name);

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(WorkerDetailsScreen.routeName, arguments: widget.worker),
      // widget.isSelecting
      //     ? null
      //     : () {
      //         setState(() {
      //           _isExpanded = !_isExpanded;
      //         });
      //       },
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
                    Hero(
                      tag: widget.worker.id,
                      child: CircleAvatar(
                        backgroundImage: widget.worker.img == null ||
                                widget.worker.img.isEmpty
                            ? AssetImage(
                                GenderHelper.getEnum(widget.worker.gender) ==
                                        Gender.FEMALE
                                    ? string.female_dummy
                                    : string.male_dummy)
                            : Image.network(widget.worker.img),
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            widget.worker.name,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: widget.userType == UserType.USER
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.spaceAround,
                          children: [
                            widget.isFavouriteList
                                ? Container()
                                : Container(
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
                            Container(
                              child: InkWell(
                                onTap: widget.isSelecting
                                    ? null
                                    : () {
                                        if (widget.isFavouriteList) {
                                          removeFavourite();
                                        } else {
                                          widget.updateWorker(
                                              widget.workerDocId,
                                              widget.worker);
                                        }
                                      },
                                child: widget.isFavouriteList
                                    ? Icon(Icons.delete)
                                    : widget.userType == UserType.USER
                                        ? Container()
                                        : Icon(Icons.edit),
                              ),
                            ),
                            Container(
                              child: InkWell(
                                onTap: widget.isSelecting
                                    ? null
                                    : () {
                                        removeWorker();
                                      },
                                child: widget.isFavouriteList
                                    ? Container()
                                    : widget.userType == UserType.USER
                                        ? Container()
                                        : Icon(Icons.delete),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                            'Skill Type:',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w300),
                          )),
                      Expanded(
                        flex: 5,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.worker.skillType,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Phone:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        child: Text('+91 ${widget.worker.phoneNumber}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.phone,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: () async {
                        try {
                          await UrlLauncher.launch(
                              'tel://' + '+91' + widget.worker.phoneNumber);
                        } catch (err) {
                          print(err);
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
