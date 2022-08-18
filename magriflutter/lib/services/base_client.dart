import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:magri/util/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'app_exception.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class BaseClient {
  static const int TIME_OUT_DURATION = 20;
  Future<String> getToken() async {
    final SharedPreferences prefs = await _prefs;
    String? token = await prefs.getString('token');

    var bearerToken = 'Bearer ' + token.toString();

    return bearerToken;
  }

  // GET
  Future<dynamic> get(String api, {bool? getCache = false}) async {
    String? token = await getToken();

    var uri = Uri.parse(Constants.base + api);

    print(Constants.base + api);

    print(uri.host);

    try {
      var response = await http.get(uri, headers: <String, String>{
        'Accept': 'application/json',
        'Authorization': token
      }).timeout(Duration(seconds: TIME_OUT_DURATION));

      return _processResponse(response);
    } on SocketException {
      //
    } on TimeoutException {
      //
    }
  }

  Future<dynamic> post(String api, dynamic payloadObj) async {
    try {
      var response = await http
          .post(Uri.parse(Constants.base + api),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': await getToken()
              },
              body: json.encode(payloadObj))
          .timeout(Duration(seconds: TIME_OUT_DURATION));

      return _processResponse(response);
    } on SocketException {
      //
    } on TimeoutException {
      //
    }
  }

  dynamic _processResponse(http.Response response, {String dataKey = 'data'}) {
    print(response.statusCode);
    print(response.request!.url.path);
    switch (response.statusCode) {
      case 200:
        Map<String, dynamic>? map = json.decode(response.body);
        return map![dataKey];
      case 400:
        throw BadRequestException('', response.request!.url.path);
      case 401:
      case 403:
      case 404:
        toast(message: 'Not found');
        break;
      // throw NotFoundException('', response.request!.url.path);
      case 500:
        toast(message: 'Error 500');
        break;
      // throw ApiNotRespondingException('', response.request!.url.path);
      // print(response.body);
      // break;
      case 503:
        throw SiteMaintenanceException('', response.request!.url.path);
      default:
      // throw fet
    }

    Map<String, dynamic> map = json.decode(response.body);
    return map[dataKey];
  }

  void handleError(error) {
    //
  }
}
