enum Gender { MALE, FEMALE, OTHER }

class GenderHelper {
  static String getValue(Gender type) {
    switch (type) {
      case Gender.MALE:
        return "Male";
      case Gender.FEMALE:
        return "Female";
      case Gender.OTHER:
        return 'Other';
      default:
        return 'None';
    }
  }

  static Gender getEnum(String gender) {
    switch (gender) {
      case 'Male':
        return Gender.MALE;
      case 'Female':
        return Gender.FEMALE;
      case 'Other':
        return Gender.OTHER;
      default:
        return Gender.OTHER;
    }
  }
}
