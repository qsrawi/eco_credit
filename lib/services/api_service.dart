import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  
  static const String baseUrl = 'https://10.0.2.2:7254/api'; // For Android emulator
  //static const String baseUrl = 'https://pos1.io/ecoRide/api';

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

  static Future<http.Response?> createInvoice(Map<String, dynamic> collectionData, File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/collections/createInvoice');
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

    addFieldIfNotNull('CollectionID', collectionData['CollectionID']);
    addFieldIfNotNull('InvoiceSize', collectionData['InvoiceSize']);
    addFieldIfNotNull('WasteTypeID', collectionData['WasteTypeID']);
    addFieldIfNotNull('ScarpyardOwner', collectionData['ScarpyardOwner']);

    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'InvoiceImage',
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

  static Future<http.Response?> register(Map<String, dynamic> user, File? imageFile, String type) async {
    // createLookups();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/users/register');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token'  // Include the token in the header
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

    // Add user fields
    addFieldIfNotNull('Name', user['Name']);
    addFieldIfNotNull('Password', user['Password']);
    addFieldIfNotNull('Email', user['Email']);
    addFieldIfNotNull('Phone', user['Phone']);
    addFieldIfNotNull('LocationID', user['LocationID']);
    addFieldIfNotNull('WasteTypeID', user['WasteTypeID']);
    addFieldIfNotNull('PreferdWasteGroupID', user['PreferdWasteGroupID']);
    addFieldIfNotNull('WasteGroupIDs', user['WasteGroupIDs']);

    // Add the 'type' field
    addFieldIfNotNull('type', type);

    if (imageFile != null) {
      String fileName = imageFile.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'UserImage',
          imageFile.path,
          contentType: MediaType('UserImage', fileName.split('.').last),
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return response;
      } else {
        print('Failed to create user: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception when calling API: $e');
      return null;
    }
  }


  Future<void> updateCollection(CollectionUpdateModel model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    
    var url = Uri.parse('$baseUrl/collections/update'); // Adjust endpoint as necessary

    var headers = {
      'Content-Type': 'application/json', // Specify JSON content type
      'Authorization': 'Bearer $token'    // Include the token in the header
    };

    var body = jsonEncode({
      'CollectionID': model.collectionID,
      'CollectionStatusID': model.collectionStatusID,
      'CollectionSize': model.collectionSize,
      'PickerID': model.pickerID
    });

    try {
      var response = await http.put(url, headers: headers, body: body);

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
    var url = Uri.parse('$baseUrl/users/login');
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
          int wasteTypeID = jsonResponse['wasteTypeID'];
          String name = jsonResponse['name'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setInt('id', id);
          await prefs.setString('role', role);
          await prefs.setInt('wasteTypeID', wasteTypeID);
          await prefs.setString('name', name);

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

  static void createLookups() async {
    var url = Uri.parse('$baseUrl/lookups/create');
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        }
      );

      if (response.statusCode != 200) {
        var error = jsonDecode(response.body);
        throw Exception('Failed to login with status code: ${response.statusCode}, Error: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  static void deleteUser(int id, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    var url = Uri.parse('$baseUrl/users/$id/delete?type=$type'); // Add type as a query parameter
    
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include the authorization token
        }
      );

      if (response.statusCode != 200) {
        var error = jsonDecode(response.body);
        throw Exception('Failed to delete user with status code: ${response.statusCode}, Error: ${error['message']}');
      }

      // If the request is successful, you can handle the response here
      var responseData = jsonDecode(response.body);
      print('User deleted successfully: $responseData');

    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<CollectionMainResource> getCollections(int status, { int? userId, String? userType, int page = 1, int pageSize = 5 }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/collections')
      .replace(queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'collectionStatus': status.toString(),
        'userID': userId?.toString(),
        'userType': userType,
      });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',  // Use the token here
    });

    if (response.statusCode == 200) {
      return CollectionMainResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<InvoiceResource> getInvoiceById(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/collections/invoice/$id');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',  // Use the token here
    });

    if (response.statusCode == 200) {
      return InvoiceResource.fromJson(json.decode(response.body));
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

  Future<PickerMainResource> getPickers(int? wasteGroupID, int? generatorID, String? strSearch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/pickers')
      .replace(queryParameters: {
        'page': '1',
        'pageSize': '-1',
        'wasteGroupID': wasteGroupID?.toString(),
        'generatorID': generatorID?.toString(),
        'strSearch': strSearch,
      });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      return PickerMainResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<GeneratorMainResource> getAllGenerators() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/generators')
      .replace(queryParameters: {
        'page': '1',
        'pageSize': '-1'
      });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      return GeneratorMainResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<KpiResource> getGeneratorKpi(int generatorID, int? months) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/kpi/generatorKpi/${generatorID.toString()}');
    if (months != null) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, 'months': months.toString()});
    }
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      return KpiResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<KpiResource> getPickerKpi(int pickerID, int? months) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/kpi/pickerKpi/${pickerID.toString()}');
    if (months != null) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, 'months': months.toString()});
    }
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      return KpiResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<KpiResource> getLocationKpi(int locationID, int? months) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/kpi/locationKpi/${locationID.toString()}');
    if (months != null) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, 'months': months.toString()});
    }
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      return KpiResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<KpiResource> getWasteCategoriesKpi(int? months) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/kpi/wasteCategoriesKpi');
    if (months != null) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, 'months': months.toString()});
    }
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      return KpiResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<KpiResource> getSuccessfulCollectionsKpi(int? months) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var uri = Uri.parse('$baseUrl/kpi/successfulCollectionsKpi');
    if (months != null) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, 'months': months.toString()});
    }
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      return KpiResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<LookupsResource>> getLookups(String categoryCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/lookups/$categoryCode');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => LookupsResource.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load collections: ${response.statusCode} ${response.body}');
    }
  }

  Future<GeneratorResource> fetchProfile(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/pickers/$id');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });

    if (response.statusCode == 200) {
      return GeneratorResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<GeneratorResource> fetchAdminProfile(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/admins/$id');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });

    if (response.statusCode == 200) {
      return GeneratorResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<GeneratorResource> fetchGeneratorsProfile(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    
    final uri = Uri.parse('$baseUrl/generators/$id');

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });
    if (response.statusCode == 200) {
      return GeneratorResource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<List<NotificationListResource>> fetchNotifications(int? userId, String? userType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/notifications')
      .replace(queryParameters: {
        'userID': userId?.toString(),
        'userType': userType,
      });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });

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

  Future<int> getAllUnreadNotificationCount(int? userId, String? userType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final uri = Uri.parse('$baseUrl/notifications/getAllUnreadNotifications')
      .replace(queryParameters: {
        'userID': userId?.toString(),
        'userType': userType,
      });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token', // Use the token here
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
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

class CollectionMainResource {
  final List<CollectionResponse> lstData;
  final int? rowsCount;

  CollectionMainResource({
    required this.lstData,
    this.rowsCount
  });

  factory CollectionMainResource.fromJson(Map<String, dynamic> json) => CollectionMainResource(
    lstData: List<CollectionResponse>.from(json['lstData'].map((x) => CollectionResponse.fromJson(x))),
    rowsCount: json['rowsCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'lstData': lstData,
    'rowsCount': rowsCount,
  };
}

class CollectionResponse {
  final int collectionID;
  final int generatorID;
  final int? pickerID;
  final int? invoiceID;
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
  final bool? isInvoiced;
  final Generator? generator;
  final Generator? picker;
  final Invoice? invoice;

  CollectionResponse({
    required this.collectionID,
    required this.generatorID,
    this.pickerID,
    this.notificationID,
    this.invoiceID,
    this.collectionStatusName,
    this.collectionTypeName,
    required this.collectionStatusID,
    required this.wasteTypeID,
    this.wasteTypeName,
    this.collectionSize,
    this.description,
    this.createdDate,
    this.isInvoiced,
    this.image,
    this.generator,
    this.picker,
    this.invoice,
  });

  factory CollectionResponse.fromJson(Map<String, dynamic> json) {
    return CollectionResponse(
      collectionID: json['collectionID'],
      generatorID: json['generatorID'],
      pickerID: json['pickerID'],
      notificationID: json['notificationID'],
      invoiceID: json['invoiceID'],
      collectionStatusID: json['collectionStatusID'],
      collectionTypeName: json['collectionTypeName'],
      collectionStatusName: json['collectionStatusName'],
      collectionSize: (json['collectionSize'] != null) ? json['collectionSize'].toDouble() : null,
      wasteTypeID: json['wasteTypeID'],
      wasteTypeName: json['wasteTypeName'],
      description: json['description'],
      isInvoiced: json['isInvoiced'],
      createdDate: DateTime.parse(json['createdDate']),
      image: json['image'] != null ? 'https://10.0.2.2:7254/${json['image']}' : null,
      generator: json['generator'] != null ? Generator.fromJson(json['generator']) : null,
      picker: json['picker'] != null ? Generator.fromJson(json['picker']) : null,
      invoice: json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null,
    );
  }
}

class Generator {
  final String name;
  final String? phone;
  final String? imageUrl;

  Generator({required this.name, this.phone, this.imageUrl});

  factory Generator.fromJson(Map<String, dynamic> json) {
    return Generator(
      name: json['name'],
      phone: json['phone'],
      imageUrl: json['imageUrl'],
    );
  }
}

class Invoice {
  final int invoiceID;
  final double? invoiceSize;
  final int? wasteTypeID;
  final int? collectionID;
  final String? scarpyardOwner;
  final String? image;

  Invoice({
    required this.invoiceID,
     this.invoiceSize,
     this.wasteTypeID,
     this.collectionID,
     this.scarpyardOwner,
     this.image
    });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceID: json['invoiceID'],
      invoiceSize: (json['invoiceSize'] != null) ? json['invoiceSize'].toDouble() : null,
      wasteTypeID: json['wasteTypeID'],
      collectionID: json['collectionID'],
      scarpyardOwner: json['scarpyardOwner'],
      image: json['image']
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

class PickerMainResource {
  final List<PickerListResource> lstData;
  final int? rowsCount;

  PickerMainResource({
    required this.lstData,
    this.rowsCount
  });

  factory PickerMainResource.fromJson(Map<String, dynamic> json) => PickerMainResource(
    lstData: List<PickerListResource>.from(json['lstData'].map((x) => PickerListResource.fromJson(x))),
    rowsCount: json['rowsCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'lstData': lstData,
    'rowsCount': rowsCount,
  };
}

class PickerListResource {
  final int id;
  final String? manualId;
  final String? name;
  final String? email;
  final String? phone;
  final int? locationId;
  final String? locationName;
  final double? collectionsCount;
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
    this.collectionsCount,
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
      collectionsCount: (json['collectionsCount'] as num?)?.toDouble(),
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

class GeneratorMainResource {
  final List<GeneratorListResource> lstData;
  final int? rowsCount;

  GeneratorMainResource({
    required this.lstData,
    this.rowsCount
  });

  factory GeneratorMainResource.fromJson(Map<String, dynamic> json) => GeneratorMainResource(
    lstData: List<GeneratorListResource>.from(json['lstData'].map((x) => GeneratorListResource.fromJson(x))),
    rowsCount: json['rowsCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'lstData': lstData,
    'rowsCount': rowsCount,
  };
}

class GeneratorListResource {
  final int id;
  final String? manualId;
  final String? name;
  final String? email;
  final String? phone;
  final int? locationId;
  final String? locationName;
  final double? collectionsCount;
  final String? image;

  GeneratorListResource({
    required this.id,
    this.manualId,
    this.name,
    this.email,
    this.phone,
    this.locationId,
    this.locationName,
    this.collectionsCount,
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
      collectionsCount: (json['collectionsCount'] as num?)?.toDouble(),
      locationId: json['locationID'] as int? ?? 0,
      image: json['image'] as String?
    );
  }
}

class CollectionUpdateModel {
  int? collectionID;
  int? pickerID;
  int? collectionStatusID;
  double? collectionSize;

  CollectionUpdateModel({
    this.collectionID,
    this.pickerID,
    this.collectionStatusID,
    this.collectionSize
  });

  Map<String, dynamic> toJson() => {
    'collectionID': collectionID,
    'pickerID': pickerID,
    'collectionStatusID': collectionStatusID,
    'collectionSize': collectionSize,
  };
}

class KpiResource {
  List<WasteTypeStatus>? wasteTypeStatus;

  KpiResource({
    this.wasteTypeStatus
  });

  factory KpiResource.fromJson(Map<String, dynamic> json) {
    return KpiResource(
      wasteTypeStatus: json['wasteTypeStatus'] != null
        ? (json['wasteTypeStatus'] as List)
            .map((e) => WasteTypeStatus.fromJson(e as Map<String, dynamic>))
            .toList()
        : null, 
    );
  }
  Map<String, dynamic> toJson() => {
    'wasteTypeStatus': wasteTypeStatus,
  };
}

class WasteTypeStatus {
  int? wasteTypeID;
  String? wasteTypeName;
  int? collectionsCount;
  double? collectionAmount;

  WasteTypeStatus({
    this.wasteTypeID,
    this.wasteTypeName,
    this.collectionsCount,
    this.collectionAmount
  });

  factory WasteTypeStatus.fromJson(Map<String, dynamic> json) {
    return WasteTypeStatus(
      wasteTypeID: json['wasteTypeID'] as int? ?? 0, // Handle null with default value
      wasteTypeName: json['wasteTypeName'] as String?,
      collectionAmount: (json['collectionAmount'] as num?)?.toDouble(),
      collectionsCount: json['collectionsCount'] as int? ?? 0
    );
  }
}

class LookupsResource {
  int? lkpID;
  String? lkpType;
  String? value;
  String? nearby;


  LookupsResource({
    this.lkpID,
    this.lkpType,
    this.value,
    this.nearby
  });

  factory LookupsResource.fromJson(Map<String, dynamic> json) {
    return LookupsResource(
      lkpID: json['lkpID'] as int? ?? 0, // Handle null with default value
      lkpType: json['lkpType'] as String?,
      value: json['value'] as String?,
      nearby: json['nearby'] as String?
    );
  }
}

class InvoiceResource {
  int invoiceID;
  double? invoiceSize;
  int? wasteTypeID;
  String? wasteTypeName;
  String? scarpyardOwner;
  String? image;

  InvoiceResource({
    required this.invoiceID,
    this.invoiceSize,
    this.wasteTypeID,
    this.wasteTypeName,
    this.scarpyardOwner,
    this.image
  });

  factory InvoiceResource.fromJson(Map<String, dynamic> json) {
    return InvoiceResource(
      invoiceID: json['invoiceID'] as int? ?? 0, // Handle null with default value
      invoiceSize: (json['invoiceSize'] as num?)?.toDouble(),
      wasteTypeID: json['wasteTypeID'] as int? ?? 0,
      wasteTypeName: json['wasteTypeName'] as String?,
      scarpyardOwner: json['scarpyardOwner'] as String?,
      image: json['image'] as String?
    );
  }
}