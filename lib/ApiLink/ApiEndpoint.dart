class ApiEndpoints {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    if (isProduction) {
      return "https://api.siddiquitd.com/api";
     //return "https://api.citytradersmis.com/api";
    } else {
     // return "https://api.citytradersmis.com/api";
      return "http://localhost:5000/api"; // Android emulator localhost
     //return "https://api.siddiquitd.com/api";
    }
  }
}