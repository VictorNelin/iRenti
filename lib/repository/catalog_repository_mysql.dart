import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysql1/mysql1.dart';
import 'package:quiver/core.dart';
import 'package:meta/meta.dart';
import 'package:irenti/model/user.dart';

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

  Future<List<CatalogEntry>> fetchData({List<String> ids, int count, int offset = 0}) async {
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
    return await Future.wait(entries.map((entry) => entry._loaded(_firestore)));
  }
}

@immutable
class CatalogEntry {
  final String id;
  final int rooms;
  final double space;
  final int floor;
  final int maxFloor;
  final double cost;
  final String address;
  final List<String> photos;
  final GeoPoint location;
  final List<DocumentReference> neighborRefs;
  final List<UserData> neighbors;
  final String description;
  final String conditions;

  const CatalogEntry({
    this.id,
    this.rooms,
    this.space,
    this.floor,
    this.maxFloor,
    this.cost,
    this.address,
    this.photos,
    this.location,
    this.neighborRefs,
    this.neighbors,
    this.description,
    this.conditions,
  });

  factory CatalogEntry.fromMap(String id, Map<String, dynamic> src) {
    List<double> loc = src['geodata'].toString().split(',').map((s) => double.tryParse(s)).toList(growable: false);
    GeoPoint location = GeoPoint(loc[0], loc[1]);
    return CatalogEntry(
      id: id,
      rooms: src['roomcol'],
      space: double.tryParse(src['area']?.toString() ?? '0'),
      floor: src['floor'],
      maxFloor: src['maxFloor'],
      cost: double.tryParse(src['price']?.toString() ?? '0'),
      address: src['address']?.toString(),
      photos: (src['imgs']?.toString() ?? '').split(','),
      location: location,
      neighborRefs: List.castFrom(src['neighbors'] ?? []),
      description: src['description']?.toString(),
      conditions: src['conditions']?.toString(),
    );
  }

  Future<CatalogEntry> _loaded(Firestore firestore) async {
    List<DocumentSnapshot> snaps = await Future.wait(neighborRefs.map((ref) => ref.get()));
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
      id: id,
      rooms: rooms,
      space: space,
      floor: floor,
      maxFloor: maxFloor,
      cost: cost,
      address: address,
      photos: photos,
      location: location,
      neighborRefs: neighborRefs,
      neighbors: users,
      description: description,
      conditions: conditions,
    );
  }

  @override
  int get hashCode => hashObjects([
    id,
    rooms,
    space,
    floor,
    maxFloor,
    cost,
    address,
    photos,
    location,
    neighborRefs,
    neighbors,
    description,
    conditions,
  ]);

  @override
  bool operator ==(other) => other is CatalogEntry && hashCode == other.hashCode;
}
