import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:flutter/material.dart';

class DryCleanOrders extends StatefulWidget {
  const DryCleanOrders({super.key});

  @override
  _DryCleanOrdersState createState() => _DryCleanOrdersState();
}

class _DryCleanOrdersState extends State<DryCleanOrders> {
  late Future<List<OrderResource>> futureOrders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    DryCleanApiService apiService = DryCleanApiService();
    futureOrders = apiService.getAllOrders(1).catchError((error) {
      throw Exception('فشل تحميل الطلبات: $error');
    });
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'وقت غير معروف';
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 0) {
      return 'من ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'من ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'من ${difference.inMinutes} دقيقة';
    }
    return 'الآن';
  }

  void _markOrderAsReady(int orderId) async {
    try {
      DryCleanApiService apiService = DryCleanApiService();
      //await apiService.updateOrderStatus(orderId, 'ready');
      setState(() => _loadOrders());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحديث الحالة: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات التنظيف', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<OrderResource>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد طلبات متاحة'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              OrderResource order = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long, size: 40),
                      title: Text(
                        'طلب #${order.orderNumber ?? order.id ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.name ?? 'طلب بدون اسم',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${order.price?.toStringAsFixed(2) ?? '0.00'} ILS',
                            style: const TextStyle(
                              fontSize: 16, 
                              color: Colors.green
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimeAgo(order.createdAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _markOrderAsReady(order.id!),
                            icon: const Icon(Icons.check_circle, size: 12), // Reduced icon size
                            label: const Text(
                              'جاهز',
                              style: TextStyle(fontSize: 10), // Reduced text size
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,  // Reduced horizontal padding
                                vertical: 2     // Reduced vertical padding
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(50, 24), // Smaller minimum size
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Remove extra tap space
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}