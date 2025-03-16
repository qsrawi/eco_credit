import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eco_credit/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickerWidget extends StatefulWidget {
  final Function(int) onSelected;

  PickerWidget({Key? key, required this.onSelected}) : super(key: key);

  @override
  _PickerWidgetState createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  List<PickerListResource> pickers = [];
  List<PickerListResource> dialogPickers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  int? selectedPickerId; // Added to store the selected picker's ID
  String? selectedPicker;

  @override
  void initState() {
    super.initState();
    fetchPickers();
  }

  Future<void> fetchPickers({String query = ''}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt('id'); 
      
      final pickersList = await ApiService().getPickers(null, null, query);
      final pickersList2 = await ApiService().getPickers(null, id, null);
      setState(() {
        if (query.isEmpty) {
          pickers = pickersList2;
        }
        dialogPickers = pickersList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load pickers: $e');
    }
  }

  void showAllPickersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(  // This builder allows for local state updates within the dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('أبطال البيئة', textAlign: TextAlign.right), // Right align the title
              content: SizedBox(
                width: double.maxFinite, // Ensure the dialog is wide enough
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      textAlign: TextAlign.right, // Right align the text inside TextField
                      decoration: InputDecoration(
                        labelText: 'بحث',
                        labelStyle: const TextStyle( // Label style applied globally here
                          fontFamily: 'Helvetica', // Example font, adjust as needed
                          fontSize: 16, // Example size, adjust as needed
                        ),
                        alignLabelWithHint: true, // Aligns the label with the hint text which is aligned right
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            fetchPickersInDialog(setStateDialog, searchController.text);  // Update dialog list without closing
                          },
                        ),
                      ),
                      onChanged: (value) {  // Use onChanged to update as user types
                        fetchPickersInDialog(setStateDialog, value);
                      },
                    ),

                    SizedBox(
                      height: 300, // Height for the ListView
                      child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: dialogPickers.length,
                            itemBuilder: (context, index) {
                              var picker = dialogPickers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: picker.image != null
                                    ? MemoryImage(base64Decode(picker.image!))
                                    : const AssetImage('assets/images/default.jpg') as ImageProvider,
                                ),
                                title: Text('${picker.name} (${picker.manualId})', textAlign: TextAlign.right),
                                subtitle: Text(picker.phone ?? 'لا يوجد هاتف', textAlign: TextAlign.right),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setState(() {  // Update the main state to reflect selection
                                    selectedPicker = picker.name;
                                    selectedPickerId = picker.id;
                                    widget.onSelected(picker.id);
                                    if (!pickers.any((p) => p.name == picker.name)) {
                                      pickers.add(picker);
                                    }
                                  });
                                },
                                selected: selectedPicker == picker.name,
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق', textAlign: TextAlign.right),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> fetchPickersInDialog(void Function(void Function()) setStateDialog, String query) async {
    try {
      final pickersList = await ApiService().getPickers(null, null, query);
      setStateDialog(() {  // Use the dialog's setState to ensure UI updates
        dialogPickers = pickersList;
        isLoading = false;
      });
    } catch (e) {
      setStateDialog(() {
        isLoading = false;
      });
      print('Failed to load pickers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'اختر بطل البيئة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: showAllPickersDialog,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...pickers.map((picker) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: picker.image != null
                          ? MemoryImage(base64Decode(picker.image!))
                          : const AssetImage('assets/images/default.jpg') as ImageProvider,
                    ),
                    title: Text('${picker.name} (${picker.manualId})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(picker.phone ?? 'لا يوجد هاتف'),
                        Text(picker.locationName ?? 'لا يوجد موقع'),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedPicker = picker.name;
                        selectedPickerId = picker.id;
                        setState(() {
                            selectedPickerId = picker.id;
                          });
                          widget.onSelected(picker.id);
                      });
                    },
                    selected: selectedPicker == picker.name,
                    selectedTileColor: Colors.blue.shade100,
                  ),
                )).toList(),
        ],
      ),
    );
  }
}
