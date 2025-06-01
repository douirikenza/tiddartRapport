import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Tiddart/page/artisan/artisan_product_management_page.dart';
import 'dart:ui' as ui;
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../controllers/message_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'artisan_chat_page.dart';
import 'artisan_conversations_list.dart';
import 'category_products_page.dart';
import '../../controllers/artisan_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueData {
  final String day;
  final double amount;

  RevenueData(this.day, this.amount);
}

class ArtisanDashboardPage extends StatelessWidget {
  final String artisanId;

  const ArtisanDashboardPage({Key? key, required this.artisanId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ArtisanDashboardController controller = Get.put(
      ArtisanDashboardController(),
    );
    final AuthController authController = Get.find<AuthController>();
    final MessageController _messageController = Get.put(MessageController());
    final OrderController orderController = Get.find<OrderController>();
    final String currentArtisanId =
        artisanId.isNotEmpty ? artisanId : (authController.userId ?? '');

    // Force le chargement des commandes à chaque build
    orderController.fetchOrders();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Tableau de Bord Artisan',
          style: TextStyle(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        // backgroundColor: Colors.white,
        // title: const Text(
        //   'Tableau de bord',
        //   style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        // ),
        actions: [
          StreamBuilder<int>(
            stream: _messageController.getUnreadCount(artisanId),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: unreadCount > 0 ? value : 1.0,
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppTheme.primaryBrown,
                            size: 26,
                          ),
                        );
                      },
                    ),
                    onPressed: () {
                      Get.to(
                        () => ArtisanConversationsList(artisanId: artisanId),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: AppTheme.primaryBrown),
            onPressed: () {
              Get.to(
                () => CategoryProductsPage(
                  categoryId: 'all', // Catégorie par défaut
                  artisanId: artisanId,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue sur votre tableau de bord',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => GestureDetector(
                            onTap: () {
                              Get.to(() => ArtisanProductManagementPage());
                            },
                            child: _buildStatCard(
                              'Produits',
                              controller.totalProducts.value.toString(),
                              Icons.inventory_2,
                              Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => _buildStatCard(
                            'Commandes',
                            controller.totalOrders.value.toString(),
                            Icons.shopping_cart,
                            Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(
                          () => _buildStatCard(
                            'Revenus',
                            '${orderController.getTotalRevenueForArtisan(currentArtisanId).toStringAsFixed(2)} TND',
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Produits les plus vendus',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Taux de vente (%) et nombre de ventes pour chaque produit',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<Map<String, double>>(
                      future: orderController.getProductSalesRateForArtisan(
                        currentArtisanId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final rates = snapshot.data ?? {};
                        if (rates.isEmpty) {
                          return _buildEmptyState(
                            'Aucun produit vendu',
                            Icons.inventory_2_outlined,
                          );
                        }
                        final salesCount = orderController
                            .getProductSalesCountForArtisan(currentArtisanId);
                        final ratesList =
                            rates.values
                                .toList()
                                .map((e) => (e as num).toDouble())
                                .toList();
                        final maxRate =
                            ratesList.isEmpty
                                ? 0.0
                                : ratesList.reduce((a, b) => a > b ? a : b);
                        final maxIndex = ratesList.indexOf(maxRate);
                        final barColors = List.generate(
                          rates.length,
                          (i) =>
                              i == maxIndex && maxRate > 0
                                  ? AppTheme.accentGold
                                  : AppTheme.primaryBrown,
                        );
                        return SizedBox(
                          height: 320,
                          child: Stack(
                            children: [
                              BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 100.0,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (
                                          double value,
                                          TitleMeta meta,
                                        ) {
                                          final idx = value.toInt();
                                          if (idx < 0 ||
                                              idx >= rates.keys.length)
                                            return const SizedBox();
                                          final name = rates.keys.elementAt(
                                            idx,
                                          );
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                  barGroups: List.generate(rates.length, (i) {
                                    final isTop = i == maxIndex && maxRate > 0;
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: ratesList[i],
                                          color: barColors[i],
                                          width: 22,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          gradient: LinearGradient(
                                            colors:
                                                isTop
                                                    ? [
                                                      AppTheme.accentGold,
                                                      AppTheme.primaryBrown
                                                          .withOpacity(0.7),
                                                    ]
                                                    : [
                                                      AppTheme.primaryBrown,
                                                      AppTheme.primaryBrown
                                                          .withOpacity(0.5),
                                                    ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                      ],
                                      showingTooltipIndicators: [],
                                    );
                                  }),
                                ),
                              ),
                              ...List.generate(rates.length, (i) {
                                final barHeight = 260 * (ratesList[i] / 100.0);
                                final pid =
                                    salesCount.keys.length > i
                                        ? salesCount.keys.elementAt(i)
                                        : '';
                                final sales = salesCount[pid] ?? 0;
                                return Positioned(
                                  left:
                                      48.0 +
                                      i *
                                          (MediaQuery.of(context).size.width -
                                              96) /
                                          rates.length,
                                  top: 260 - barHeight - 30,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: barColors[i],
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: barColors[i].withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '$sales',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => Get.to(() => ArtisanProductManagementPage()),
      //   backgroundColor: AppTheme.primaryBrown,
      //   icon: const Icon(Icons.add, color: Colors.white),
      //   label: const Text(
      //     'Ajouter un produit',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order['id'].substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'} TND',
              style: TextStyle(
                color: AppTheme.primaryBrown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${order['items']?.length ?? 0} articles',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (product['imageUrls']?.isNotEmpty ?? false)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['imageUrls'][0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Produit sans nom',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['price']?.toStringAsFixed(2) ?? '0.00'} TND',
                    style: TextStyle(
                      color: AppTheme.primaryBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['orderCount'] ?? 0} commandes',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;

  ChartPainter({required this.data, required this.labels, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.fill;

    final dotBorderPaint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - (data[i] / maxValue * size.height * 0.8);
      points.add(Offset(x, y));
    }

    // Draw area
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    final fillPath =
        Path.from(path)
          ..lineTo(points.last.dx, size.height)
          ..lineTo(points.first.dx, size.height)
          ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots and labels
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(point, 6, dotBorderPaint);

      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: color.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
