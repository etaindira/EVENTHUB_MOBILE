//For Windows desktop or Chrome use
class ApiConstants {
  static const String baseUrl = 'http://localhost:5000';

  static const String apiPrefix = '/api';

  static String get fullBaseUrl => '$baseUrl$apiPrefix';
}

//For Android emulator use
// class ApiConstants {
 // static const String baseUrl = 'http://10.0.2.2:5000';
//  static const String apiPrefix = '/api';

  // static String get fullBaseUrl => '$baseUrl$apiPrefix';
//}
// for real phone use computer ip address
// class ApiConstants {
 // static const String baseUrl = 'http://192.168.1.5:5000';
  // static const String apiPrefix = '/api';

 //  static String get fullBaseUrl => '$baseUrl$apiPrefix';
// }
