class Categories {
  final String name;
  final bool isSkilled;
  final String img;
  Categories({this.name, this.isSkilled, this.img});

  static Categories toObject(Map<String, dynamic> data) {
    return Categories(
      name: data['name'],
      isSkilled: data['isSkilled'],
      img: data['img'],
    );
  }
}
