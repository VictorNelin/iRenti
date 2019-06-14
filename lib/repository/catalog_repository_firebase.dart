import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/user.dart';

export 'package:irenti/model/catalog.dart';
export 'package:irenti/model/user.dart';

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
    return await Future.wait(entries.map((entry) => _loaded(entry, _firestore)));
  }

  Future<CatalogEntry> _loaded(CatalogEntry on, Firestore firestore) async {
    var snaps = await Future.wait(on.neighborIds.map((ref) => firestore.collection('users').document(ref).get()));
    List<UserData> users = [
      for (DocumentSnapshot doc in snaps)
        UserData(
          id: doc.reference.path.split('/').last,
          displayName: doc.data['display_name'],
          photoUrl: doc.data['ava_url'],
          data: doc.data['profile'].map((v) => v is Timestamp ? v.toDate() : v).toList(growable: false),
        ),
    ];
    return CatalogEntry(
      id: on.id,
      type: on.type,
      rooms: on.rooms,
      space: on.space,
      floor: on.floor,
      maxFloor: on.maxFloor,
      cost: on.cost,
      address: on.address,
      photos: on.photos,
      location: on.location,
      neighborIds: on.neighborIds,
      neighbors: users,
      description: on.description,
      conditions: on.conditions,
    );
  }
}
