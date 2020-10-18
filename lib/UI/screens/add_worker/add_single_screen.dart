import 'package:flutter/material.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/utilities/service_exception.dart';
import 'package:shram/UI/utilities/utils.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/UI/widgets/DropDownList.dart';
import 'package:shram/core/enums/gender.dart';
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
  bool isOther = false;
  bool _isLoading = false;
  Worker _worker = Worker();
  Worker oldWorker;
  String docId;

  Categories selectedSkilled;
  Categories selectedUnskilled;

  int selectedBlock = -1;
  int selectedPanchayat = -1;
  int selectedVillage = -1;

  List<String> blockNames = [];
  List<String> panchayatNames = [];
  List<String> villageNames = [];
  List<String> categoryNames = [];
  Gender gender;

  bool isFirstTime = true;
  bool isUpdating = false;
  @override
  void initState() {
    selectedSkilled = Constants.skilledCategories[0];
    selectedUnskilled = Constants.unskilledCategories[0];
    initialiseList();
    super.initState();
  }

  void initialiseList() {
    var addressData = Constants.addressData;
    blockNames.clear();
    for (var block in addressData) {
      blockNames.add(block['name']);
    }
    blockNames.insert(0, 'N/A');
    gender = Gender.MALE;
    // print(Constants.addressData[selectedBlock]);
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

        _worker = Worker.clone(oldWorker);

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

  Future _saveForm(WorkersPageModel model) async {
    FocusScope.of(context).unfocus();
    var isValid = _form.currentState.validate();
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (isValid) {
      _worker.isSkilled = _selectedRadio == 1 || initRadio ? true : false;
      if (_worker.isSkilled) {
        _worker.skillType = selectedSkilled.name.toLowerCase();
      } else {
        _worker.skillType = selectedUnskilled.name.toLowerCase();
      }
      _worker.district = 'Hazaribag';
      _worker.block = selectedBlock == -1
          ? ''
          : Constants.addressData[selectedBlock]['name']
              .toString()
              .toLowerCase();
      _worker.panchayat = selectedPanchayat == -1
          ? ''
          : Constants.addressData[selectedBlock]['panchayats']
                  [selectedPanchayat]['name']
              .toString()
              .toLowerCase();
      _worker.village = selectedVillage == -1
          ? ''
          : Constants.addressData[selectedBlock]['panchayats']
                  [selectedPanchayat]['villages'][selectedVillage]
              .toString()
              .toLowerCase();

      _worker.gender = GenderHelper.getValue(gender);
      _worker.isOther = isOther;
      _worker.img = '';

      _form.currentState.save();
      print('yesss');
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
                                child: SingleChildScrollView(
                                  child: Column(
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
                                      DropDownList(
                                          title: 'Gender',
                                          selectedValue:
                                              GenderHelper.getValue(gender),
                                          data: ['Male', 'Female', 'Other'],
                                          onSelect: onGenderSelect),
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
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: 10,
                                              decoration: InputDecoration(
                                                  labelText: 'Phone Number'),
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                // FocusScope.of(context)
                                                //     .requestFocus(_addressFocus);
                                              },
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Please Provide Worker Phone number';
                                                }
                                                if (value.trim().length != 10 ||
                                                    !Utils.isNumeric(
                                                        value.trim())) {
                                                  return 'Invalid Phone number';
                                                }
                                                if (int.parse(value).isNaN) {
                                                  return 'Invalid Phone number';
                                                }
                                                return null;
                                              },
                                              onSaved: (val) {
                                                _worker.phoneNumber =
                                                    val.trim();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
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
                                      DropDownList(
                                          title: 'Category',
                                          selectedValue: getSelectedCategory(),
                                          data: getCategoryList(),
                                          onSelect: onSelectCategory),
                                      isOther
                                          ? TextFormField(
                                              initialValue: _worker.name,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      'Write Category Name if any'),
                                              textInputAction:
                                                  TextInputAction.next,
                                              onFieldSubmitted: (_) {
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              onSaved: (val) {
                                                if (val.isNotEmpty)
                                                  _worker.skillType =
                                                      val.trim();
                                              },
                                              validator: (value) {
                                                return null;
                                              },
                                            )
                                          : Container(),
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Text(
                                          'Address',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                        ),
                                      ),
                                      DropDownList(
                                        title: 'District',
                                        selectedValue: 'Hazaribag',
                                        data: ['Hazaribag'],
                                        onSelect: null,
                                        isEnabled: false,
                                      ),
                                      DropDownList(
                                          title: 'Block',
                                          selectedValue: selectedBlock == -1
                                              ? 'N/A'
                                              : Constants.addressData[
                                                  selectedBlock]['name'],
                                          data: blockNames,
                                          onSelect: onSelectBlock),
                                      DropDownList(
                                        title: 'Panchayat',
                                        selectedValue: selectedPanchayat == -1
                                            ? 'N/A'
                                            : Constants.addressData[
                                                    selectedBlock]['panchayats']
                                                [selectedPanchayat]['name'],
                                        data: getPanchayatList(),
                                        onSelect: onSelectPanchayat,
                                        isEnabled:
                                            selectedBlock == -1 ? false : true,
                                      ),
                                      DropDownList(
                                        title: 'Village',
                                        selectedValue: selectedVillage == -1
                                            ? 'N/A'
                                            : Constants.addressData[
                                                            selectedBlock]
                                                        ['panchayats']
                                                    [selectedPanchayat]
                                                ['villages'][selectedVillage],
                                        data: getVillageList(),
                                        onSelect: onSelectVillage,
                                        isEnabled: selectedPanchayat == -1
                                            ? false
                                            : true,
                                      ),
                                      TextFormField(
                                        // focusNode: _addressFocus,
                                        initialValue: _worker.address,
                                        keyboardType: TextInputType.multiline,
                                        focusNode: _addressFocus,

                                        decoration: InputDecoration(
                                            labelText:
                                                'House no, street name or area'),
                                        maxLines: 4,
                                        maxLength: 200,

                                        textInputAction:
                                            TextInputAction.newline,
                                        onSaved: (val) {
                                          _worker.address = val.trim();
                                        },
                                        validator: (value) {
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

  List<String> getPanchayatList() {
    panchayatNames.clear();
    if (selectedBlock == -1) {
      return [];
    }
    var panchayats = Constants.addressData[selectedBlock]['panchayats'];
    panchayatNames.clear();
    for (var panchayat in panchayats) {
      panchayatNames.add(panchayat['name']);
    }
    panchayatNames.insert(0, 'N/A');
    return panchayatNames;
  }

  List<String> getVillageList() {
    villageNames.clear();
    if (selectedPanchayat == -1) return [];
    var villages = Constants.addressData[selectedBlock]['panchayats']
        [selectedPanchayat]['villages'];
    villageNames.clear();
    if (villages != null) {
      for (var village in villages) {
        villageNames.add(village);
      }
    }
    villageNames.insert(0, 'N/A');

    return villageNames;
  }

  void onSelectBlock(int selectedPos) {
    FocusScope.of(context).unfocus();
    setState(() {
      selectedBlock = selectedPos - 1;
      selectedPanchayat = -1;
      selectedVillage = -1;
    });
  }

  void onSelectPanchayat(int selectedPos) {
    setState(() {
      selectedPanchayat = selectedPos - 1;
      selectedVillage = -1;
    });
    FocusScope.of(context).unfocus();
  }

  void onSelectVillage(int selectedPos) {
    FocusScope.of(context).unfocus();
    setState(() {
      selectedVillage = selectedPos - 1;
    });
  }

  void onGenderSelect(int selectedPos) {
    FocusScope.of(context).unfocus();
    switch (selectedPos) {
      case 0:
        gender = Gender.MALE;
        break;
      case 1:
        gender = Gender.FEMALE;
        break;
      case 2:
        gender = Gender.OTHER;
        break;
    }
    setState(() {});
  }

  getSelectedCategory() {
    if (initRadio) {
      return selectedSkilled.name;
    }
    if (_selectedRadio == 1) {
      return selectedSkilled.name;
    } else {
      return selectedUnskilled.name;
    }
  }

  onSelectCategory(int selectedPos) {
    FocusScope.of(context).unfocus();
    if (initRadio || _selectedRadio == 1) {
      selectedSkilled = Constants.skilledCategories.firstWhere(
          (cat) => cat.name.compareTo(categoryNames[selectedPos]) == 0);
      if (selectedSkilled.name
              .toLowerCase()
              .compareTo('Others'.toLowerCase()) ==
          0) {
        isOther = true;
      } else {
        isOther = false;
      }
    } else {
      isOther = false;
      selectedUnskilled = Constants.unskilledCategories.firstWhere(
          (cat) => cat.name.compareTo(categoryNames[selectedPos]) == 0);
    }
    setState(() {});
  }

  List<String> getCategoryList() {
    if (initRadio || _selectedRadio == 1) {
      categoryNames = Constants.skilledCategories.map((e) => e.name).toList();
    } else {
      categoryNames = Constants.unskilledCategories.map((e) => e.name).toList();
    }
    return categoryNames;
  }
}
