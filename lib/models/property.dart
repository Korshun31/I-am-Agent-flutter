class Property {
  final String id;
  final String name;
  final String code;
  final String type; // resort, house, condo
  final String? resortId;
  final String? locationId;
  final String? city;
  final String? district;
  final String? codeSuffix;
  final String? ownerId;
  final String? ownerId2;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final int? housesCount;
  final int? floors;
  final int? beachDistance;
  final int? marketDistance;
  final List<String>? photos;
  final List<String>? videos;

  Property({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.resortId,
    this.locationId,
    this.city,
    this.district,
    this.codeSuffix,
    this.ownerId,
    this.ownerId2,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.housesCount,
    this.floors,
    this.beachDistance,
    this.marketDistance,
    this.photos,
    this.videos,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? 'house',
      resortId: json['resort_id']?.toString(),
    locationId: json['location_id']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      codeSuffix: json['code_suffix']?.toString(),
      ownerId: json['owner_id']?.toString(),
      ownerId2: json['owner_id_2']?.toString(),
      bedrooms: _toInt(json['bedrooms']),
      bathrooms: _toInt(json['bathrooms']),
      area: _toDouble(json['area']),
      housesCount: _toInt(json['houses_count']),
      floors: _toInt(json['floors']),
      beachDistance: _toInt(json['beach_distance']),
      marketDistance: _toInt(json['market_distance']),
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      videos: (json['videos'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Property copyWith({
    String? name,
    String? code,
    String? type,
    String? city,
    String? district,
    int? bedrooms,
    int? bathrooms,
    double? area,
    int? beachDistance,
    int? marketDistance,
    List<String>? photos,
  }) {
    return Property(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      resortId: resortId,
      city: city ?? this.city,
      district: district ?? this.district,
      codeSuffix: codeSuffix,
      ownerId: ownerId,
      ownerId2: ownerId2,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      housesCount: housesCount,
      floors: floors,
      beachDistance: beachDistance ?? this.beachDistance,
      marketDistance: marketDistance ?? this.marketDistance,
      photos: photos ?? this.photos,
      videos: videos,
    );
  }
}
