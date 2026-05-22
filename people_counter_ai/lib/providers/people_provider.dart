import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../db/database_helper.dart';
import '../models/people_record.dart';

class PeopleProvider extends ChangeNotifier {
  int male = 0;
  int female = 0;
  int enterCount = 0;
  int exitCount = 0;

  bool isScanning = false;

  String locationName = 'หน้าห้องเรียน';
  String sessionName = 'ช่วงเช้า';
  int densityLimit = 10;

  final Set<String> detectedPersonIds = {};
  List<PeopleRecord> records = [];

  int get total => male + female;

  int get currentInside {
    final inside = enterCount - exitCount;
    return inside < 0 ? 0 : inside;
  }

  bool get isHighDensity => total >= densityLimit;

  void startScanning() {
    isScanning = true;
    notifyListeners();
  }

  void stopScanning() {
    isScanning = false;
    notifyListeners();
  }

  bool detectPerson({required String personId, required String gender}) {
    if (!isScanning) return false;

    if (detectedPersonIds.contains(personId)) {
      return false;
    }

    detectedPersonIds.add(personId);

    if (gender == 'male') {
      male++;
    } else if (gender == 'female') {
      female++;
    }

    notifyListeners();
    return true;
  }

  void simulateMale() {
    final id = 'M${DateTime.now().millisecondsSinceEpoch}';

    detectPerson(personId: id, gender: 'male');
  }

  void simulateFemale() {
    final id = 'F${DateTime.now().millisecondsSinceEpoch}';

    detectPerson(personId: id, gender: 'female');
  }

  void addEnter() {
    enterCount++;
    notifyListeners();
  }

  void addExit() {
    if (exitCount < enterCount) {
      exitCount++;
    }

    notifyListeners();
  }

  void resetSession() {
    male = 0;
    female = 0;
    enterCount = 0;
    exitCount = 0;
    detectedPersonIds.clear();

    notifyListeners();
  }

  void updateSetting({
    required String location,
    required String session,
    required int limit,
  }) {
    locationName = location;
    sessionName = session;
    densityLimit = limit;

    notifyListeners();
  }

  Future<void> saveRecord() async {
    final record = PeopleRecord(
      male: male,
      female: female,
      total: total,
      enterCount: enterCount,
      exitCount: exitCount,
      insideCount: currentInside,
      location: locationName,
      session: sessionName,
      dateTime: DateTime.now().toString(),
    );

    await DatabaseHelper.instance.insertRecord(record);
    await loadRecords();
  }

  Future<void> applyApiDetectionResult(Map<String, dynamic> data) async {
    male = _toInt(data['male']);
    female = _toInt(data['female']);
    enterCount = _toInt(data['enter']);
    exitCount = _toInt(data['exit']);

    final uniquePeople = _toInt(data['unique_people']);

    detectedPersonIds.clear();

    for (int i = 1; i <= uniquePeople; i++) {
      detectedPersonIds.add('API_$i');
    }

    notifyListeners();

    await saveRecord();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  Future<void> loadRecords() async {
    records = await DatabaseHelper.instance.getAllRecords();

    notifyListeners();
  }

  Future<void> updateRecord(PeopleRecord record) async {
    await DatabaseHelper.instance.updateRecord(record);
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseHelper.instance.deleteRecord(id);
    await loadRecords();
  }

  Future<void> deleteAllRecords() async {
    await DatabaseHelper.instance.deleteAllRecords();
    await loadRecords();
  }

  Future<void> exportPDF() async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load(
      'assets/fonts/NotoSansThai-Regular.ttf',
    );

    final thaiFont = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(base: thaiFont, bold: thaiFont),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'รายงานระบบนับจำนวนคนด้วย AI',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 16),

                pw.Text('สถานที่: $locationName'),
                pw.Text('รอบเวลา: $sessionName'),
                pw.Text('วันที่ออกรายงาน: ${DateTime.now()}'),

                pw.SizedBox(height: 16),

                pw.Text(
                  'สรุปผลล่าสุด',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text('ชาย: $male คน'),
                pw.Text('หญิง: $female คน'),
                pw.Text('รวมทั้งหมด: $total คน'),
                pw.Text('เข้า: $enterCount คน'),
                pw.Text('ออก: $exitCount คน'),
                pw.Text('คงเหลือในพื้นที่: $currentInside คน'),

                pw.SizedBox(height: 16),

                pw.Text(
                  isHighDensity
                      ? 'สถานะ: พื้นที่มีความหนาแน่นสูง'
                      : 'สถานะ: พื้นที่ปกติ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'ประวัติการตรวจจับ',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.TableHelper.fromTextArray(
                  headers: [
                    'ID',
                    'ชาย',
                    'หญิง',
                    'รวม',
                    'เข้า',
                    'ออก',
                    'คงเหลือ',
                    'สถานที่',
                    'รอบเวลา',
                  ],
                  data: records.map((record) {
                    return [
                      record.id.toString(),
                      record.male.toString(),
                      record.female.toString(),
                      record.total.toString(),
                      record.enterCount.toString(),
                      record.exitCount.toString(),
                      record.insideCount.toString(),
                      record.location,
                      record.session,
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    font: thaiFont,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                  cellStyle: pw.TextStyle(font: thaiFont, fontSize: 11),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration: const pw.BoxDecoration(),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
