enum ListType { NAME, PHONE, ADDRESS, NONE }

class ListTypeHelper {
  static String getValue(ListType type) {
    switch (type) {
      case ListType.NAME:
        return "Name";
      case ListType.PHONE:
        return "Phone";
      case ListType.ADDRESS:
        return 'Address';
      default:
        return 'None';
    }
  }

  static ListType getEnum(int i) {
    switch (i) {
      case 1:
        return ListType.NAME;
      case 2:
        return ListType.PHONE;
      case 3:
        return ListType.ADDRESS;
      default:
        return ListType.NONE;
    }
  }
}
