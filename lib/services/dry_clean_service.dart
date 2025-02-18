import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DryCleanApiService {
  
  static const String baseUrl = 'https://10.0.2.2:7254/api';
  
  static Future<http.Response?> createDonation(Map<String, dynamic> collectionData, File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/donations/create');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token', // Include the token in the header
    });

    // Add fields only if they are not null
    void addFieldIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is List) {
          // If the value is a list, add each item as a separate field
          for (var i = 0; i < value.length; i++) {
            request.fields['$key[$i]'] = value[i].toString();
          }
        } else {
          // Otherwise, convert the value to a string as usual
          request.fields[key] = value.toString();
        }
      }
    }

    addFieldIfNotNull('Longitude', collectionData['Longitude']);
    addFieldIfNotNull('Latitude', collectionData['Latitude']);
    addFieldIfNotNull('LocationName', collectionData['LocationName']);
    addFieldIfNotNull('DonaterID', collectionData['DonaterID']);
    addFieldIfNotNull('DonationStatusID', collectionData['DonationStatusID']);
    addFieldIfNotNull('Types', collectionData['Types']); // Send as a list
    addFieldIfNotNull('Size', collectionData['Size']);
    // addFieldIfNotNull('Description', collectionData['Description']);

    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'Image',
          imageFile.path,
          contentType: MediaType('image', fileName.split('.').last),
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return response;
      } else {
        print('Failed to create collection: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception when calling API: $e');
      return null;
    }
  }
  
  Future<List<DonationResource>> getAllDonations(int donationStatus, int? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/donations')
      .replace(queryParameters: {
        'donationStatus': donationStatus.toString(),
        'userID': userId?.toString()
      });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',  // Use the token here
    });
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => DonationResource.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }
}

class DonationResource {
  final int id;
  final double? size;
  final int? locationID;
  final List<String>? typesNames;
  final String? image;
  final int? createdSince;
  final DateTime? createdAt;
  final int? donationStatusID;
  final String? donationStatusName;
  final String? longitude;
  final String? latitude;
  final String? locationName;
  final String? address;
  final int? donaterID;
  final DonationDonaterResource? donater;

  DonationResource({
    required this.id,
    this.size,
    this.locationID,
    this.typesNames,
    this.image,
    this.createdSince,
    this.createdAt,
    this.donationStatusID,
    this.donationStatusName,
    this.longitude,
    this.latitude,
    this.locationName,
    this.address,
    this.donaterID,
    this.donater,
  });

  factory DonationResource.fromJson(Map<String, dynamic> json) {
    return DonationResource(
      id: int.parse(json['id'].toString()),
      size: json['size'] != null ? double.tryParse(json['size'].toString()) : null,
      locationID: json['locationID'] != null ? int.tryParse(json['locationID'].toString()) : null,
      typesNames: (json['typesNames'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      image: json['image'],
      createdSince: json['createdSince'] != null ? int.tryParse(json['createdSince'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      donationStatusID: json['donationStatusID'] != null ? int.tryParse(json['donationStatusID'].toString()) : null,
      donationStatusName: json['donationStatusName'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      locationName: json['locationName'],
      address: json['address'],
      donaterID: json['donaterID'] != null ? int.tryParse(json['donaterID'].toString()) : null,
      donater: json['donater'] != null ? DonationDonaterResource.fromJson(json['donater']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Size': size,
      'LocationID': locationID,
      'TypesNames': typesNames,
      'Image': image,
      'CreatedSince': createdSince,
      'CreatedAt': createdAt?.toIso8601String(),
      'DonationStatusID': donationStatusID,
      'DonationStatusName': donationStatusName,
      'Longitude': longitude,
      'Latitude': latitude,
      'LocationName': locationName,
      'Address': address,
      'DonaterID': donaterID,
      'Donater': donater?.toJson(),
    };
  }
}

class DonationDonaterResource {
  final int id;
  final String? manualID;
  final String? name;
  final String? email;
  final String? phone;
  final int? locationID;
  final String? locationName;
  final String? image;
  final double? donationCount;
  final int? pending;
  final int? completed;

  DonationDonaterResource({
    required this.id,
    this.manualID,
    this.name,
    this.email,
    this.phone,
    this.locationID,
    this.locationName,
    this.image,
    this.donationCount,
    this.pending,
    this.completed,
  });

  factory DonationDonaterResource.fromJson(Map<String, dynamic> json) {
    return DonationDonaterResource(
      id: json['id'],
      manualID: json['manualID'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      locationID: json['locationID'] != null ? int.tryParse(json['locationID'].toString()) : null,
      locationName: json['locationName'],
      image: json['Image'],
      donationCount: json['donationCount']?.toDouble(),
      pending: json['pending'] != null ? int.tryParse(json['pending'].toString()) : null,
      completed: json['completed'] != null ? int.tryParse(json['completed'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manualID': manualID,
      'name': name,
      'email': email,
      'phone': phone,
      'locationID': locationID,
      'locationName': locationName,
      'image': image,
      'donationCount': donationCount,
      'pending': pending,
      'completed': completed,
    };
  }
}
