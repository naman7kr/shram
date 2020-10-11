import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final String imageLocation;
  final Widget child;
  final BoxFit fit;

  Background(
      {@required this.imageLocation, this.child, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imageLocation),
            fit: fit,
          ),
        ),
        child: child,
      ),
    );
  }
}
