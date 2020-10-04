import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shram/core/models/worker.dart';

class WorkerItem extends StatefulWidget {
  final DocumentSnapshot workerDocument;
  final bool isSelecting;
  final bool isSelected;
  final Function removeFavourite;
  final Function addFavourite;
  WorkerItem(this.workerDocument, this.isSelecting, this.isSelected,
      this.removeFavourite, this.addFavourite);

  @override
  _WorkerItemState createState() => _WorkerItemState();
}

class _WorkerItemState extends State<WorkerItem> {
  bool _isExpanded = false;
  Worker worker;
  bool isFavourite = false;
  @override
  void initState() {
    _isExpanded = false;
    worker = Worker.fromJson(widget.workerDocument.data());
    isFavourite =
        worker.usersInterested.contains(FirebaseAuth.instance.currentUser.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        worker.name[0].toUpperCase(),
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        worker.name,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )),
                    Container(
                        margin: EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: widget.isSelecting
                              ? null
                              : () {
                                  if (isFavourite) {
                                    widget
                                        .removeFavourite(widget.workerDocument);
                                  } else {
                                    widget.addFavourite(widget.workerDocument);
                                  }
                                },
                          child: Icon(
                              isFavourite ? Icons.star : Icons.star_border),
                        )),
                    InkWell(
                      onTap: widget.isSelecting ? null : () {},
                      child: Icon(Icons.edit),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 55),
                        alignment: Alignment.centerLeft,
                        child: Text(worker.skillType),
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
                              child: Text(worker.phoneNumber),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.phone,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: widget.isSelecting ? null : () {},
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
                              child: Text(worker.address),
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
                                child: Text(worker.aadhar),
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
