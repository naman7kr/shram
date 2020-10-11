import 'package:flutter/material.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/utilities/service_exception.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/models/worker.dart';
import 'package:shram/core/viewmodel/workers_page_model.dart';

class AddSingle extends StatefulWidget {
  static const String routeName = '/add-worker';

  @override
  _AddSingleState createState() => _AddSingleState();
}

class _AddSingleState extends State<AddSingle> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _form = GlobalKey<FormState>();

  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  int _selectedRadio = 0;
  bool initRadio = true;

  bool _isLoading = false;
  Worker _worker = Worker();
  Worker oldWorker;
  String docId;

  Categories selectedSkilled;
  Categories selectedUnskilled;
  bool isFirstTime = true;
  bool isUpdating = false;
  @override
  void initState() {
    selectedSkilled = Constants.skilledCategories[0];
    selectedUnskilled = Constants.unskilledCategories[0];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isFirstTime) {
      isFirstTime = false;
      var args =
          ModalRoute.of(context).settings.arguments as Map<String, Object>;
      // print(args);
      if (args != null) {
        // print('LOL');
        oldWorker = args['worker'];
        docId = args['docId'];
        print(oldWorker.searchAadhar);
        _worker = Worker.clone(oldWorker);
        print(_worker.searchAadhar);
        print(_worker.toString());
        initRadio = false;
        isUpdating = true;
        setState(() {
          _selectedRadio = _worker.isSkilled ? 1 : 2;
          if (_worker.isSkilled) {
            selectedSkilled = Categories(
                name: _worker.skillType, isSkilled: _worker.isSkilled);
          } else {
            selectedUnskilled = Categories(
                name: _worker.skillType, isSkilled: _worker.isSkilled);
          }
        });
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  setSelectedRadio(int val) {
    initRadio = false;
    setState(() {
      _selectedRadio = val;
    });
  }

  Widget categoriesItem(Categories cat) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (initRadio || _selectedRadio == 1) {
              selectedSkilled = cat;
            } else {
              selectedUnskilled = cat;
            }
            Navigator.of(context).pop();
          },
          child: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(cat.name)),
        ),
        Divider()
      ],
    );
  }

  List<Categories> getCategoriesData() {
    List<Categories> data;
    if (initRadio || _selectedRadio == 1) {
      data = Constants.skilledCategories;
    } else {
      data = Constants.unskilledCategories;
    }
    return data;
  }

  Future _showDialog(BuildContext context) async {
    FocusScope.of(context).unfocus();
    var data = getCategoriesData();
    return showDialog(
      context: context,
      // barrierDismissible: false,

      builder: (context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return categoriesItem(data[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Future _saveForm(WorkersPageModel model) async {
    FocusScope.of(context).unfocus();
    var isValid = _form.currentState.validate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (isValid) {
      _worker.isSkilled = _selectedRadio == 1 || initRadio ? true : false;
      if (_worker.isSkilled) {
        _worker.skillType = selectedSkilled.name;
      } else {
        _worker.skillType = selectedUnskilled.name;
      }
      _form.currentState.save();
      print(_worker.name);
      if (isUpdating && _worker.isEqualTo(oldWorker)) {
        _scaffoldKey.currentState.hideCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('No changes were made'),
          duration: Duration(seconds: integer.snackbar_duration),
        ));
        return;
      }
      print(_worker.toString());

      setState(() {
        _isLoading = true;
      });
      try {
        if (await model.checkInternetConnection()) {
          if (isUpdating) {
            await model.updateWorker(docId, _worker);
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop('Add');
          } else {
            await model.addWorker(_worker);
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop('Add');
          }
        } else {
          // handle no internet
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Check Internet Connection'),
            duration: Duration(seconds: integer.snackbar_duration),
          ));
          setState(() {
            _isLoading = false;
          });
        }
      } on ServiceException catch (_) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Phone number or Aadhar already exists'),
          duration: Duration(seconds: integer.snackbar_duration),
        ));
        setState(() {
          _isLoading = false;
        });
      } catch (err) {
        print(err);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Error Occurred. Try again later'),
          duration: Duration(seconds: integer.snackbar_duration),
        ));
        setState(() {
          _isLoading = false;
        });
        // print('WTH END');
      }
    }
  }

  int getVal() {
    if (initRadio) {
      return 1;
    } else {
      return _selectedRadio;
    }
  }

  String getCategory() {
    if (initRadio) {
      return selectedSkilled.name;
    }
    if (_selectedRadio == 1) {
      return selectedSkilled.name;
    } else {
      return selectedUnskilled.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<WorkersPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              '${isUpdating ? 'Update' : 'Add'} Worker',
              style: Theme.of(context).textTheme.headline1,
            ),
            actions: [
              FlatButton(
                onPressed: _isLoading ? null : () => _saveForm(model),
                child: InkWell(
                  child: Text(
                    'Submit',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  onTap: () => _saveForm(model),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              Background(
                imageLocation: string.default_background,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 80,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    topRight: Radius.circular(50))),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 40, left: 20, right: 20, bottom: 20),
                              child: Form(
                                key: _form,
                                child: ListView(
                                  children: [
                                    TextFormField(
                                      initialValue: _worker.name,
                                      decoration:
                                          InputDecoration(labelText: 'Name'),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context)
                                            .requestFocus(_phoneFocus);
                                      },
                                      onSaved: (val) {
                                        _worker.name = val.trim();
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please Provide Worker Name';
                                        }
                                        return null;
                                      },
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text('+91'),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: _worker.phoneNumber,
                                            focusNode: _phoneFocus,
                                            keyboardType: TextInputType.number,
                                            maxLength: 10,
                                            decoration: InputDecoration(
                                                labelText: 'Phone Number'),
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) {
                                              FocusScope.of(context).unfocus();
                                              // FocusScope.of(context)
                                              //     .requestFocus(_addressFocus);
                                            },
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please Provide Worker Phone number';
                                              }
                                              if (value.trim().length != 10) {
                                                return 'Invalid Phone number';
                                              }
                                              if (int.parse(value).isNaN) {
                                                return 'Invalid Phone number';
                                              }
                                              return null;
                                            },
                                            onSaved: (val) {
                                              _worker.phoneNumber = val.trim();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: ButtonBar(
                                        alignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Skilled'),
                                          Radio(
                                            value: 1,
                                            groupValue: getVal(),
                                            activeColor: Colors.green,
                                            onChanged: (val) {
                                              setSelectedRadio(val);
                                            },
                                          ),
                                          Text('Unskilled'),
                                          Radio(
                                            value: 2,
                                            groupValue: _selectedRadio,
                                            activeColor: Colors.green,
                                            onChanged: (val) {
                                              setSelectedRadio(val);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child:
                                                          Text(getCategory())),
                                                  onTap: () {
                                                    _showDialog(context).then(
                                                        (value) =>
                                                            setState(() {}));
                                                  },
                                                ),
                                              ),
                                              Icon(Icons.arrow_drop_down)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      initialValue: _worker.aadhar,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 12,
                                      decoration: InputDecoration(
                                          labelText: 'Aadhar Number'),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context)
                                            .requestFocus(_addressFocus);
                                      },
                                      onSaved: (val) {
                                        _worker.aadhar = val.trim();
                                      },
                                      validator: (value) {
                                        if (value.isNotEmpty &&
                                            value.length != 12) {
                                          return 'Invalid Aadhar';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      // focusNode: _addressFocus,
                                      initialValue: _worker.address,
                                      keyboardType: TextInputType.multiline,
                                      focusNode: _addressFocus,

                                      decoration:
                                          InputDecoration(labelText: 'Address'),
                                      maxLines: 4,
                                      maxLength: 200,

                                      textInputAction: TextInputAction.newline,
                                      onSaved: (val) {
                                        _worker.address = val.trim();
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please Provide Worker Address';
                                        }
                                        if (value.trim().length < 15) {
                                          return 'Should be at least 10 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          child: Text('Submit'),
                          color: Theme.of(context).accentColor,
                          onPressed: () => _saveForm(model),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _isLoading
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
