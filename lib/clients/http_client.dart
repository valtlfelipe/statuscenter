import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:statuspageapp/models/auth_data.dart';
import 'package:statuspageapp/services/auth_service.dart';

class HTTPClient {
  final String _baseURL = 'https://api.statuspage.io/v1/';
  AuthData _authData;
  String _customAPIKey;

  Future<AuthData> _getAuthData() async {
    if (this._authData == null) {
      this._authData = await AuthService.getData();
    }

    return this._authData;
  }

  Future<String> getRequestPageId() async {
    return (await this._getAuthData()).page.id;
  }

  void setCustomAPIKey(String apiKey) {
    this._customAPIKey = apiKey;
  }

  Future<String> getRequestApiKey() async {
    if (this._customAPIKey != null) {
      return this._customAPIKey;
    }
    return (await this._getAuthData()).apiKey;
  }

  Future<Map<String, String>> _getDefaultHeaders() async {
    String apiKey = await this.getRequestApiKey();
    return <String, String>{
      'authorization': '$apiKey',
      'user-agent': 'Status Center APP (statuscenterapp@felipe.im)'
    };
  }

  Future requestGet(String path) async {
    http.Response response = await http.get('$_baseURL/$path',
        headers: await this._getDefaultHeaders());

    // TODO: if (response.statusCode == 200) {

    return json.decode(utf8.decode(response.bodyBytes));
  }

  Future requestPatch(String path, Map data) async {
    Map headers = await this._getDefaultHeaders();
    headers['content-type'] = 'application/json; charset=UTF-8';
    http.Response response = await http.patch('$_baseURL/$path',
        headers: headers, body: jsonEncode(data));

    // TODO: if (response.statusCode == 200) {

    return json.decode(utf8.decode(response.bodyBytes));
  }

  Future requestPost(String path, Map data) async {
    Map headers = await this._getDefaultHeaders();
    headers['content-type'] = 'application/json; charset=UTF-8';
    http.Response response = await http.post('$_baseURL/$path',
        headers: headers, body: jsonEncode(data));

    // TODO: if (response.statusCode == 200) {

    return json.decode(utf8.decode(response.bodyBytes));
  }
}
