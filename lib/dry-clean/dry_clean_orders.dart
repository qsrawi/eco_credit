import 'dart:async';
import 'package:eco_credit/services/dry_clean_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DryCleanOrders extends StatefulWidget {
  final bool isEditable;

  const DryCleanOrders({
    super.key,
    this.isEditable = true, // Default to editable
  });

  @override
  _DryCleanOrdersState createState() => _DryCleanOrdersState();
}

class _DryCleanOrdersState extends State<DryCleanOrders> {
  late Future<List<OrderResource>> futureOrders;
  Timer? _searchDebounce;
  String _searchQuery = '';
  int currentPage = 1;
  int totalPages = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    DryCleanApiService apiService = DryCleanApiService();
    futureOrders = apiService
    .getAllOrders(
      widget.isEditable ? 1 : 2,
      _searchQuery,
      currentPage,
      pageSize,
    )
    .then((res) {
      // Calculate total pages based on your API response
      // Assuming your API returns total count in the response
      totalPages = ((res.rowsCount ?? 0) / pageSize).ceil();
      return res.lstData;
    }).catchError((error) {
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
      await apiService.updateOrder({'ID': orderId, 'OrderStatusID': 2});
      setState(() => _loadOrders());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحديث الحالة: ${e.toString()}')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات التنظيف', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (widget.isEditable)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity, // Makes the button span full width
                child: ElevatedButton.icon(
                  onPressed: () async {
                    bool? result = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AddRequestDialog();
                      },
                    );

                    if (result == true) {
                      _loadOrders(); // Reload the orders if a new one was added
                      setState(() {}); // Ensure UI refresh
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'اضافة طلب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color
                    padding:
                        EdgeInsets.symmetric(vertical: 14), // Adjust height
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    elevation: 5, // Adds a slight shadow for better design
                  ),
                ),
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                // Debounce search input
                if (_searchDebounce?.isActive ?? false)
                  _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _searchQuery = value;
                    _loadOrders();
                  });
                });
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن الطلبات...',
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
            child: FutureBuilder<List<OrderResource>>(
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

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
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
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.receipt_long, size: 40),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'طلب #${order.orderNumber ?? order.id}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              order.name ?? 'طلب بدون اسم',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              order.phone ?? '+970',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            Row(
                                              children: [
                                                // WhatsApp Button
                                                GestureDetector(
                                                  onTap: () {
                                                    final phone =
                                                        order.phone ?? '+970';
                                                    _launchWhatsApp(phone);
                                                  },
                                                  child: SvgPicture.asset(
                                                    "assets/icons/whatsapp.svg",
                                                    height: 30,
                                                  ),
                                                ),
                                                // Copy Button
                                                IconButton(
                                                  icon: Icon(Icons.content_copy,
                                                      color: Colors.grey),
                                                  iconSize: 20,
                                                  onPressed: () {
                                                    final phone =
                                                        order.phone ?? '+970';
                                                    _copyToClipboard(phone);
                                                  },
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${order.price?.toStringAsFixed(2) ?? '0.00'} ILS',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatTimeAgo(order.createdAt),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (widget.isEditable)
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _markOrderAsReady(order.id),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      size: 20),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'جاهز',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (!widget.isEditable) _buildPaginationControls(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الرقم: $text'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanedNumber = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = "https://wa.me/${cleanedNumber.replaceFirst('+', '')}";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تطبيق واتساب غير مثبت'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AddRequestDialog extends StatefulWidget {
  @override
  _AddRequestDialogState createState() => _AddRequestDialogState();
}

class _AddRequestDialogState extends State<AddRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+970';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة طلب جديد',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Price Field
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'السعر',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال السعر بالشيكل';
                }
                if (double.tryParse(value) == null) {
                  return 'السعر يجب أن يكون رقمًا';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Phone Field
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    items: ['+970', '+972']
                        .map((code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountryCode = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      if (value.length < 7) {
                        return 'رقم الهاتف يجب أن يكون 7 أرقام على الأقل';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Add Button
            ElevatedButton.icon(
              icon: Icon(Icons.add, color: Colors.white),
              label: const Text('اضافة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Process data
                  final fullPhone =
                      _selectedCountryCode + _phoneController.text;

                  Map<String, dynamic> model = {
                    'Name': _nameController.text,
                    'Price': _priceController.text,
                    'Phone': fullPhone,
                    'OrderStatusID': 1
                  };

                  DryCleanApiService apiService = DryCleanApiService();

                  apiService.createOrder(model).then((_) {
                    Navigator.pop(context, true); // Indicate success
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فشل في إضافة الطلب: $error')));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
