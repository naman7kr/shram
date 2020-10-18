import 'package:shared_preferences/shared_preferences.dart';
import 'package:shram/core/enums/user_type.dart';

class SharedPreferenceHelper {
  final String _loggedInUserId = '_loggedInUserId';
  final String _isLoggedIn = '_isLoggedIn';
  final String _userJsonModel = '_userJsonModel';
  final String _userType = '_userType';
  final String _addressData = '_addressData';

  Future<bool> setLoggedInUserId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_loggedInUserId, id);
  }

  Future<String> getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedInUserId) ?? '';
  }

  Future<bool> setLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isLoggedIn, true);
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedIn) ?? false;
  }

  Future<bool> setUserDetails(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userJsonModel, data);
  }

  Future<String> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userJsonModel) ?? '';
  }

  Future<bool> setUserType(UserType type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userType, UserTypeHelper.getValue(type));
  }

  Future<UserType> getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return UserTypeHelper.getEnum(prefs.getString(_userType) ?? '');
  }

  Future<bool> setAddressData(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_addressData, data);
  }

  Future<String> getAddressData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressData) ?? '';
  }

  Future<bool> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
