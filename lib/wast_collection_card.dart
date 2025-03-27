import 'dart:io';
import 'package:eco_credit/e_recycle_hub.dart';
import 'package:eco_credit/picker_widget.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:eco_credit/upload-photo-section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WasteCollectionCard extends StatelessWidget {
  final int collectionID;
  final String role;
  final String status; // حالة الجمع
  final int statusID; // حالة الجمع
  final String title; // العنوان
  final String name; // الاسم
  final String pickerName; // اسم الجامع
  final String collectionTypeName; // نوع الجمع
  final String imageUrl; // صورة مُكودة بنظام Base64
  final String timeAgo; // منذ
  final double collectionSize; // حجم الجمع
  final String description;
  final bool isInvoiced;
  final int invoiceID; // حالة الجمع
  final String invoiceImage;
  final String generatorPhone;
  final String pickerPhone;

  const WasteCollectionCard({
    required this.collectionID,
    required this.role,
    required this.status,
    required this.statusID,
    required this.invoiceID,
    required this.title,
    required this.collectionTypeName,
    required this.name,
    required this.pickerName,
    required this.imageUrl,
    required this.timeAgo,
    required this.collectionSize,
    required this.description,
    required this.isInvoiced,
    required this.invoiceImage,
    required this.generatorPhone,
    required this.pickerPhone,
  });

  void setWasteTypeId(int wasteTypeId) {
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.network(
                imageUrl, // Adjust the URL accordingly
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(description, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                'حجم الجمع: $collectionSize كغ', // "كغ" stands for kilograms in Arabic
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'رقم هاتف المنشأه: $generatorPhone', // Phone number
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: const Color(0xFF3F9A25)), // Copy icon
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: generatorPhone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ رقم الهاتف!')), // "Phone number copied!"
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'رقم هاتف بطل البيئة: $pickerPhone', // Phone number
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: const Color(0xFF3F9A25)), // Copy icon
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: pickerPhone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ رقم الهاتف!')), // "Phone number copied!"
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

void _showPickers(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'اختر بطل البيئة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: PickerWidget(
                    onSelected: (int selectedId) async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int userId = prefs.getInt('id') ?? 1;
                      String userType = prefs.getString('role') ?? 'Generator';

                      CollectionUpdateModel model = CollectionUpdateModel(
                        collectionID: collectionID,
                        collectionStatusID: 1,
                        pickerID: selectedId
                      );
                      
                      await ApiService().updateCollection(model);
                      
                      Navigator.of(context).pop(); // Close dialog first
                          Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ERecycleHub(id: userId, role: userType)),
                    (route) => false, // Remove all previous routes
                  );
                    },
                  ),
                ),
              ),
              Divider(height: 1),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showInvoiceDialogView(BuildContext context, InvoiceResource invoice) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              'تفاصيل الفاتورة',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3F9A25),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: _getImageProvider(invoice.image), // Use helper method
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: invoice.image == null
                      ? Center(child: Text('لا توجد صورة متاحة'))
                      : null,
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'ساحة الخردة:',
                  value: invoice.scarpyardOwner?? '',
                ),
                const Divider(height: 30, thickness: 0.5),
                _buildInfoRow(
                  icon: Icons.scale,
                  label: 'الوزن الحقيقي:',
                  value: '${invoice.invoiceSize?.toStringAsFixed(2) ?? 'N/A'} كغم',
                ),
                const Divider(height: 30, thickness: 0.5),
                _buildInfoRow(
                  icon: Icons.category,
                  label: 'نوع المادة القابلة للتدوير:',
                  value: invoice.wasteTypeName?? '',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F9A25),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  ImageProvider<Object> _getImageProvider(String? invoiceImage) {
    if (invoiceImage != null && invoiceImage.isNotEmpty) {
      return NetworkImage(
        invoiceImage,
        scale: 0.5,
      );
    }
    return const AssetImage('assets/images/default.jpg');
  }

    Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF3F9A25), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
    onTap: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String role = prefs.getString('role') ?? 'Generator';
      if (statusID == 4 && role == 'Picker' && isInvoiced == false) {
        _showInvoiceDialog(collectionID, context);
      } else {
        _showDetails(context);
      }
    },
      child: Card(
        color: Colors.white, // Set the background color to red
        // elevation: 5.0,
        // shadowColor: const Color(0xFF3F9A25),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          // side: const BorderSide(
          //   color: Color(0xFF3F9A25),
          //   width: 1.0,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: collectionTypeName == 'للبيع' ? Colors.red : const Color(0xFF3F9A25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      collectionTypeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      // color: status == 'قيد الإنتظار' ? Colors.orange : const Color(0xFF3F9A25),
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Image.network(
                imageUrl, // Adjust the URL accordingly
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$name - $timeAgo',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الجمع: $pickerName',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black
                  ),
                ),
              ),
              if (role == "Picker" && statusID == 1) ...[
                const SizedBox(height: 10),// Add space before the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int userId = prefs.getInt('id') ?? 1;
                      String userType = prefs.getString('role') ?? 'Generator';
                      
                        CollectionUpdateModel model = CollectionUpdateModel(
                          collectionID: collectionID,
                          collectionStatusID: 2,
                        );
                        ApiService apiService = ApiService();
                        await apiService.updateCollection(model);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => ERecycleHub(id: userId, role: userType)),
                          (route) => false, // Remove all previous routes
                        );
                      },
                      child: const Text('رفض', style: TextStyle(color: Colors.red)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white.withOpacity(0.9); // Light opacity when pressed
                            }
                            return Colors.white; // Default non-pressed state
                          }
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 55, vertical: 10)
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Smaller border radius
                            side: BorderSide(color: Colors.red, width: 0.8), // Red border color
                          )
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                              return Colors.red.withOpacity(0.1); // Hover and click effect color
                            }
                            return Colors.transparent; // Default is transparent
                          }
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between buttons
                    ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      int userId = prefs.getInt('id') ?? 1;
                      String userType = prefs.getString('role') ?? 'Generator';
                      // Create the updated model
                      CollectionUpdateModel model = CollectionUpdateModel(
                        collectionID: collectionID,
                        collectionStatusID: 3, // Assuming 3 is the new status
                      );

                      // Call the API to update the collection
                      ApiService apiService = ApiService();
                      await apiService.updateCollection(model);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => ERecycleHub(id: userId, role: userType)),
                        (route) => false, // Remove all previous routes
                      ); // Pass `true` to indicate success
                    },
                      child: const Text('قبول', style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return const Color(0xFF3F9A25).withOpacity(0.9); // Light opacity when pressed
                            }
                            return const Color(0xFF3F9A25); // Default non-pressed state
                          }
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 55, vertical: 10)
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Smaller border radius
                            side: BorderSide(color: const Color(0xFF3F9A25), width: 0.8), // Matching border color
                          )
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                              return const Color(0xFF3F9A25).withOpacity(0.1); // Hover and click effect color
                            }
                            return Colors.transparent; // Default is transparent
                          }
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (role == "Generator" && statusID == 2) ...[
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 10), // Space between buttons
                      ElevatedButton(
                      onPressed: () async {
                        _showPickers(context);
                      },
                        child: Text('تغيير بطل البيئة', style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color(0xFF3F9A25).withOpacity(0.9); // Light opacity when pressed
                              }
                              return const Color(0xFF3F9A25); // Default non-pressed state
                            }
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 75, vertical: 10)
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Smaller border radius
                              side: BorderSide(color: const Color(0xFF3F9A25), width: 0.8), // Matching border color
                            )
                          ),
                          overlayColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                                return const Color(0xFF3F9A25).withOpacity(0.1); // Hover and click effect color
                              }
                              return Colors.transparent; // Default is transparent
                            }
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
              if ((role == "Picker" && statusID == 4 && isInvoiced == true) || (role == "Admin" && statusID == 4 && isInvoiced == true)) ...[
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 10), // Space between buttons
                      ElevatedButton(
                      onPressed: () async {
                        final apiService = ApiService();
                        final invoice = await apiService.getInvoiceById(invoiceID);
                        _showInvoiceDialogView(context, invoice);
                      },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color(0xFF3F9A25).withOpacity(0.9); // Light opacity when pressed
                              }
                              return const Color(0xFF3F9A25); // Default non-pressed state
                            }
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 75, vertical: 10)
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Smaller border radius
                              side: BorderSide(color: const Color(0xFF3F9A25), width: 0.8), // Matching border color
                            )
                          ),
                          overlayColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                                return const Color(0xFF3F9A25).withOpacity(0.1); // Hover and click effect color
                              }
                              return Colors.transparent; // Default is transparent
                            }
                          ),
                        ),
                        child: const Text('عرض الفاتورة', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
              ],
              if (role == "Picker" && statusID == 3) ...[
                const SizedBox(height: 10),
                Row( // Remove const here
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _SizeInputButton(collectionID: collectionID), // Now recognizes collectionID
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeInputButton extends StatefulWidget {
  final int collectionID;
  const _SizeInputButton({required this.collectionID});

  @override
  State<_SizeInputButton> createState() => _SizeInputButtonState();
}

class _SizeInputButtonState extends State<_SizeInputButton> {
  final TextEditingController _sizeController = TextEditingController();

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _sizeController.text.isNotEmpty
              ? () async {
                  try {
                    final size = double.parse(_sizeController.text);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    int userId = prefs.getInt('id') ?? 1;
                    String userType = prefs.getString('role') ?? 'Generator';
                    ApiService apiService = ApiService();
                    CollectionUpdateModel model = CollectionUpdateModel(
                      collectionID: widget.collectionID,
                      collectionStatusID: 4,
                      collectionSize: size,
                    );
                    await apiService.updateCollection(model);
                    // Optional: Show success message or reset field
                    _sizeController.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ERecycleHub(id: userId, role: userType)),
                      (route) => false, // Remove all previous routes
                    ); // Pass `true` to indicate success
                    
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('أدخل قيمة رقمية صحيحة'),
                      ),
                    );
                  }
                }
              : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (_sizeController.text.isEmpty) return Colors.grey;
                if (states.contains(MaterialState.pressed)) {
                  return const Color(0xFF3F9A25).withOpacity(0.9);
                }
                return const Color(0xFF3F9A25);
              },
            ),
            // ... rest of the style
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white), // Choose an icon that fits your design
              SizedBox(width: 4), // Space between icon and text
              Text(
                'اكتملت',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _sizeController,
            onChanged: (value) => setState(() {}),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              hintText: 'أدخل الحجم',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3F9A25)), // Default border color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3F9A25)), // Green color when TextField is enabled
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF3F9A25)), // Green color when TextField is focused
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}

void _showInvoiceDialog(int collectionID, BuildContext context) {
  late TextEditingController invoiceSizeController = TextEditingController();
  late TextEditingController scarpyardOwnerController = TextEditingController();
  File? invoiceImage;
  int? wasteTypeID;

  showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إنشاء فاتورة'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 800, // Increased width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UploadPhotoSection(
                      onImageSelected: (File image) {
                        setState(() => invoiceImage = image);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: invoiceSizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الوزن الحقيقي',
                        labelStyle: TextStyle(color: Colors.black), // Set label text color to black
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3F9A25)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3F9A25)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: scarpyardOwnerController,
                      decoration: const InputDecoration(
                        labelText: 'ساحة الخردة',
                        labelStyle: TextStyle(color: Colors.black), // Set label text color to black
                        border: OutlineInputBorder(),
                         enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3F9A25)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF3F9A25)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F9A25),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int userId = prefs.getInt('id') ?? 1;
              String userType = prefs.getString('role') ?? 'Generator';
              if (invoiceImage != null &&
                  invoiceSizeController.text.isNotEmpty &&
                  scarpyardOwnerController.text.isNotEmpty) {
                try {
                  final invoiceData = {
                    'CollectionID': collectionID,
                    'InvoiceSize': invoiceSizeController.text,
                    'wasteTypeID': wasteTypeID,
                    'ScarpyardOwner': scarpyardOwnerController.text
                  };

                  await ApiService.createInvoice(invoiceData, invoiceImage!);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ERecycleHub(id: userId, role: userType),
                    ),
                    (route) => false, // Remove all previous routes
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إنشاء الفاتورة بنجاح')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في إنشاء الفاتورة: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('إرسال', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}