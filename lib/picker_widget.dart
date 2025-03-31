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
      
      final pickersList = await ApiService().getPickers(null, null, query, null, null);
      final pickersList2 = await ApiService().getPickers(null, id, null, null, null);
      setState(() {
        if (query.isEmpty) {
          pickers = pickersList2.lstData;
        }
        dialogPickers = pickersList.lstData;
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
                  child:const Text(
                'إغلاق',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
      final pickersList = await ApiService().getPickers(null, null, query, null, null);
      setStateDialog(() {  // Use the dialog's setState to ensure UI updates
        dialogPickers = pickersList.lstData;
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
      mainAxisSize: MainAxisSize.min,
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
          SizedBox(
            height: 150,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      ...pickers.map((picker) => Card(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth - 30, // Account for padding
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: CircleAvatar(
                              backgroundImage: picker.image != null
                                  ? MemoryImage(base64Decode(picker.image!))
                                  : const AssetImage('assets/images/default.jpg') 
                                    as ImageProvider,
                            ),
                            title: Text(
                              '${picker.name} (${picker.manualId})',
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  picker.phone ?? 'لا يوجد هاتف',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait 
                                      ? 14 
                                      : 12,
                                  ),
                                ),
                                Text(
                                  picker.locationName ?? 'لا يوجد موقع',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait 
                                      ? 14 
                                      : 12,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                selectedPicker = picker.name;
                                selectedPickerId = picker.id;
                                widget.onSelected(picker.id);
                              });
                            },
                            selected: selectedPicker == picker.name,
                            selectedTileColor: Colors.blue.shade100,
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}
}
