import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Project')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xff241b35),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'People Counter AI',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  'แอปพลิเคชันต้นแบบสำหรับนับจำนวนคน '
                  'คัดกรองชายหญิง บันทึกประวัติ แสดงผล Dashboard '
                  'และจำลองระบบไม่นับคนเดิมซ้ำด้วย Unique Person ID',
                ),

                SizedBox(height: 18),

                Text(
                  'ฟังก์ชันหลัก',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('- Login เข้าสู่ระบบ'),
                Text('- นับจำนวนคน'),
                Text('- แยกชาย / หญิง'),
                Text('- ไม่นับคนเดิมซ้ำ'),
                Text('- ระบบเข้า / ออกพื้นที่'),
                Text('- Dashboard Pie Chart และ Bar Chart'),
                Text('- บันทึกประวัติด้วย SQLite'),
                Text('- ค้นหา แก้ไข และลบประวัติ'),
                Text('- Export PDF Report'),
                Text('- ตั้งค่าสถานที่ รอบเวลา และความหนาแน่น'),

                SizedBox(height: 18),

                Text(
                  'เทคโนโลยีที่ใช้',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('- Flutter'),
                Text('- Dart'),
                Text('- Provider'),
                Text('- SQLite / sqflite'),
                Text('- fl_chart'),
                Text('- pdf / printing'),

                SizedBox(height: 18),

                Text(
                  'แนวทางพัฒนาต่อ',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('- เชื่อมต่อกล้องมือถือจริง'),
                Text('- ใช้ YOLO หรือ TensorFlow Lite ตรวจจับคน'),
                Text('- ใช้ Object Tracking เพื่อลดการนับซ้ำ'),
                Text('- เชื่อมต่อ Web API หรือ Firebase'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
