import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quiver/core.dart';
import 'package:meta/meta.dart';

class CatalogRepository {
  final Firestore _firestore;
  final FirebaseStorage _storage;

  CatalogRepository({Firestore firestore, FirebaseStorage storage})
      : _firestore = firestore ?? Firestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<List<CatalogEntry>> fetchData() async {
    QuerySnapshot q = await _firestore.collection('catalog').getDocuments();
    return [
      for (DocumentSnapshot doc in q.documents)
        CatalogEntry.fromMap(doc.reference.path.split('/').last, doc.data),
    ];
  }
}

@immutable
class CatalogEntry {
  final String id;
  final int type;
  final int rooms;
  final double space;
  final int floor;
  final int maxFloor;
  final double cost;
  final String address;
  final List<String> photos;
  final GeoPoint location;
  final bool fave;
  final List<String> neighbors;
  final String description;
  final String conditions;

  const CatalogEntry({
    this.id,
    this.type,
    this.rooms,
    this.space,
    this.floor,
    this.maxFloor,
    this.cost,
    this.address,
    this.photos,
    this.location,
    this.fave,
    this.neighbors,
    this.description,
    this.conditions,
  });

  factory CatalogEntry.fromMap(String id, Map<String, dynamic> src) {
    return CatalogEntry(
      id: id,
      type: src['type'],
      rooms: src['rooms'],
      space: double.tryParse(src['space']),
      floor: src['floor'],
      maxFloor: src['maxFloor'],
      cost: double.tryParse(src['cost']),
      address: src['address'],
      photos: List.castFrom(src['photos'] ?? []),
      location: src['location'],
      fave: src['fave'],
      neighbors: List.castFrom(src['neighbors'] ?? []),
      description: src['description'],
      conditions: src['conditions'],
    );
  }

  @override
  int get hashCode => hashObjects([
    id,
    type,
    rooms,
    space,
    floor,
    maxFloor,
    cost,
    address,
    photos,
    location,
    fave,
    neighbors,
    description,
    conditions,
  ]);

  @override
  bool operator ==(other) => other is CatalogEntry && hashCode == other.hashCode;
}
