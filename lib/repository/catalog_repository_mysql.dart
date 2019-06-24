import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysql1/mysql1.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/user.dart';

export 'package:irenti/model/catalog.dart';
export 'package:irenti/model/user.dart';

final ConnectionSettings _kDbSettings = ConnectionSettings(
  host: 'hodlyard.com',
  port: 3306,
  db: 'hodlyard_parsecia',
  user: 'hodlyard_user2',
  password: '768218df',
);

class CatalogRepository {
  final Firestore _firestore;
  MySqlConnection _db;

  CatalogRepository({MySqlConnection db, Firestore firestore})
      : _db = db, _firestore = firestore ?? Firestore.instance;

  Future<List<CatalogEntry>> fetchData({String uid, List<String> ids, int count, int offset = 0}) async {
    _db ??= await MySqlConnection.connect(_kDbSettings);
    String query = 'select * from datapars '
        '${ids != null ? 'where id in (${ids.isEmpty ? '-1' : ids.join(',')}) ' : ''}'
        'order by id asc'
        '${ids == null ? ' limit ${offset ?? 0},$count' : ''};';
    //print(query);
    Results q = await _db.query(query);
    List<CatalogEntry> entries = [
      for (Row row in q)
        CatalogEntry.fromMap(row['id'].toString(), row.fields),
    ];
    return await Future.wait(entries.map((entry) => _loaded(entry, _firestore, uid)));
  }

  Future<CatalogEntry> _loaded(CatalogEntry on, Firestore firestore, String uid) async {
    var snaps = (await _firestore.collection('users').where('fave', arrayContains: on.id).getDocuments()).documents;
    List<UserData> users = [
      for (DocumentSnapshot doc in snaps.where((s) => s.documentID != uid))
        UserData(
          id: doc.reference.path.split('/').last,
          displayName: doc.data['display_name'],
          photoUrl: doc.data['ava_url'],
          data: doc.data['profile']?.map((v) => v is Timestamp ? v.toDate() : v)?.toList(growable: false),
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
