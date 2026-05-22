import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../providers/people_provider.dart';

class VideoDetectionScreen extends StatefulWidget {
  const VideoDetectionScreen({super.key});

  @override
  State<VideoDetectionScreen> createState() => _VideoDetectionScreenState();
}

class _VideoDetectionScreenState extends State<VideoDetectionScreen> {
  File? selectedVideo;
  Map<String, dynamic>? result;

  bool isLoading = false;
  bool useRealYolo = false;

  VideoPlayerController? originalController;
  VideoPlayerController? resultController;

  /*
    Android Emulator ใช้: http://10.0.2.2:8000
    Windows Desktop ใช้: http://127.0.0.1:8000
    มือถือจริง ใช้ IP คอม เช่น http://192.168.1.xx:8000
  */
  final String baseApiUrl = 'http://10.0.2.2:8000';

  Future<void> pickVideo() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.video);

    if (picked == null || picked.files.single.path == null) {
      return;
    }

    final file = File(picked.files.single.path!);

    await originalController?.dispose();
    await resultController?.dispose();

    originalController = VideoPlayerController.file(file);
    await originalController!.initialize();

    setState(() {
      selectedVideo = file;
      result = null;
      resultController = null;
    });
  }

  Future<void> uploadVideo() async {
    if (selectedVideo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกวิดีโอก่อน')));
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      final mode = useRealYolo ? 'real' : 'mock';
      final uri = Uri.parse('$baseApiUrl/detect-video?mode=$mode');

      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', selectedVideo!.path),
      );

      final response = await request.send().timeout(
        const Duration(minutes: 10),
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Detection failed');
      }

      final videoUrl = data['output_video_url'];

      await resultController?.dispose();

      resultController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await resultController!.initialize();

      /*
        จุดสำคัญ:
        ส่งผลจาก API ไปอัปเดต PeopleProvider
        เพื่อให้ข้อมูลไปแสดงใน Dashboard และบันทึกเข้า History
      */
      if (context.mounted) {
        await context.read<PeopleProvider>().applyApiDetectionResult(data);
      }

      setState(() {
        result = data;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ตรวจจับวิดีโอและบันทึกผลเรียบร้อย')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ตรวจจับวิดีโอไม่สำเร็จ: $e')));
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    originalController?.dispose();
    resultController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff120f1f),
      appBar: AppBar(
        title: const Text('Video Detection'),
        backgroundColor: const Color(0xff211832),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),

          const SizedBox(height: 16),

          if (originalController != null &&
              originalController!.value.isInitialized)
            _videoBox(
              title: 'วิดีโอต้นฉบับ',
              controller: originalController!,
              color: Colors.purpleAccent,
            ),

          const SizedBox(height: 16),

          _controlCard(),

          const SizedBox(height: 16),

          if (isLoading) _loadingCard(),

          if (resultController != null && resultController!.value.isInitialized)
            _videoBox(
              title: 'วิดีโอผลลัพธ์ที่ตีกรอบแล้ว',
              controller: resultController!,
              color: Colors.greenAccent,
            ),

          const SizedBox(height: 16),

          if (result != null) _resultCard(),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff241b35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
      ),
      child: const Column(
        children: [
          Icon(Icons.smart_display, size: 70, color: Colors.purpleAccent),
          SizedBox(height: 12),
          Text(
            'YOLO Video Detection',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purpleAccent,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'เลือกวิดีโอ ส่งไปยัง FastAPI แล้วแสดงวิดีโอผลลัพธ์ที่มีกรอบตรวจจับคน',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _controlCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff241b35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (selectedVideo != null)
            Text(
              selectedVideo!.path.split(Platform.pathSeparator).last,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 12),

          SwitchListTile(
            value: useRealYolo,
            activeColor: Colors.greenAccent,
            title: const Text('ใช้ YOLO จริง'),
            subtitle: Text(
              useRealYolo
                  ? 'โหมดจริง: ตรวจจับคนด้วย YOLO'
                  : 'โหมดจำลอง: ตีกรอบตัวอย่างบนวิดีโอ',
            ),
            onChanged: (value) {
              setState(() {
                useRealYolo = value;
              });
            },
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: pickVideo,
              icon: const Icon(Icons.folder_open),
              label: const Text('เลือกวิดีโอ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : uploadVideo,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                isLoading ? 'กำลังประมวลผล...' : 'ส่งวิดีโอไปตรวจจับ',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff241b35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Colors.purpleAccent),
          SizedBox(height: 12),
          Text(
            'กำลังประมวลผลวิดีโอ อาจใช้เวลาสักครู่...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _videoBox({
    required String title,
    required VideoPlayerController controller,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff241b35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: VideoPlayer(controller),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  label: Text(controller.value.isPlaying ? 'Pause' : 'Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              ElevatedButton.icon(
                onPressed: () {
                  controller.seekTo(Duration.zero);
                  controller.pause();
                  setState(() {});
                },
                icon: const Icon(Icons.replay),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultCard() {
    final status = result!['status'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff241b35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: status == 'High Density'
              ? Colors.redAccent.withOpacity(0.6)
              : Colors.greenAccent.withOpacity(0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ผลการตรวจจับ',
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _resultItem(Icons.memory, 'Mode', '${result!['mode']}', Colors.cyan),
          _resultItem(
            Icons.groups,
            'Total People',
            '${result!['total_people']} คน',
            Colors.orangeAccent,
          ),
          _resultItem(
            Icons.verified_user,
            'Unique People',
            '${result!['unique_people']} คน',
            Colors.greenAccent,
          ),
          _resultItem(
            Icons.male,
            'Male',
            '${result!['male']} คน',
            Colors.blueAccent,
          ),
          _resultItem(
            Icons.female,
            'Female',
            '${result!['female']} คน',
            Colors.pinkAccent,
          ),
          _resultItem(
            Icons.login,
            'Enter',
            '${result!['enter']} คน',
            Colors.green,
          ),
          _resultItem(
            Icons.logout,
            'Exit',
            '${result!['exit']} คน',
            Colors.redAccent,
          ),
          _resultItem(
            Icons.meeting_room,
            'Inside',
            '${result!['inside']} คน',
            Colors.orange,
          ),

          const Divider(color: Colors.white24),

          Text(
            'Status: $status',
            style: TextStyle(
              color: status == 'High Density'
                  ? Colors.redAccent
                  : Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Processing Time: ${result!['processing_time']} sec',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'File: ${result!['file_name']}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _resultItem(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff2f2445),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
