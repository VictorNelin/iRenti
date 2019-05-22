library catalog;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/core.dart';
import 'package:meta/meta.dart';
import 'package:irenti/model/user.dart';

export 'package:irenti/model/user.dart';

part '../model/catalog.dart';

class CatalogRepository {
  final Firestore _firestore;

  CatalogRepository({Firestore firestore})
      : _firestore = firestore ?? Firestore.instance;

  Future<List<CatalogEntry>> fetchData() async {
    QuerySnapshot q = await _firestore.collection('catalog').getDocuments();
    List<CatalogEntry> entries = [
      for (DocumentSnapshot doc in q.documents)
        CatalogEntry.fromMap(doc.reference.path.split('/').last, doc.data),
    ];
    return await Future.wait(entries.map((entry) => entry._loaded(_firestore)));
  }
}
