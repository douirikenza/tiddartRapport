import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/admin_dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';

class AdminStatisticsPage extends StatelessWidget {
  final AdminDashboardController controller =
      Get.find<AdminDashboardController>();

  AdminStatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Statistiques',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Get.back(closeOverlays: true),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Vue d\'ensemble'),
              const SizedBox(height: 20),
              _buildOverviewCards(),
              const SizedBox(height: 30),
              _buildSectionTitle('Évolution des inscriptions'),
              const SizedBox(height: 20),
              _buildSignupChart(),
              const SizedBox(height: 30),
              _buildSectionTitle('Statistiques par catégorie'),
              const SizedBox(height: 20),
              _buildCategoryStats(),
              const SizedBox(height: 30),
              _buildSectionTitle('Performances des artisans'),
              const SizedBox(height: 20),
              _buildArtisanPerformance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio:
          MediaQuery.of(Get.context!).size.width > 600 ? 2.0 : 1.3,
      children: [
        _buildOverviewCard(
          'Total Artisans',
          controller.totalArtisans.toString(),
          Icons.people,
          Colors.blue,
        ),
        FutureBuilder<int>(
          future: controller.getActiveArtisansCount(),
          builder: (context, snapshot) {
            return _buildOverviewCard(
              'Artisans Actifs',
              snapshot.hasData ? snapshot.data.toString() : '...',
              Icons.person_outline,
              AppTheme.primaryBrown,
            );
          },
        ),
        _buildOverviewCard(
          'Catégories',
          controller.totalCategories.toString(),
          Icons.category,
          Colors.orange,
        ),
        FutureBuilder<List<int>>(
          future: Future.wait([
            controller.getActiveArtisansCount(),
            controller.getTotalArtisansCount(),
          ]),
          builder: (context, snapshot) {
            final total = snapshot.hasData ? snapshot.data![1] : 1;
            final actifs = snapshot.hasData ? snapshot.data![0] : 0;
            final taux = (actifs / (total > 0 ? total : 1) * 100).round();
            return _buildOverviewCard(
              "Taux d'activité",
              '$taux%',
              Icons.analytics,
              Colors.purple,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupChart() {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.3,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FutureBuilder<Map<String, int>>(
        future: controller.getArtisanSignupEvolution(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune donnée d\'inscription disponible',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          final data = snapshot.data!;
          final keys = data.keys.toList()..sort();
          int cumulative = 0;
          final List<FlSpot> spots = [];
          for (int i = 0; i < keys.length; i++) {
            cumulative += data[keys[i]]!;
            spots.add(FlSpot(i.toDouble(), cumulative.toDouble()));
          }
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppTheme.primaryBrown.withOpacity(0.15),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppTheme.primaryBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                    interval: 5,
                    reservedSize: 40,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < keys.length) {
                        if (value.toInt() % 2 != 0)
                          return const SizedBox.shrink();
                        final date = keys[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              date.substring(5),
                              style: TextStyle(
                                color: AppTheme.primaryBrown,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryBrown.withOpacity(0.15),
                  ),
                  left: BorderSide(
                    color: AppTheme.primaryBrown.withOpacity(0.15),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppTheme.primaryBrown,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppTheme.accentGold,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryBrown.withOpacity(0.08),
                  ),
                ),
              ],
              minY: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryStats() {
    return Obx(() {
      if (controller.categoryStats.isEmpty) {
        return const Center(child: Text('Aucune catégorie disponible'));
      }

      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children:
              controller.categoryStats.map((category) {
                final color =
                    Colors.primaries[controller.categoryStats.indexOf(
                          category,
                        ) %
                        Colors.primaries.length];
                return Column(
                  children: [
                    _buildCategoryStatItem(
                      category['name'],
                      category['percentage'],
                      color,
                    ),
                    if (controller.categoryStats.last != category)
                      const Divider(),
                  ],
                );
              }).toList(),
        ),
      );
    });
  }

  Widget _buildCategoryStatItem(String category, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanPerformance() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.getTopArtisansBySales(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun artisan trouvé'));
          }
          final top = snapshot.data!;
          return Column(
            children:
                top.take(5).map((artisan) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                      child: Text(
                        (artisan['name'] as String).isNotEmpty
                            ? artisan['name'][0]
                            : '?',
                        style: TextStyle(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(artisan['name']),
                    subtitle: Text(artisan['category'] ?? ''),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${artisan['sales']} ventes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
