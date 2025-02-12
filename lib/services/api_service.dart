import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  
  static const String baseUrl = 'https://10.0.2.2:7254/api'; // For Android emulator

  static Future<http.Response?> createCollectionWithImage(Map<String, dynamic> collectionData, File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/collections/create');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token'  // Include the token in the header
    });

    // Add fields only if they are not null
    void addFieldIfNotNull(String key, dynamic value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    }

    addFieldIfNotNull('GeneratorID', collectionData['GeneratorID']);
    addFieldIfNotNull('PickerID', collectionData['PickerID']);
    addFieldIfNotNull('InvoiceID', collectionData['InvoiceID']); // Pass null if InvoiceID is null
    addFieldIfNotNull('CollectionStatusID', collectionData['CollectionStatusID']);
    addFieldIfNotNull('CollectionTypeID', collectionData['CollectionTypeID']);
    addFieldIfNotNull('WasteTypeID', collectionData['WasteTypeID']);
    addFieldIfNotNull('CollectionSize', collectionData['CollectionSize']);
    addFieldIfNotNull('Description', collectionData['Description']);

    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'CollectionImage',
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

  Future<void> updateCollection(CollectionModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    
    var url = Uri.parse('$baseUrl/collections/update'); // Adjust endpoint as necessary

    var request = http.MultipartRequest('PUT', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token'  // Include the token in the header
    });
    
    void addFieldIfNotNull(String key, dynamic value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    }

    addFieldIfNotNull('CollectionID', model.collectionID);
    addFieldIfNotNull('CollectionStatusID', model.collectionStatusID);
    try {
    var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Update successful');
      } else {
        print('Failed to update: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
  
  static Future<Map<String, dynamic>> login(String email, String password, String? type) async {
    var url = Uri.parse('$baseUrl/admins/login');
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'type': type
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['token'] != null && jsonResponse['id'] != null) {
          String token = jsonResponse['token'];
          int id = jsonResponse['id'];
          String role = jsonResponse['role'];
          String wasteTypeID = jsonResponse['WasteTypeID'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setInt('id', id);
          await prefs.setString('role', role);
          await prefs.setString('wasteTypeID', wasteTypeID);

          return { 'token': token, 'id': id, 'role': role };
        } else {
          throw Exception('Token or User ID not found in response');
        }
      } else {
        var error = jsonDecode(response.body);
        throw Exception('Failed to login with status code: ${response.statusCode}, Error: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<List<CollectionResponse>> getCollections(int status, {int? userId, String? userType}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/collections')
      .replace(queryParameters: {
        'collectionStatus': status.toString(),
        'userID': userId?.toString(),
        'userType': userType,
      });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',  // Use the token here
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => CollectionResponse.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<CollectionLightResource> statistics(int? pickerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/collections/statistics').replace(queryParameters: {
      'pickerID': pickerId.toString(),
    });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });

    if (response.statusCode == 200) {
      // Decode the JSON response
      Map<String, dynamic> data = json.decode(response.body);

      // Directly parse the JSON into a CollectionLightResource object
      return CollectionLightResource.fromJson(data);
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<PickerListResource>> getPickers(int? wasteGroupID, int? generatorID, String? strSearch) async {
    final uri = Uri.parse('$baseUrl/pickers')
      .replace(queryParameters: {
        'wasteGroupID': wasteGroupID?.toString(),
        'generatorID': generatorID?.toString(),
        'strSearch': strSearch,
      });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PickerListResource.fromJson(item)).toList();
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

  Future<List<NotificationListResource>> fetchNotifications(int? userId, String? userType) async {
    final uri = Uri.parse('$baseUrl/notifications')
      .replace(queryParameters: {
        'userID': userId?.toString(),
        'userType': userType,
      });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['notificationListResource'] != null && 
          data['notificationListResource'] is Map<String, dynamic>) {
        var notificationsMap = data['notificationListResource'] as Map<String, dynamic>;
        List<NotificationListResource> notifications = [];
        notificationsMap.forEach((key, value) {
          if (value is List) {
            notifications.addAll(value.map((item) => NotificationListResource.fromJson(item)).toList());
          }
        });
        return notifications;
      }
      return []; // Return an empty list if 'notificationListResource' is improperly formatted
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode} ${response.body}');
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
  final String? locationName;
  final int wasteTypeId;
  final String? wasteTypeName;
  final String? collectionTypeName;
  final double? collectionCount;
  final String? image;
  final List<CollectionGeneratorResource>? collections;
  final List<NotificationGeneratorResource>? notifications;
  final int? pending;
  final int? ignored;
  final int? picked;
  final int? completed;

  GeneratorResource({
    required this.id,
    this.manualId,
    this.name,
    this.email,
    this.phone,
    this.locationId,
    required this.wasteTypeId,
    this.wasteTypeName,
    this.collectionTypeName,
    this.locationName,
    this.collectionCount,
    this.image,
    this.collections,
    this.notifications,
    this.pending,
    this.ignored,
    this.picked,
    this.completed,
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
      collectionTypeName: json['collectionTypeName'] as String?,
      locationName: json['locationName'] as String?,
      collectionCount: (json['collectionCount'] as num?)?.toDouble(),
      image: json['image'] as String?,
      collections: (json['collections'] as List<dynamic>?)?.map((x) => CollectionGeneratorResource.fromJson(x)).toList(),
      notifications: (json['notifications'] as List<dynamic>?)?.map((x) => NotificationGeneratorResource.fromJson(x)).toList(),
      pending: json['pending'] as int?,
      ignored: json['ignored'] as int?,
      picked: json['picked'] as int?,
      completed: json['completed'] as int?,
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
  final int notificationID;
  // final String message;

  NotificationGeneratorResource({
    required this.notificationID
  });

  factory NotificationGeneratorResource.fromJson(Map<String, dynamic> json) {
    return NotificationGeneratorResource(
      notificationID: json['notificationID']
    );
  }
}

class CollectionLightResource {
  final int? pending;
  final int? todayPickups;

  CollectionLightResource({
    this.pending,
    this.todayPickups
  });

  factory CollectionLightResource.fromJson(Map<String, dynamic> json) {
    return CollectionLightResource(
      pending: json['pending'],
      todayPickups: json['todayPickups']
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
  final String? collectionStatusName;
  final String? collectionTypeName;
  final String? description;
  final double? collectionSize;
  final DateTime? createdDate;
  final String? image;
  final Generator? generator;
  final Generator? picker;

  CollectionResponse({
    required this.collectionID,
    required this.generatorID,
    this.pickerID,
    this.notificationID,
    this.collectionStatusName,
    this.collectionTypeName,
    required this.collectionStatusID,
    required this.wasteTypeID,
    this.wasteTypeName,
    this.collectionSize,
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
      collectionTypeName: json['collectionTypeName'],
      collectionStatusName: json['collectionStatusName'],
      collectionSize: (json['collectionSize'] != null) ? json['collectionSize'].toDouble() : null,
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

class NotificationListResource {
  final int notificationID;
  final int notificationTypeID;
  final String? notificationTypeName;
  final String? description;
  final DateTime? createdDate;

  NotificationListResource({
    required this.notificationID,
    required this.notificationTypeID,
    this.notificationTypeName,
    this.description,
    this.createdDate,
  });

  factory NotificationListResource.fromJson(Map<String, dynamic> json) {
    return NotificationListResource(
      notificationID: json['notificationID'],
      notificationTypeID: json['notificationTypeID'],
      description: json['description'],
      notificationTypeName: json['notificationTypeName'],
      createdDate: json['createdDate'] != null 
          ? DateTime.parse(json['createdDate'])
          : null,
    );
  }
}

class PickerListResource {
  final int id;
  final String? manualId;
  final String? name;
  final String? email;
  final String? phone;
  final int? locationId;
  final String? locationName;
  final double? collectionCount;
  final String? image;
  final List<CollectionPickerResource>? collections;  // Add this line

  PickerListResource({
    required this.id,
    this.manualId,
    this.name,
    this.email,
    this.phone,
    this.locationId,
    this.locationName,
    this.collectionCount,
    this.image,
    this.collections, // Add this line
  });

  factory PickerListResource.fromJson(Map<String, dynamic> json) {
    return PickerListResource(
      id: json['id'] as int? ?? 0, // Handle null with default value
      manualId: json['manualID'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      locationName: json['locationName'] as String?,
      collectionCount: (json['collectionCount'] as num?)?.toDouble(),
      locationId: json['locationID'] as int? ?? 0,
      image: json['image'] as String?,
      collections: json['Collections'] != null
        ? (json['Collections'] as List)
            .map((e) => CollectionPickerResource.fromJson(e as Map<String, dynamic>))
            .toList()
        : null, // Parse collections if not null
    );
  }
}


class CollectionPickerResource {
  final int collectionID;
  final int collectionStatusID;

  CollectionPickerResource({
    required this.collectionID,
    required this.collectionStatusID,
  });

  factory CollectionPickerResource.fromJson(Map<String, dynamic> json) {
    return CollectionPickerResource(
      collectionID: json['CollectionID'] as int,
      collectionStatusID: json['CollectionStatusID'] as int,
    );
  }
}


class GeneratorListResource {
  final int id;
  final String? manualId;
  final String? name;
  final String? email;
  final String? phone;
  final int? locationId;
  final String? locationName;
  final double? collectionCount;
  final String? image;

  GeneratorListResource({
    required this.id,
    this.manualId,
    this.name,
    this.email,
    this.phone,
    this.locationId,
    this.locationName,
    this.collectionCount,
    this.image,
  });

  factory GeneratorListResource.fromJson(Map<String, dynamic> json) {
    return GeneratorListResource(
      id: json['id'] as int? ?? 0, // Handle null with default value
      manualId: json['manualID'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      locationName: json['locationName'] as String?,
      collectionCount: (json['collectionCount'] as num?)?.toDouble(),
      locationId: json['locationID'] as int? ?? 0,
      image: json['image'] as String?
    );
  }
}

class CollectionModel {
  int? collectionID;
  int? generatorID;
  int? pickerID;
  int? invoiceID;
  int? collectionStatusID;
  int? collectionTypeID;
  int? wasteTypeID;
  DateTime? createdDate;
  double? collectionSize;
  String? description;

  CollectionModel({
    this.collectionID,
    this.generatorID,
    this.pickerID,
    this.invoiceID,
    this.collectionStatusID,
    this.collectionTypeID,
    this.wasteTypeID,
    this.createdDate,
    this.collectionSize,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'collectionID': collectionID,
    'generatorID': generatorID,
    'pickerID': pickerID,
    'invoiceID': invoiceID,
    'collectionStatusID': collectionStatusID,
    'collectionTypeID': collectionTypeID,
    'wasteTypeID': wasteTypeID,
    'createdDate': createdDate?.toIso8601String(),
    'collectionSize': collectionSize,
    'description': description,
  };
}