import 'package:flutter/material.dart';
import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/widgets/DropDownList.dart';

class MyBottomSheet extends StatefulWidget {
  final Function onSubmit;
  MyBottomSheet({@required this.onSubmit});
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  int selectedBlock = 0;
  int selectedPanchayat = -1;
  int selectedVillage = -1;

  List<String> blockNames = [];
  List<String> panchayatNames = [];
  List<String> villageNames = [];

  @override
  void initState() {
    initialiseList();
    super.initState();
  }

  void initialiseList() {
    var addressData = Constants.addressData;
    blockNames.clear();
    for (var block in addressData) {
      blockNames.add(block['name']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop()),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Search By Address',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ],
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
                      ? 'Any'
                      : Constants.addressData[selectedBlock]['name'],
                  data: blockNames,
                  onSelect: onSelectBlock),
              DropDownList(
                title: 'Panchayat',
                selectedValue: selectedPanchayat == -1
                    ? 'Any'
                    : Constants.addressData[selectedBlock]['panchayats']
                        [selectedPanchayat]['name'],
                data: getPanchayatList(),
                onSelect: onSelectPanchayat,
                isEnabled: selectedBlock == -1 ? false : true,
              ),
              DropDownList(
                title: 'Village',
                selectedValue: selectedVillage == -1
                    ? 'Any'
                    : Constants.addressData[selectedBlock]['panchayats']
                        [selectedPanchayat]['villages'][selectedVillage],
                data: getVillageList(),
                onSelect: onSelectVillage,
                isEnabled: selectedPanchayat == -1 ? false : true,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    onPressed: () {
                      widget.onSubmit(getMap());
                      Navigator.of(context).pop();
                    },
                    child: Text('Search'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
    panchayatNames.insert(0, 'Any');
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
    villageNames.insert(0, 'Any');

    return villageNames;
  }

  void onSelectBlock(int selectedPos) {
    setState(() {
      selectedBlock = selectedPos;
      selectedPanchayat = -1;
      selectedVillage = -1;
    });
  }

  void onSelectPanchayat(int selectedPos) {
    setState(() {
      selectedPanchayat = selectedPos - 1;
      selectedVillage = -1;
    });
  }

  void onSelectVillage(int selectedPos) {
    setState(() {
      selectedVillage = selectedPos - 1;
    });
  }

  Map<String, String> getMap() {
    var district = 'Hazaribag';
    var block = Constants.addressData[selectedBlock]['name'];
    var panchayat = selectedPanchayat == -1
        ? ''
        : Constants.addressData[selectedBlock]['panchayats'][selectedPanchayat]
            ['name'];
    var village = selectedVillage == -1
        ? ''
        : Constants.addressData[selectedBlock]['panchayats'][selectedPanchayat]
            ['villages'][selectedVillage];
    return {
      'district': district,
      'block': block,
      'panchayat': panchayat,
      'village': village
    };
  }
}
