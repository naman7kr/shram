import 'dart:convert';

import 'package:shram/UI/utilities/constants.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/helpers/sharedpreference_helper.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/services.dart';
import 'package:http/http.dart' as http;

class CategoriesService extends Services {
  List<Categories> _categories = [];

  Future getAllCategories() async {
    _categories.clear();
    var result = await categoriesRef
        .orderBy('name')
        .get()
        .timeout(Duration(seconds: integer.fetch_timeout));

    result.docs.forEach((category) {
      _categories.add(Categories.toObject(category.data()));
    });
  }

  List<Categories> get categories => _categories;
  List<Map<String, dynamic>> dummyCategories = [
    {
      'name': 'Plumber',
      'isSkilled': true,
    },
    {
      'name': 'Weldor',
      'isSkilled': true,
    },
    {
      'name': 'Carpenter',
      'isSkilled': true,
    },
    {
      'name': 'Driver',
      'isSkilled': true,
    },
    {
      'name': 'Raj Mistry',
      'isSkilled': true,
    },
    {
      'name': 'Cook',
      'isSkilled': true,
    },
    {
      'name': 'Maid',
      'isSkilled': true,
    },
    {
      'name': 'Electrician',
      'isSkilled': true,
    },
    {
      'name': 'Painter',
      'isSkilled': true,
    },
    {
      'name': 'Guard',
      'isSkilled': true,
    },
    {
      'name': 'Building Contractor',
      'isSkilled': true,
    },
    {
      'name': 'Labour Contractor',
      'isSkilled': true,
    },
    {
      'name': 'Fitter',
      'isSkilled': true,
    },
    {
      'name': 'Driver Helper',
      'isSkilled': true,
    },
    {
      'name': 'Technician',
      'isSkilled': true,
    },
    {
      'name': 'Others',
      'isSkilled': true,
    },
    {
      'name': 'Daily Wages',
      'isSkilled': false,
    },
    {
      'name': 'Linked To Manrega',
      'isSkilled': false,
    },
  ];

  Future<void> addAllCategories() async {
    dummyCategories.forEach((value) {
      categoriesRef.add(value);
    });
  }

  Future getAddressData() async {
    var res = await storageReference
        .child('address/address_data.json')
        .getDownloadURL();
    print(res);
    var response = await http.get(res);
    var decodedRes = json.decode(response.body) as List;
    Constants.addressData.clear();
    Constants.addressData.addAll(decodedRes);
    sharedPreferencesHelper.setAddressData(response.body);
  }

  getAddressDataFromSharedPref() async {
    String data = await sharedPreferencesHelper.getAddressData();
    var decodedRes = json.decode(data) as List;
    Constants.addressData.clear();
    Constants.addressData.addAll(decodedRes);
  }
}
