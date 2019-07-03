import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysql1/mysql1.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/user.dart';

export 'package:irenti/model/catalog.dart';
export 'package:irenti/model/user.dart';

const List<int> _kCounts = [5, 3, 2, 3, 2];

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

  Future<List<CatalogEntry>> fetchData({String uid, List<dynamic> profile, List<String> ids, int count, int offset = 0}) async {
    _db ??= await MySqlConnection.connect(_kDbSettings);
    String query = 'select * from datapars '
        '${ids != null ? 'where id in (${ids.isEmpty ? '-1' : ids.join(',')}) ' : ''}'
        'order by id asc'
        '${ids == null ? ' limit ${offset ?? 0},$count' : ''};';
    Results q = await _db.query(query);
    List<CatalogEntry> entries = [
      for (Row row in q)
        CatalogEntry.fromMap(row['id'].toString(), row.fields),
    ];
    return await Future.wait(entries.map((entry) => _loaded(entry, _firestore, uid, profile)));
  }

  Future<CatalogEntry> _loaded(CatalogEntry on, Firestore firestore, String uid, List<dynamic> profile) async {
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
    if (profile.length == 7) profile = profile.skip(2).toList(growable: false);
    List<double> ratings = List.from(users.map<double>((u) {
      if (u.data == null || u.data.isEmpty) return 0;
      double rating = 0;
      var data = u.data.skip(2).toList(growable: false);
      for (int i = 0; i < 5; ++i) {
        final pData = profile[i];
        if (pData is num) {
          rating += _kCounts[i] / (_kCounts[i] - (data[i] - pData).abs());
        }
      }
      return rating;
    }));
    users.sort((u1, u2) => ratings[users.indexOf(u2)].compareTo(ratings[users.indexOf(u1)]));
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
      neighbors: users,
      description: on.description,
      conditions: on.conditions,
    );
  }
}
