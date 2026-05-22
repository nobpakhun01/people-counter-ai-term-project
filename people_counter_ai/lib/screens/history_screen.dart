import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/people_record.dart';
import '../providers/people_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String searchText = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PeopleProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeopleProvider>();

    final filteredRecords = provider.records.where((record) {
      final keyword = searchText.toLowerCase();

      return record.location.toLowerCase().contains(keyword) ||
          record.session.toLowerCase().contains(keyword) ||
          record.dateTime.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: provider.exportPDF,
            icon: const Icon(Icons.picture_as_pdf),
          ),
          IconButton(
            onPressed: provider.deleteAllRecords,
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'ค้นหาตามสถานที่ / รอบเวลา / วันที่',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xff241b35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredRecords.isEmpty
                ? const Center(
                    child: Text(
                      'ไม่พบข้อมูลประวัติ',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff241b35),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'บันทึกครั้งที่ ${record.id}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              record.dateTime,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            Text('สถานที่: ${record.location}'),
                            Text('รอบเวลา: ${record.session}'),
                            const SizedBox(height: 8),
                            Text('ชาย: ${record.male} คน'),
                            Text('หญิง: ${record.female} คน'),
                            Text('รวมทั้งหมด: ${record.total} คน'),
                            const SizedBox(height: 8),
                            Text('เข้า: ${record.enterCount} คน'),
                            Text('ออก: ${record.exitCount} คน'),
                            Text('คงเหลือในพื้นที่: ${record.insideCount} คน'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'สรุป: ${record.total} คน',
                                    style: const TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showEditDialog(context, record);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    provider.deleteRecord(record.id!);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, PeopleRecord record) {
    final maleController = TextEditingController(text: record.male.toString());
    final femaleController = TextEditingController(
      text: record.female.toString(),
    );
    final enterController = TextEditingController(
      text: record.enterCount.toString(),
    );
    final exitController = TextEditingController(
      text: record.exitCount.toString(),
    );
    final locationController = TextEditingController(text: record.location);
    final sessionController = TextEditingController(text: record.session);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('แก้ไขประวัติ'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: maleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'จำนวนผู้ชาย'),
                ),
                TextField(
                  controller: femaleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'จำนวนผู้หญิง'),
                ),
                TextField(
                  controller: enterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'จำนวนคนเข้า'),
                ),
                TextField(
                  controller: exitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'จำนวนคนออก'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'สถานที่'),
                ),
                TextField(
                  controller: sessionController,
                  decoration: const InputDecoration(labelText: 'รอบเวลา'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                final male = int.tryParse(maleController.text) ?? 0;
                final female = int.tryParse(femaleController.text) ?? 0;
                final enter = int.tryParse(enterController.text) ?? 0;
                final exit = int.tryParse(exitController.text) ?? 0;
                final inside = enter - exit < 0 ? 0 : enter - exit;

                final updatedRecord = PeopleRecord(
                  id: record.id,
                  male: male,
                  female: female,
                  total: male + female,
                  enterCount: enter,
                  exitCount: exit,
                  insideCount: inside,
                  location: locationController.text,
                  session: sessionController.text,
                  dateTime: record.dateTime,
                );

                await context.read<PeopleProvider>().updateRecord(
                  updatedRecord,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }
}
