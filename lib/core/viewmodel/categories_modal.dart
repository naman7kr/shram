import 'package:shram/core/models/categories.dart';
import 'package:shram/core/services/categories_service.dart';
import 'package:shram/core/viewmodel/BaseModel.dart';
import 'package:shram/locator.dart';

class CategoriesModal extends BaseModel {
  final _categoriesService = locator<CategoriesService>();
  List<Categories> getAllCategories() {
    return _categoriesService.categories;
  }

  List<Categories> getSkilledCategories() {
    final list =
        _categoriesService.categories.where((cat) => cat.isSkilled).toList();
    int othersIndex =
        list.indexWhere((cat) => cat.name.compareTo('Others') == 0);
    var val = list[othersIndex];
    list.removeAt(othersIndex);
    list.add(val);
    return list;
  }

  List<Categories> getUnSkilledCategories() {
    return _categoriesService.categories
        .where((cat) => !cat.isSkilled)
        .toList();
  }
}
