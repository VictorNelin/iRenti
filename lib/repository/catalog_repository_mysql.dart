import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysql1/mysql1.dart';
import 'package:irenti/model/catalog.dart';
import 'package:irenti/model/user.dart';

export 'package:irenti/model/catalog.dart';
export 'package:irenti/model/user.dart';

const List<int> _kCounts = [5, 3, 2, 3, 2];

const String _kRoomCol = 'roomcol';
const String _kPrice = 'price';
const String _kMetro = 'allundergrounds';

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

  Future<List<CatalogEntry>> fetchData({
    String uid,
    List<dynamic> profile,
    List<String> ids,
    int count,
    int offset = 0,
    int roomCol,
    double priceLow,
    double priceHigh,
    List<String> metro,
  }) async {
    _db ??= await MySqlConnection.connect(_kDbSettings);
    List<String> filters = [
      if (ids != null)
        '(id in (${ids.isEmpty ? '-1' : ids.join(',')})) ',
      if (roomCol != null && roomCol >= 0)
        _roomColExpr(roomCol),
      if (priceLow != null || priceHigh != null)
        _priceExpr(priceLow, priceHigh),
      if (metro != null && metro.isNotEmpty)
        _metroExpr(metro),
    ];
    String query = filters.isEmpty ? '' : 'where ${filters.join('and ')} ';
    query = 'select * from datapars '
        '$query'
        'order by id asc'
        '${ids == null ? ' limit ${offset ?? 0},$count' : ''};';
    Results q;
    try {
      q = await _db.query(query);
    } catch (e) {
      _db = await MySqlConnection.connect(_kDbSettings);
      q = await _db.query(query);
    }
    if (q == null) {
      return <CatalogEntry>[];
    }
    List<CatalogEntry> entries = [
      for (Row row in q)
        CatalogEntry.fromMap(row['id'].toString(), row.fields),
    ];
    return await Future.wait(entries.map((entry) => _loaded(entry, _firestore, uid, profile)));
  }

  Future<int> countWith({int roomCol, double priceLow, double priceHigh, List<String> metro}) async {
    _db ??= await MySqlConnection.connect(_kDbSettings);
    List<String> filters = [
      if (roomCol != null && roomCol >= 0)
        _roomColExpr(roomCol),
      if (priceLow != null || priceHigh != null)
        _priceExpr(priceLow, priceHigh),
      if (metro != null && metro.isNotEmpty)
        _metroExpr(metro),
    ];
    String query = filters.isEmpty ? '' : ' where ${filters.join('and ')}';
    query = 'select count(id) from datapars$query';
    Results q = await _db.query(query);
    return q.single['count(id)'];
  }

  Future<List<double>> getMinMax() async {
    _db ??= await MySqlConnection.connect(_kDbSettings);
    Results q = await _db.query('select min(price),max(price) from datapars');
    return [q.single['min(price)'].toDouble(),q.single['max(price)'].toDouble()];
  }

  Future<List<CatalogEntry>> findNearby(double left, double top, double right, double bottom) async {
    _db ??= await MySqlConnection.connect(_kDbSettings);
    String query = '''select * from datapars where ST_Contains(GeomFromText('POLYGON(($left $top,$right $top,$right $bottom,$left $bottom,$left $top))'), Point(cast(substring_index(substring_index(geodata, ',', 2), ',', -1) as decimal(12, 10)), cast(substring_index(substring_index(geodata, ',', 1), ',', -1) as decimal(12, 10))))''';
    Results q = await _db.query(query);
    return [
      for (Row row in q)
        CatalogEntry.fromMap(row['id'].toString(), row.fields),
    ];
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
    if (profile?.length == 7) profile = profile.skip(2).toList(growable: false);
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
      undergrounds: on.undergrounds,
      description: on.description,
      conditions: on.conditions,
      phones: on.phones,
    );
  }

  String _roomColExpr(int roomCol) {
    switch (roomCol) {
      case 0:
        return '($_kRoomCol = 1) ';
      case 1:
        return '($_kRoomCol = 2) ';
      case 2:
        return '($_kRoomCol = 3) ';
      case 3:
        return '($_kRoomCol >= 4) ';
      default:
        return '';
    }
  }

  String _priceExpr(double low, double high) {
    return [
      if (low != null)
        '($_kPrice >= $low) ',
      if (high != null)
        '($_kPrice <= $high) ',
    ].join('and ');
  }

  String _metroExpr(List<String> metro) {
    return '(${[for (var st in metro) '$_kMetro like "%$st%"'].join(' or ')}) ';
  }
}
