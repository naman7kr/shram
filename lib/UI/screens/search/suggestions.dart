import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/list_type.dart';
import 'package:shram/core/models/worker.dart';

class Suggestions extends StatelessWidget {
  final List<DocumentSnapshot> _suggestionsDocument;
  final ListType type;
  final Function _onSuggestionTap;
  final Function _onSuggestionChangeQuery;
  final BuildContext ctx;

  Suggestions(this._suggestionsDocument, this.type, this._onSuggestionTap,
      this._onSuggestionChangeQuery, this.ctx);

  String getText(Worker w) {
    if (type == ListType.NAME) return w.name;
    if (type == ListType.PHONE) return w.phoneNumber;
    if (type == ListType.AADHAR) return w.aadhar;
    return '';
  }

  Widget buildList(List<DocumentSnapshot> data) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        var suggesttedText = getText(Worker.fromJson(data[i].data()));
        return ListTile(
          onTap: () => _onSuggestionTap(suggesttedText, ctx),
          title: Text(suggesttedText),
          leading: Icon(Icons.search),
          trailing: InkWell(
            onTap: () => _onSuggestionChangeQuery(suggesttedText),
            child: Transform.rotate(
                angle: 45 * pi / 180, child: Icon(Icons.arrow_back)),
          ),
        );
      },
      itemCount: data.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [buildList(_suggestionsDocument)],
        ),
      ),
    );
  }
}

// Container(
//   alignment: Alignment.topLeft,
//   margin: EdgeInsets.only(left: 10, bottom: 20, top: 20),
//   child: Text(
//     string.suggestion_address,
//     style: Theme.of(context).textTheme.headline3,
//   ),
// ),
// _resultPhone.isNotEmpty
//     ? Column(
//         children: [
//           Container(
//             alignment: Alignment.topLeft,
//             margin: EdgeInsets.only(left: 10, bottom: 20, top: 20),
//             child: Text(
//               string.suggestion_phone,
//               style: Theme.of(context).textTheme.headline3,
//             ),
//           ),
//           buildList(_resultPhone)
//         ],
//       )
//     : Container(),
// _resultAadhar.isNotEmpty
//     ? Column(
//         children: [
//           Container(
//             alignment: Alignment.topLeft,
//             margin: EdgeInsets.only(left: 10, bottom: 20, top: 20),
//             child: Text(
//               string.suggestion_aadhar,
//               style: Theme.of(context).textTheme.headline3,
//             ),
//           ),
//           buildList(_resultAadhar)
//         ],
//       )
//     : Container(),
//   ],
// ),
