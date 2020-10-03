import 'package:flutter/material.dart';
import 'package:shram/UI/utilities/resources.dart';

class ConnectionError extends StatelessWidget {
  final Function onReload;
  final String imageLocation;
  final BoxFit fit;
  final double imgWidth;
  final double imgHeight;
  final String title;
  final String subtitle;

  ConnectionError({
    @required this.onReload,
    this.imageLocation = string.no_internet,
    this.fit = BoxFit.cover,
    this.imgWidth = 200,
    this.imgHeight = 100,
    this.title = string.internet_error_title,
    this.subtitle = string.internet_error_subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            Container(
                width: imgWidth,
                height: imgHeight,
                child: Image.asset(imageLocation)),
            Text(title, style: TextStyle(fontSize: 25)),
            Container(margin: EdgeInsets.only(top: 5), child: Text(subtitle)),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: onReload,
            )
          ],
        ),
      ),
    );
  }
}
