import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/services.dart';

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
}
