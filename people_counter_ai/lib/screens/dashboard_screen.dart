import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/people_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeopleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xff241b35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'สรุปผลการคัดกรอง',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.total}',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                const Text(
                  'จำนวนคนทั้งหมดที่ไม่ซ้ำ',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 260,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xff241b35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: provider.total == 0
                ? const Center(child: Text('ยังไม่มีข้อมูลสำหรับแสดงกราฟ'))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: provider.male.toDouble(),
                          title: 'ชาย\n${provider.male}',
                          color: Colors.blueAccent,
                          radius: 65,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: provider.female.toDouble(),
                          title: 'หญิง\n${provider.female}',
                          color: Colors.pinkAccent,
                          radius: 65,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 260,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xff241b35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: BarChart(
              BarChartData(
                maxY: _getMaxY(provider),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: provider.male.toDouble(),
                        color: Colors.blueAccent,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: provider.female.toDouble(),
                        color: Colors.pinkAccent,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: provider.enterCount.toDouble(),
                        color: Colors.greenAccent,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(
                        toY: provider.exitCount.toDouble(),
                        color: Colors.redAccent,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 1:
                            return const Text('ชาย');
                          case 2:
                            return const Text('หญิง');
                          case 3:
                            return const Text('เข้า');
                          case 4:
                            return const Text('ออก');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _summaryCard(
            icon: Icons.male,
            title: 'จำนวนผู้ชาย',
            value: provider.male,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 12),
          _summaryCard(
            icon: Icons.female,
            title: 'จำนวนผู้หญิง',
            value: provider.female,
            color: Colors.pinkAccent,
          ),
          const SizedBox(height: 12),
          _summaryCard(
            icon: Icons.login,
            title: 'จำนวนคนเข้า',
            value: provider.enterCount,
            color: Colors.greenAccent,
          ),
          const SizedBox(height: 12),
          _summaryCard(
            icon: Icons.logout,
            title: 'จำนวนคนออก',
            value: provider.exitCount,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          _summaryCard(
            icon: Icons.groups,
            title: 'คงเหลือในพื้นที่',
            value: provider.currentInside,
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  double _getMaxY(PeopleProvider provider) {
    final values = [
      provider.male,
      provider.female,
      provider.enterCount,
      provider.exitCount,
    ];

    final max = values.reduce((a, b) => a > b ? a : b);

    if (max <= 5) return 5;
    return max + 5;
  }

  Widget _summaryCard({
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
      child: Row(
        children: [
          Icon(icon, size: 38, color: color),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
