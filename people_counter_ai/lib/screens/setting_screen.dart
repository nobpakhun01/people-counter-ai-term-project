import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/people_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final locationController = TextEditingController();
  final limitController = TextEditingController();

  String selectedSession = 'ช่วงเช้า';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = context.read<PeopleProvider>();
      locationController.text = provider.locationName;
      selectedSession = provider.sessionName;
      limitController.text = provider.densityLimit.toString();

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeopleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xff241b35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ตั้งค่าระบบนับคน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสถานที่',
                    hintText: 'เช่น หน้าห้องเรียน',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedSession,
                  decoration: const InputDecoration(
                    labelText: 'รอบเวลา',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'ช่วงเช้า',
                      child: Text('ช่วงเช้า'),
                    ),
                    DropdownMenuItem(
                      value: 'ช่วงบ่าย',
                      child: Text('ช่วงบ่าย'),
                    ),
                    DropdownMenuItem(
                      value: 'ช่วงเย็น',
                      child: Text('ช่วงเย็น'),
                    ),
                    DropdownMenuItem(value: 'ทั้งวัน', child: Text('ทั้งวัน')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSession = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'จำนวนคนที่ถือว่าหนาแน่น',
                    hintText: 'เช่น 10',
                    prefixIcon: Icon(Icons.warning),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.updateSetting(
                        location: locationController.text,
                        session: selectedSession,
                        limit: int.tryParse(limitController.text) ?? 10,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('บันทึกการตั้งค่าเรียบร้อย'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('บันทึกการตั้งค่า'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xff241b35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ค่าปัจจุบัน',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('สถานที่: ${provider.locationName}'),
                Text('รอบเวลา: ${provider.sessionName}'),
                Text('แจ้งเตือนเมื่อเกิน: ${provider.densityLimit} คน'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
