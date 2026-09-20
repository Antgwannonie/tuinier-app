/// Standplaats van een moestuin (meerdere fysieke moestuinen mogelijk).
enum TuinSpacePlace {
  outdoor,
  balcony,
  greenhouse,
  indoor,
}

extension TuinSpacePlaceLabel on TuinSpacePlace {
  String get label {
    switch (this) {
      case TuinSpacePlace.outdoor:
        return 'Buiten';
      case TuinSpacePlace.balcony:
        return 'Balkon';
      case TuinSpacePlace.greenhouse:
        return 'Kas / tunnel';
      case TuinSpacePlace.indoor:
        return 'Binnen';
    }
  }
}

/// Eén moestuin met eigen naam en plantenlijst.
class TuinSpace {
  const TuinSpace({
    required this.id,
    required this.name,
    required this.place,
    required this.plantIds,
  });

  final String id;
  final String name;
  final TuinSpacePlace place;
  final Set<String> plantIds;

  int get plantCount => plantIds.length;

  TuinSpace copyWith({
    String? name,
    TuinSpacePlace? place,
    Set<String>? plantIds,
  }) {
    return TuinSpace(
      id: id,
      name: name ?? this.name,
      place: place ?? this.place,
      plantIds: plantIds ?? this.plantIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'place': place.name,
        'plantIds': plantIds.toList()..sort(),
      };

  factory TuinSpace.fromJson(Map<String, dynamic> json) {
    return TuinSpace(
      id: json['id'] as String,
      name: json['name'] as String,
      place: TuinSpacePlace.values.byName(
        json['place'] as String? ?? TuinSpacePlace.outdoor.name,
      ),
      plantIds: (json['plantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
    );
  }
}
