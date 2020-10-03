class Categories {
  final String name;
  final bool isSkilled;
  Categories({this.name, this.isSkilled});

  static Categories toObject(Map<String, dynamic> data) {
    return Categories(
      name: data['name'],
      isSkilled: data['isSkilled'],
    );
  }
}
