import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';


class EnergyCurve extends StatelessWidget {
  const EnergyCurve({super.key});

  @override
  Widget build(BuildContext context) {

    return  Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),

        boxShadow: [
          BoxShadow(
            color: Color(0xFF78A55A).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 4,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            minX: 0,
            maxX: 11,
            minY: 0,
            maxY: 6,
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 0.2),
                  FlSpot(1, 0.5),
                  FlSpot(2, 2.8),
                  FlSpot(3, 1.8),
                  FlSpot(4, 2.2),
                  FlSpot(5, 4.5),
                  FlSpot(6, 3.8),
                  FlSpot(7, 2.2),
                  FlSpot(8, 4.2),
                  FlSpot(9, 2.8),
                  FlSpot(10, 3.5),
                  FlSpot(11, 8.0),
                ],
                isCurved: true,
                curveSmoothness: 0.4,
                gradient: const LinearGradient(
                  colors: [Color(0xFF78A55A), Color(0xFF59B74F)],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, barData) => false,
                ),
                showingIndicators: [],
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF78A55A).withValues(alpha: 0.15),
                      const Color(0xFF59B74F).withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}