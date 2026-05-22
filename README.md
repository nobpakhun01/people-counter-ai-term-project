# People Counter AI

ระบบนับจำนวนคนด้วย AI จากวิดีโอ โดยใช้ Flutter, FastAPI และ YOLO

## รายละเอียดโปรเจกต์

โปรเจกต์นี้เป็นเทอมโปรเจกต์รายวิชา Mobile Application Development  
พัฒนาแอปพลิเคชันสำหรับนับจำนวนคนจากวิดีโอ โดยใช้ Flutter เป็น Mobile App และใช้ FastAPI เป็น Web API สำหรับรับวิดีโอจากแอปไปประมวลผลด้วย YOLO และ OpenCV

ระบบสามารถตรวจจับบุคคลจากวิดีโอ แสดงจำนวนคนทั้งหมด จำนวนชาย หญิง จำนวนคนเข้า ออก และจำนวนคนคงเหลือในพื้นที่ พร้อมแสดงผลผ่าน Dashboard บันทึกประวัติลง SQLite และส่งออกรายงาน PDF ภาษาไทยได้

## เทคโนโลยีที่ใช้

- Flutter
- Dart
- Provider
- SQLite / sqflite
- FastAPI
- Python
- YOLO
- OpenCV
- PDF Export

## ฟังก์ชันหลักของระบบ

- Login
- Live Count
- Video Detection
- Dashboard
- History
- CRUD ข้อมูลประวัติ
- Setting
- Export PDF ภาษาไทย
- Web API ด้วย FastAPI
- ตรวจจับบุคคลจากวิดีโอด้วย YOLO

## โครงสร้างโปรเจกต์

```text
people-counter-ai-term-project/
├── people_counter_ai/
└── people_counter_yolo_api/