import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/small_filter_chip.dart';

class RankTab extends StatelessWidget {
  const RankTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('랭킹 보드', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              Row(
                children: [
                  SmallFilterChip(label: '서면', onTap: () {}),
                  const SizedBox(width: 6),
                  SmallFilterChip(label: '광안리', onTap: () {}),
                  const SizedBox(width: 6),
                  SmallFilterChip(label: '해운대', onTap: () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.10)),
                color: Colors.white.withOpacity(0.04),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStatePropertyAll(Colors.white.withOpacity(0.06)),
                  columns: const [
                    DataColumn(label: Text('순위', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('닉네임', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('레벨', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('XP', style: TextStyle(color: Color(0xFFCBD5E1)))),
                    DataColumn(label: Text('이번달 소비', style: TextStyle(color: Color(0xFFCBD5E1)))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('#1', style: TextStyle(color: Colors.white))),
                      DataCell(Text('SeomyeonKing', style: TextStyle(color: Colors.white))),
                      DataCell(Text('Lv.5', style: TextStyle(color: Colors.white))),
                      DataCell(Text('1,240', style: TextStyle(color: Colors.white))),
                      DataCell(Text('₩ 385,000', style: TextStyle(color: Colors.white))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('#2', style: TextStyle(color: Colors.white))),
                      DataCell(Text('HaeundaeWave', style: TextStyle(color: Colors.white))),
                      DataCell(Text('Lv.4', style: TextStyle(color: Colors.white))),
                      DataCell(Text('1,010', style: TextStyle(color: Colors.white))),
                      DataCell(Text('₩ 305,000', style: TextStyle(color: Colors.white))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('#12', style: TextStyle(color: Colors.white))),
                      DataCell(Text('내_부기_최고', style: TextStyle(color: Colors.white))),
                      DataCell(Text('Lv.3', style: TextStyle(color: Colors.white))),
                      DataCell(Text('312', style: TextStyle(color: Colors.white))),
                      DataCell(Text('₩ 118,000', style: TextStyle(color: Colors.white))),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
