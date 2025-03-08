import 'package:eco_credit/e_recycle_hub.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/user_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickersListWidget extends StatefulWidget {
  const PickersListWidget({super.key});

  @override
  State<PickersListWidget> createState() => _PickersListWidgetState();
}

class _PickersListWidgetState extends State<PickersListWidget> {
  late Future<List<PickerListResource>> _pickersFuture;

  @override
  void initState() {
    super.initState();
    late final ApiService _apiService = ApiService();
    _pickersFuture = _apiService.getPickers(null, null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text('قائمة أبطال البيئة'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Retrieve values from SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int someId = prefs.getInt('id') ?? 0; // Provide a default value in case it's null
            String someRole = prefs.getString('role') ?? ''; // Provide a default value in case it's null

            // Navigate to ERecycleHub with the retrieved values
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ERecycleHub(id: someId, role: someRole),
              ),
            );
          },
        ),
      ),
      body: Directionality(
      textDirection: TextDirection.rtl,
      child: FutureBuilder<List<PickerListResource>>(
        future: _pickersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد بيانات متاحة'));
          }

          final pickers = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pickers.length,
            itemBuilder: (context, index) {
              final picker = pickers[index];
              return UserCard(
                id: picker.id,
                role: "Picker",
                imageUrl: picker.image ?? 'assets/images/default.jpg',
                name: picker.name ?? 'اسم غير معروف',
                phone: picker.phone ?? 'لا يوجد رقم هاتف',
                locationName: picker.locationName ?? 'موقع غير محدد',
                wasteCollectionCount: picker.collectionCount?.toInt() ?? 0,
                onKpiPressed: () => _handleKpiPress(picker.id),
              );
            },
          );
        },
      ),
    )
    );
  }

  void _handleKpiPress(int pickerId) {
    // Handle KPI button press for specific picker
    print('KPI pressed for picker ID: $pickerId');
  }
}