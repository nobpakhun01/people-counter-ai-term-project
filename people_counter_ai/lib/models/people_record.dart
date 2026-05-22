class PeopleRecord {
  final int? id;
  final int male;
  final int female;
  final int total;
  final int enterCount;
  final int exitCount;
  final int insideCount;
  final String location;
  final String session;
  final String dateTime;

  PeopleRecord({
    this.id,
    required this.male,
    required this.female,
    required this.total,
    required this.enterCount,
    required this.exitCount,
    required this.insideCount,
    required this.location,
    required this.session,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'male': male,
      'female': female,
      'total': total,
      'enterCount': enterCount,
      'exitCount': exitCount,
      'insideCount': insideCount,
      'location': location,
      'session': session,
      'dateTime': dateTime,
    };
  }

  factory PeopleRecord.fromMap(Map<String, dynamic> map) {
    return PeopleRecord(
      id: map['id'],
      male: map['male'] ?? 0,
      female: map['female'] ?? 0,
      total: map['total'] ?? 0,
      enterCount: map['enterCount'] ?? 0,
      exitCount: map['exitCount'] ?? 0,
      insideCount: map['insideCount'] ?? 0,
      location: map['location'] ?? 'ไม่ระบุสถานที่',
      session: map['session'] ?? 'ไม่ระบุรอบเวลา',
      dateTime: map['dateTime'] ?? '',
    );
  }
}
