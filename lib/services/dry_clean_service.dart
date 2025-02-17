import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DryCleanApiService {
  
  static const String baseUrl = 'https://10.0.2.2:7254/api';
  
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
  final String? types;
  final List<int>? typesIDs;
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
    this.types,
    this.typesIDs,
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
      id: json['ID'],
      size: json['Size']?.toDouble(),
      locationID: json['LocationID'],
      types: json['Types'],
      typesIDs: json['TypesIDs']?.cast<int>(),
      typesNames: json['TypesNames']?.cast<String>(),
      image: json['Image'],
      createdSince: json['CreatedSince'],
      createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      donationStatusID: json['DonationStatusID'],
      donationStatusName: json['DonationStatusName'],
      longitude: json['Longitude'],
      latitude: json['Latitude'],
      locationName: json['LocationName'],
      address: json['Address'],
      donaterID: json['DonaterID'],
      donater: json['Donater'] != null ? DonationDonaterResource.fromJson(json['Donater']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Size': size,
      'LocationID': locationID,
      'Types': types,
      'TypesIDs': typesIDs,
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
      id: json['ID'],
      manualID: json['ManualID'],
      name: json['Name'],
      email: json['Email'],
      phone: json['Phone'],
      locationID: json['LocationID'],
      locationName: json['LocationName'],
      image: json['Image'],
      donationCount: json['DonationCount']?.toDouble(),
      pending: json['Pending'],
      completed: json['Completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ManualID': manualID,
      'Name': name,
      'Email': email,
      'Phone': phone,
      'LocationID': locationID,
      'LocationName': locationName,
      'Image': image,
      'DonationCount': donationCount,
      'Pending': pending,
      'Completed': completed,
    };
  }
}
