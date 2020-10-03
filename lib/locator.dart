import 'package:get_it/get_it.dart';
import 'package:shram/core/helpers/sharedpreference_helper.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/core/services/categories_service.dart';
import 'package:shram/core/services/workers_service.dart';
import 'package:shram/core/viewmodel/categories_modal.dart';
import 'package:shram/core/viewmodel/login_page_model.dart';
import 'package:shram/core/viewmodel/search_page_model.dart';
import 'package:shram/core/viewmodel/workers_page_model.dart';

import 'core/services/search_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => WorkersService());
  locator.registerLazySingleton(() => CategoriesService());
  locator.registerLazySingleton(() => SearchService());

  locator.registerLazySingleton(() => SharedPreferenceHelper());

  locator.registerFactory(() => LoginPageModel());
  locator.registerFactory(() => CategoriesModal());
  locator.registerFactory(() => WorkersPageModel());
  locator.registerFactory(() => SearchPageModel());
}
