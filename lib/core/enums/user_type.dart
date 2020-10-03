enum UserType { USER, ADMIN, UNKNOWN }

class UserTypeHelper {
  static String getValue(UserType userType) {
    switch (userType) {
      case UserType.USER:
        return "USER";
      case UserType.ADMIN:
        return "ADMIN";
      default:
        return 'UNKNOWN';
    }
  }

  static UserType getEnum(String userType) {
    if (userType == getValue(UserType.USER)) {
      return UserType.USER;
    } else if (userType == getValue(UserType.ADMIN)) {
      return UserType.ADMIN;
    } else {
      return UserType.UNKNOWN;
    }
  }
}
