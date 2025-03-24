import 'package:eco_credit/collection_tabs.dart';
import 'package:eco_credit/notification_icon.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final bool showCompleted;

  HomeScreen({this.showCompleted = false});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int notificationCount = 0; // Example count, replace with actual data source
  late final ApiService _apiService = ApiService();
  Future<CollectionLightResource>? _futureStatistics;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
    _fetchUnreadNotificationCount();
  }

  Future<void> _fetchStatistics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? pickerId = prefs.getInt('id'); // Assuming pickerId is stored in SharedPreferences
    String role = prefs.getString('role') ?? ''; // Provide a default value in case it's null

    if (pickerId != null && role == "Picker") {
      setState(() {
        _futureStatistics = _apiService.statistics(pickerId);
      });
    }
  }

  Future<void> _fetchUnreadNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    String role = prefs.getString('role') ?? '';
    if (id != null && role != '') {
      int fetchedCount = await _apiService.getAllUnreadNotificationCount(id, role);
      setState(() {
        notificationCount = fetchedCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.hasData) {
              String role = snapshot.data!.getString('role') ?? 'Default Role';
              return getTitleWidget(role);
            } else {
              return Text("Loading..."); // Or any other placeholder
            }
          },
        ),
        actions: [
          NotificationIcon(notificationCount: notificationCount), // Use NotificationIcon here
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasData && 
                        snapshot.data!.getString('role') != "Admin" && 
                        !widget.showCompleted) {
                      if (snapshot.hasData) {
                        final userName = snapshot.data!.getString('name') ?? 'صديق البيئة';
                        final role = snapshot.data!.getString('role') ?? '';
                        
                        String message;
                        if (role == "Generator") {
                          message = 'مرحبا $userName شكراً لقيامك بدورك في الحفاظ على البيئة ';
                        } else if (role == "Picker") {
                          message = 'مرحباً $userName، شكراً لتحملك مسؤولية حماية البيئة ';
                        } else {
                          message = 'مرحباً $userName، شكراً لانضمامك إلى مجتمعنا البيئي ';
                        }

                        return Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade300, Colors.green.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.eco, color: Colors.white, size: 40),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  message,
                                  style: GoogleFonts.cairo(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.4,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }
                    else {
                return SizedBox.shrink();
              }
            }
          ),
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
              if (snapshot.hasData && 
                  snapshot.data!.getString('role') == "Admin" && 
                  widget.showCompleted) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        SizedBox(
                          width: 140,
                          child: _buildKpiButton(
                            icon: Icons.location_on,
                            label: 'المواد القابلة للتدوير حسب الموقع',
                            onPressed: () => _handleLocationKpi(context),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: _buildKpiButton(
                            icon: Icons.category,
                            label: 'المواد القابلة للتدوير حسب النوع',
                            onPressed: () => _handleCategoryKpi(context),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: _buildKpiButton(
                            icon: Icons.check_circle,
                            label: 'الطلبات المنجزة',
                            onPressed: () => _handleSuccessfulKpi(context),
                          ),
                        ),
                      ],
                  ),
                );
              } else if (snapshot.hasData && 
                        snapshot.data!.getString('role') == "Picker" && 
                        !widget.showCompleted) {
                return roleBasedCards();
              } else {
                return SizedBox.shrink();
              }
            },
          ),
          Expanded(
            child: CollectionTabs(showCompleted: widget.showCompleted),
          ),
        ],
      ),
    );
  }

Widget roleBasedCards() {
  return FutureBuilder<CollectionLightResource>(
    future: _futureStatistics,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData) {
        return Center(child: Text('No data available'));
      } else {
        // Extract the counts from the API response
        int completedTasks = snapshot.data!.todayPickups ?? 0;
        int pendingTasks = snapshot.data!.pending ?? 0;

        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoCard(
                title: "المهام المنجزة",
                count: completedTasks,
                iconData: Icons.directions_car,
                color: Colors.green,
              ),
              InfoCard(
                title: "قيد الانتظار",
                count: pendingTasks,
                iconData: Icons.hourglass_empty,
                color: Colors.amber,
              ),
            ],
          ),
        );
      }
    },
  );
}
}

class InfoCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData iconData;
  final Color color;

  const InfoCard({
    required this.title,
    required this.count,
    required this.iconData,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: color),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget getTitleWidget(String role) {
  IconData iconData;
  Color color;
  String text;

  switch (role) {
    case "Generator":
      iconData = Icons.business;
      color = const Color(0xFF3F9A25);
      text = "منشأة";
      break;
    case "Picker":
      iconData = Icons.eco;
      color = const Color(0xFF3F9A25);
      text = "بطل البيئة";
      break;
   case "Admin":
      iconData = Icons.admin_panel_settings;
      color = const Color(0xFF3F9A25);
      text = "آدمن";
      break;
    default:
      iconData = Icons.error;
      color = Colors.grey;
      text = "Unknown Role";
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start, // Aligns the Row content to the start, which is the right in RTL
    textDirection: TextDirection.rtl, // Ensures content is right-to-left
    children: <Widget>[
      Text(text, textAlign: TextAlign.right), // Ensures the text is right-aligned
      SizedBox(width: 8), // Space between text and icon
      Icon(iconData, size: 20, color: color), // You can adjust the size as needed
    ],
  );
}

// Add these helper methods
Widget _buildKpiButton({required IconData icon, required String label, required VoidCallback onPressed}) {
  return Card(
    elevation: 4,
    shadowColor: Colors.grey.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3F9A25),
          width: 1,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3F9A25), // Splash/overlay color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3F9A25).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: const Color(0xFF3F9A25),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _handleLocationKpi(BuildContext context) async {
  final apiService = ApiService();
  
  // First show location selection dialog
  final selectedLocation = await showDialog<int>(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: FutureBuilder<List<LookupsResource>>(
        future: apiService.getLookups("Location"),
        builder: (context, snapshot) {
          return AlertDialog(
            title: const Text('اختر الموقع'),
            content: SizedBox(
              width: double.maxFinite,
              child: _buildLocationList(snapshot),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ],
          );
        },
      ),
    ),
  );

  if (selectedLocation != null && context.mounted) {
    _showKpiReportDialog(
      context,
      (months) => apiService.getLocationKpi(selectedLocation, months),
    );
  }
  // if (selectedLocation != null) {
  //   final wasteTypeStatus = await apiService.getLocationKpi(selectedLocation);
    
  //   if (context.mounted) {
  //     _showKpiReportDialog(context, wasteTypeStatus);
  //   }
  // }
}

Widget _buildLocationList(AsyncSnapshot<List<LookupsResource>> snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }

  if (snapshot.hasError) {
    return Text('خطأ في تحميل المواقع: ${snapshot.error}');
  }

  if (!snapshot.hasData || snapshot.data!.isEmpty) {
    return const Text('لا توجد مواقع متاحة');
  }

  final locations = snapshot.data!;

  return ListView.builder(
    shrinkWrap: true,
    itemCount: locations.length,
    itemBuilder: (context, index) {
      final location = locations[index];
      return ListTile(
        title: Text(location.value ?? ''),
        onTap: () => Navigator.pop(context, location.lkpID),
      );
    },
  );
}

Future<void> _handleCategoryKpi(BuildContext context) async {
  late final ApiService apiService = ApiService();
  // KpiResource wasteTypeStatus = KpiResource();

  // wasteTypeStatus = await apiService.getWasteCategoriesKpi();

  _showKpiReportDialog(
    context,
    (months) => apiService.getWasteCategoriesKpi(months),
  );
  // ignore: use_build_context_synchronously
  // _showKpiReportDialog(context, wasteTypeStatus);
}

Future<void> _handleSuccessfulKpi(BuildContext context) async {
  late final ApiService apiService = ApiService();
  // KpiResource wasteTypeStatus = KpiResource();

  // wasteTypeStatus = await apiService.getSuccessfulCollectionsKpi();

  _showKpiReportDialog(
    context,
    (months) => apiService.getSuccessfulCollectionsKpi(months),
  );
  // ignore: use_build_context_synchronously
  // _showKpiReportDialog(context, wasteTypeStatus);
}


// Add this to your WasteCollectorCard widget's onKpiPressed handler
Future<void> _showKpiReportDialog(
  BuildContext context,
  Future<KpiResource> Function(int) fetcher,
) async {
  final TextEditingController lastMonthsController = TextEditingController(text: '12');

  await showDialog(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تقرير مؤشرات الأداء'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return FutureBuilder<KpiResource>(
                future: fetcher(int.tryParse(lastMonthsController.text) ?? 12),
                builder: (context, snapshot) {
                  final isLoading = snapshot.connectionState == ConnectionState.waiting;
                  final error = snapshot.error;
                  final data = snapshot.data ?? KpiResource();

                  return Column(
                    children: [
                      TextField(
                        controller: lastMonthsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'في آخر شهور',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (error != null)
                        Text('خطأ في التحميل: $error')
                      else
                        ...data.wasteTypeStatus!.map((item) => _buildWasteTypeItem(
                  item.wasteTypeID ?? 0,
                  item.wasteTypeName ?? "",
                  item.collectionsCount ?? 0,
                  item.collectionAmount ?? 0.0,
                )).toList(),
                    ],
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildWasteTypeItem(int typeId, String name, int count, double amount) {
    return ListTile(
      leading: Icon(_getWasteTypeIcon(typeId), color: Colors.green),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
        children: [
          _buildMetricItem(Icons.format_list_numbered, 'العدد: $count'),
          const SizedBox(height: 4), // Add vertical spacing between items
          _buildMetricItem(Icons.scale, 'الكمية: ${amount.toStringAsFixed(1)} كجم'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
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
        Icon(icon, size: 14),
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