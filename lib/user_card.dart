import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // For AssetImage

class UserCard extends StatelessWidget {
  final int id;
  final String role;
  final String imageUrl;
  final String name;
  final String phone;
  final String locationName;
  final int wasteCollectionCount;
  final VoidCallback onKpiPressed;

  const UserCard({
    super.key,
    required this.id,
    required this.role,
    required this.imageUrl,
    required this.name,
    required this.phone,
    required this.locationName,
    required this.wasteCollectionCount,
    required this.onKpiPressed,
  });

// Keep the rest of the dialog implementation the same
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Image section
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone
                    _buildInfoRow(Icons.phone, phone),
                    const SizedBox(height: 4),

                    // Location
                    _buildInfoRow(Icons.location_on, locationName),
                    const SizedBox(height: 8),

                    // KPI Button and Waste Count
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showKpiReportDialog(context, id, role),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            'مؤشر الأداء',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'عدد المجموعات: $wasteCollectionCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

// Add this to your WasteCollectorCard widget's onKpiPressed handler
  Future<void> _showKpiReportDialog(BuildContext context, int id, String role) async {
    late final ApiService _apiService = ApiService();
    KpiResource wasteTypeStatus = KpiResource();
    if(role == "Generator") {
      wasteTypeStatus = await _apiService.getGeneratorKpi(id);
    } else {
      wasteTypeStatus = await _apiService.getPickerKpi(id);
    }

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تقرير مؤشرات الأداء'),
          content: SingleChildScrollView(
            child: Column(
              children: wasteTypeStatus.wasteTypeStatus!.map((item) {
                return _buildWasteTypeItem(
                  item.wasteTypeID ?? 0 ,
                  item.wasteTypeName ?? "" ,
                  item.collectionsCount ?? 0 ,
                  item.collectionAmount ?? 0.0 ,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteTypeItem(int typeId, String name, int count, double amount) {
    return ListTile(
      leading: Icon(_getWasteTypeIcon(typeId), color: Colors.green),
      title: Text(name),
      subtitle: Row(
        children: [
          _buildMetricItem(Icons.format_list_numbered, 'العدد: $count'),
          const SizedBox(width: 2),
          _buildMetricItem(Icons.scale, 'الكمية: ${amount.toStringAsFixed(1)} كجم'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMetricItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 2),
        Text(text),
      ],
    );
  }

IconData _getWasteTypeIcon(int typeId) {
  switch (typeId) {
    case 1: // بلاستك (Plastic)
      return Icons.recycling;
    case 2: // ورق (Paper)
      return Icons.description;
    case 3: // كرتون (Cardboard)
      return Icons.archive;
    case 4: // معادن (Metals)
      return Icons.build;
    case 5: // خشب (Wood)
      return Icons.forest;
    case 6: // زجاج (Glass)
      return Icons.local_drink;
    default:
      return Icons.delete_outline;
  }
}
