import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/people_provider.dart';

class LivePeopleScreen extends StatelessWidget {
  const LivePeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeopleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('People Counter AI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cameraBox(),
            const SizedBox(height: 16),
            Text(
              provider.isScanning ? 'SCANNING ACTIVE' : 'SCANNING STOPPED',
              style: TextStyle(
                color: provider.isScanning
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'สถานที่: ${provider.locationName} | ${provider.sessionName}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xff241b35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'จำนวนคนทั้งหมด',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${provider.total}',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  Text(
                    'Unique ID: ${provider.detectedPersonIds.length}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (provider.isHighDensity)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'แจ้งเตือน: พื้นที่มีความหนาแน่นสูง',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _countCard(
                    icon: Icons.male,
                    title: 'ชาย',
                    value: provider.male,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _countCard(
                    icon: Icons.female,
                    title: 'หญิง',
                    value: provider.female,
                    color: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isScanning
                        ? provider.stopScanning
                        : provider.startScanning,
                    icon: Icon(
                      provider.isScanning ? Icons.stop : Icons.play_arrow,
                    ),
                    label: Text(provider.isScanning ? 'หยุดสแกน' : 'เริ่มสแกน'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isScanning
                          ? Colors.redAccent
                          : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.resetSession,
                    icon: const Icon(Icons.refresh),
                    label: const Text('รีเซ็ต'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.simulateMale,
                    child: const Text('+ จำลองผู้ชาย'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.simulateFemale,
                    child: const Text('+ จำลองผู้หญิง'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final added = provider.detectPerson(
                  personId: 'P001',
                  gender: 'male',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      added
                          ? 'นับคนใหม่ ID: P001'
                          : 'ตรวจพบคนเดิม ID: P001 จึงไม่นับซ้ำ',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_search),
              label: const Text('ทดสอบไม่นับคนเดิมซ้ำ ID: P001'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.addEnter,
                    icon: const Icon(Icons.login),
                    label: const Text('เข้า +1'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.addExit,
                    icon: const Icon(Icons.logout),
                    label: const Text('ออก +1'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff241b35),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text('เข้า: ${provider.enterCount} คน'),
                  Text('ออก: ${provider.exitCount} คน'),
                  Text(
                    'คงเหลือในพื้นที่: ${provider.currentInside} คน',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await provider.saveRecord();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('บันทึกผลเรียบร้อย')),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('บันทึกผล'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraBox() {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent, width: 2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=1000&q=80',
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(left: 40, top: 55, child: _detectBox('ID:P001 / MALE')),
          Positioned(right: 35, top: 80, child: _detectBox('ID:P002 / FEMALE')),
          Positioned(
            left: 130,
            bottom: 35,
            child: _detectBox('ID:P003 / MALE'),
          ),
        ],
      ),
    );
  }

  Widget _detectBox(String label) {
    return Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent, width: 2),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          color: Colors.greenAccent,
          padding: const EdgeInsets.all(3),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 8),
          ),
        ),
      ),
    );
  }

  Widget _countCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff241b35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: color),
          Text(title),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 36,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
