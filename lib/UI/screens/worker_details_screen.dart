import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shram/UI/utilities/header_curved_container.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/core/enums/gender.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/locator.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class WorkerDetailsScreen extends StatefulWidget {
  static const String routeName = '/worker-details';

  @override
  _WorkerDetailsScreenState createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  Worker worker;
  bool _isFavourite;
  UserType _userType;
  WorkersService _workersService;
  String workerDocId;
  // ignore: non_constant_identifier_names
  Widget Title(BuildContext context, String title) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Divider(
            color: Colors.purple[50],
            thickness: 3,
            endIndent: 30,
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _workersService = locator<WorkersService>();
    var result =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    worker = result['worker'];
    _isFavourite = result['isFavourite'];
    _userType = result['userType'];
    workerDocId = result['workerDocId'];
  }

  void removeFavourite() async {
    setState(() {
      _isFavourite = false;
    });
    if (await _workersService.checkInternetConnection()) {
      try {
        worker = await _workersService.removeFavourite(worker, workerDocId);
        print('success');
      } catch (err) {
        // please try again later
        print('failure');
        Fluttertoast.showToast(
            msg: 'Error connecting to server',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          _isFavourite = true;
        });
      }
    } else {
      // no internet connection
      Fluttertoast.showToast(
          msg: 'Check your internet connection',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _isFavourite = true;
      });
    }
  }

  Future addFavourite() async {
    setState(() {
      _isFavourite = true;
    });
    if (await _workersService.checkInternetConnection()) {
      try {
        // print('Length Before adding: ' + widget._workerList.length.toString());
        await _workersService.addFavourite(worker, workerDocId);
        print('success');
      } catch (err) {
        // please try again later
        print('failure');
        print(err);
        Fluttertoast.showToast(
            msg: 'Error connecting to server',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          _isFavourite = false;
        });
      }
    } else {
      // no internet connection
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please check your internet connection'),
        duration: Duration(
          seconds: integer.snackbar_duration,
        ),
      ));

      setState(() {
        _isFavourite = false;
      });
    }
  }

  void onUpdate() {}
  void onDelete() {}
  Future<bool> _onWillPop() async {
    Navigator.of(context).pop({'isFavourite': _isFavourite});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Details'),
              elevation: 0.0,
              actions: [
                IconButton(
                  onPressed: _isFavourite ? removeFavourite : addFavourite,
                  icon: Icon(
                      _isFavourite ? Icons.bookmark : Icons.bookmark_border),
                ),
                if (_userType == UserType.ADMIN)
                  ...[
                    IconButton(icon: Icon(Icons.edit), onPressed: onUpdate),
                    IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
                  ].toList()
                else
                  Container()
              ],
            ),
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return true;
              },
              child: SingleChildScrollView(
                child: Container(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      CustomPaint(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                        painter: HeaderCurvedContainer(),
                      ),
                      Column(
                        children: [
                          Hero(
                            tag: worker.id,
                            child: Container(
                              margin: EdgeInsets.only(top: 50),
                              padding: EdgeInsets.all(10),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 5),
                                shape: BoxShape.circle,
                                color: Colors.white,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: worker.img == null ||
                                          worker.img.isEmpty
                                      ? AssetImage(
                                          GenderHelper.getEnum(worker.gender) ==
                                                  Gender.FEMALE
                                              ? string.female_dummy
                                              : string.male_dummy)
                                      : Image.network(worker.img),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              worker.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 80,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Title(context, 'Skills'),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Is Skilled:',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                )),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  worker.isSkilled
                                                      ? 'Yes'
                                                      : 'No',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Skill Type:',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                )),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(worker.skillType,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Title(context, 'Contacts'),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          'Phone:',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 8),
                                          child: Text(
                                              '+91 ${worker.phoneNumber}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.phone,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        onPressed: () async {
                                          try {
                                            await UrlLauncher.launch('tel://' +
                                                '+91' +
                                                worker.phoneNumber);
                                          } catch (err) {
                                            print(err);
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Title(context, 'Address'),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  worker.address.isNotEmpty
                                      ? Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'House no. or Street Name:',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                )),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  worker.address,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Village:',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                          )),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            worker.village.isEmpty
                                                ? 'N/A'
                                                : worker.village,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Panchayat:',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                          )),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            worker.panchayat.isEmpty
                                                ? 'N/A'
                                                : worker.panchayat,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Block:',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                          )),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            worker.block.isEmpty
                                                ? 'N/A'
                                                : worker.block,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
