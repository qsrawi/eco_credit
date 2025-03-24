import 'dart:async';
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
  late Future<PickerMainResource> _pickersFuture;
  PickerMainResource? _currentData;
  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 5;
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final ApiService _apiService = ApiService();
    _pickersFuture = _apiService
        .getPickers(null, null, _searchQuery, currentPage, pageSize)
        .then((res) {
      setState(() {
        _currentData = res;
        totalPages = ((res.rowsCount ?? 0) / pageSize).ceil();
        if (totalPages == 0) totalPages = 1;
      });
      return res;
    }).catchError((error) {
      throw Exception('فشل تحميل الطلبات: $error');
    });
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
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int someId = prefs.getInt('id') ?? 0;
            String someRole = prefs.getString('role') ?? '';
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
        child: FutureBuilder<PickerMainResource>(
          future: _pickersFuture,
          initialData: _currentData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _currentData == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }

            final data = snapshot.data ?? _currentData;
            if (data == null || data.lstData.isEmpty) {
              return const Center(child: Text('لا توجد بيانات متاحة'));
            }

            final pickers = data.lstData;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    onChanged: (value) {
                      if (_searchDebounce?.isActive ?? false) {
                        _searchDebounce?.cancel();
                      }
                      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {
                          _searchQuery = value;
                          currentPage = 1;
                          _loadOrders();
                        });
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن الأبطال...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 20.0,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 1.5,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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
                        wasteCollectionCount:
                            picker.collectionsCount?.toInt() ?? 0,
                        onKpiPressed: () => _handleKpiPress(picker.id),
                      );
                    },
                  ),
                ),
                _buildPaginationControls(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      _loadOrders();
                    });
                  }
                : null,
          ),
          Text(
            'الصفحة $currentPage من $totalPages',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                      _loadOrders();
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _handleKpiPress(int pickerId) {
    print('KPI pressed for picker ID: $pickerId');
  }
}