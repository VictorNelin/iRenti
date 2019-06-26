import 'package:meta/meta.dart';
import 'package:quiver/core.dart';
import 'package:irenti/model/user.dart';

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
  final List<double> location;
  final List<UserData> neighbors;
  final String description;
  final String conditions;
  final String owner;
  final List<String> phones;

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
    this.neighbors,
    this.description,
    this.conditions,
    this.owner,
    this.phones,
  });

  factory CatalogEntry.fromMap(String id, Map<String, dynamic> src) {
    return CatalogEntry(
      id: id ?? src['id'],
      type: src['type'],
      rooms: src['roomcol'],
      space: src['area'] is double ? src['area'] : double.tryParse(src['area']?.toString() ?? '0'),
      floor: src['floor'],
      maxFloor: src['maxFloor'],
      cost: src['price'] is double ? src['price'] : double.tryParse(src['price']?.toString() ?? '0'),
      address: src['address']?.toString(),
      photos: (src['imgs']?.toString() ?? '').split(','),
      location: src['geodata']?.toString()?.split(',')?.map((s) => double.tryParse(s))?.toList(growable: false),
      description: src['description']?.toString(),
      conditions: src['conditions']?.toString(),
      owner: src['authorname']?.toString(),
      phones: src['allphones']?.toString()?.split(','),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'roomcol': rooms,
    'area': space,
    'floor': floor,
    'maxFloor': maxFloor,
    'price': cost,
    'address': address,
    'imgs': photos.join(','),
    'geodata': location.join(','),
    'description': description,
    'conditions': conditions,
    'authorname': owner,
    'allphones': phones?.join(',') ?? '',
  };

  String get costFormatted {
    List<String> parts = cost.toStringAsFixed(2).split('.');
    parts[0] = String.fromCharCodes(
      String.fromCharCodes(
        parts[0].codeUnits.reversed,
      ).replaceAllMapped(RegExp('[0-9][0-9][0-9]'), (m) => '${m.group(0)},').codeUnits.reversed,
    );
    if (parts[0].startsWith(',')) parts[0] = parts[0].substring(1);
    return parts.join('.');
  }

  String get titleFormatted => '$rooms-к квартира'
      ', ${space.toStringAsFixed(1)} м²'
      '${floor != null ? ', $floor${maxFloor != null ? '/$maxFloor' : ''} этаж' : ''}';

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
    neighbors,
    description,
    conditions,
  ]);

  @override
  bool operator ==(other) => other is CatalogEntry && hashCode == other.hashCode;
}