part of catalog;

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
  final List<DocumentReference> neighborRefs;
  final List<UserData> neighbors;
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
    this.neighborRefs,
    this.neighbors,
    this.description,
    this.conditions,
  });

  factory CatalogEntry.fromMap(String id, Map<String, dynamic> src) {
    print(src['neighbors'][0].runtimeType);
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
      neighborRefs: List.castFrom(src['neighbors'] ?? []),
      description: src['description'],
      conditions: src['conditions'],
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
      type: type,
      rooms: rooms,
      space: space,
      floor: floor,
      maxFloor: maxFloor,
      cost: cost,
      address: address,
      photos: photos,
      location: location,
      fave: fave,
      neighborRefs: neighborRefs,
      neighbors: users,
      description: description,
      conditions: conditions,
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
    neighborRefs,
    neighbors,
    description,
    conditions,
  ]);

  @override
  bool operator ==(other) => other is CatalogEntry && hashCode == other.hashCode;
}
