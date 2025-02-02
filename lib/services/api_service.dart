import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  
static const String baseUrl = 'https://10.0.2.2:7254/api'; // For Android emulator

  Future<CollectionResponse> createCollection(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/collections/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return CollectionResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create collection: ${response.body}');
    }
  }

  Future<List<CollectionResponse>> getCollections(String status, {int? userId, String? userType}) async {
    final uri = Uri.parse('$baseUrl/collections')
      .replace(queryParameters: {
        'status': status,
        'userID': userId?.toString(),
        'userType': userType,
      });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => CollectionResponse.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<GeneratorResource> fetchProfile(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pickers/$id'));

    if (response.statusCode == 200) {
      return GeneratorResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<GeneratorResource> fetchGeneratorsProfile(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/generators/$id'));

    if (response.statusCode == 200) {
      return GeneratorResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}

class GeneratorResource {
  final int id;
  final String? manualId;
  final String? name;
  final String? email;
  final String? phone;
  final int? locationId;
  final int wasteTypeId;
  final String? wasteTypeName;
  final double? collectionCount;
  final String? image;
  final List<CollectionGeneratorResource>? collections;
  final List<NotificationGeneratorResource>? notifications;

  GeneratorResource({
    required this.id,
    this.manualId,
    this.name,
    this.email,
    this.phone,
    this.locationId,
    required this.wasteTypeId,
    this.wasteTypeName,
    this.collectionCount,
    this.image,
    this.collections,
    this.notifications,
  });

  factory GeneratorResource.fromJson(Map<String, dynamic> json) {
    return GeneratorResource(
      id: json['id'] as int? ?? 0, // Handle null with default value
      manualId: json['manualID'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      locationId: json['locationID'] as int? ?? 0,
      wasteTypeId: json['wasteTypeID'] as int? ?? 0, // Handle null with default
      wasteTypeName: json['wasteTypeName'] as String?,
      collectionCount: (json['collectionCount'] as num?)?.toDouble(),
      image: json['image'] as String?,
      collections: (json['collections'] as List<dynamic>?)?.map((x) => CollectionGeneratorResource.fromJson(x)).toList(),
      notifications: (json['notifications'] as List<dynamic>?)?.map((x) => NotificationGeneratorResource.fromJson(x)).toList(),
    );
  }
}

class CollectionGeneratorResource {
  final int id;
  // final String title;

  CollectionGeneratorResource({
    required this.id,
    // required this.title,
  });

  factory CollectionGeneratorResource.fromJson(Map<String, dynamic> json) {
    return CollectionGeneratorResource(
      id: json['collectionID'],
      // title: json['title'],
    );
  }
}

class NotificationGeneratorResource {
  final int id;
  final String message;

  NotificationGeneratorResource({
    required this.id,
    required this.message,
  });

  factory NotificationGeneratorResource.fromJson(Map<String, dynamic> json) {
    return NotificationGeneratorResource(
      id: json['id'],
      message: json['message'],
    );
  }
}


class CollectionResponse {
  final int collectionID;
  final int generatorID;
  final int? pickerID;
  final int? notificationID;
  final int collectionStatusID;
  final int wasteTypeID;
  final String? wasteTypeName;
  final String? description;
  final DateTime? createdDate;
  final String? image;
  final Generator? generator;
  final Generator? picker;

  CollectionResponse({
    required this.collectionID,
    required this.generatorID,
    this.pickerID,
    this.notificationID,
    required this.collectionStatusID,
    required this.wasteTypeID,
    this.wasteTypeName,
    this.description,
    this.createdDate,
    this.image,
    this.generator,
    this.picker,
  });

  factory CollectionResponse.fromJson(Map<String, dynamic> json) {
    return CollectionResponse(
      collectionID: json['collectionID'],
      generatorID: json['generatorID'],
      pickerID: json['pickerID'],
      notificationID: json['notificationID'],
      collectionStatusID: json['collectionStatusID'],
      wasteTypeID: json['wasteTypeID'],
      wasteTypeName: json['wasteTypeName'],
      description: json['description'],
      createdDate: DateTime.parse(json['createdDate']),
      image: json['image'],
      generator: json['generator'] != null ? Generator.fromJson(json['generator']) : null,
      picker: json['picker'] != null ? Generator.fromJson(json['picker']) : null,
    );
  }
}

class Generator {
  final String name;
  final String? imageUrl;

  Generator({required this.name, this.imageUrl});

  factory Generator.fromJson(Map<String, dynamic> json) {
    return Generator(
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}