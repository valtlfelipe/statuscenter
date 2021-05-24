import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:statuscenter/exceptions/request_exception.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/services/auth_service.dart';

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

  _getResponseJSON(http.Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }

  _handleError(int statusCode, json) {
    if (statusCode >= 400 && statusCode <= 499) {
      if (json['error'] != null) {
        throw new RequestException(json['error']);
      } else if (json['message'] != null) {
        throw new RequestException(json['message']);
      }
    } else if (statusCode >= 500) {
      throw new RequestException('Internal server error');
    }
  }

  Future requestGet(String path) async {
    http.Response response = await http.get(Uri.parse('$_baseURL/$path'),
        headers: await this._getDefaultHeaders());

    var json = this._getResponseJSON(response);
    this._handleError(response.statusCode, json);

    return json;
  }

  Future requestdelete(String path) async {
    http.Response response = await http.delete(Uri.parse('$_baseURL/$path'),
        headers: await this._getDefaultHeaders());

    var json = this._getResponseJSON(response);
    this._handleError(response.statusCode, json);

    return json;
  }

  Future requestPatch(String path, Map data) async {
    Map headers = await this._getDefaultHeaders();
    headers['content-type'] = 'application/json; charset=UTF-8';
    http.Response response = await http.patch(Uri.parse('$_baseURL/$path'),
        headers: headers, body: jsonEncode(data));

    var json = this._getResponseJSON(response);
    this._handleError(response.statusCode, json);

    return json;
  }

  Future requestPost(String path, Map data) async {
    Map headers = await this._getDefaultHeaders();
    headers['content-type'] = 'application/json; charset=UTF-8';
    http.Response response = await http.post(Uri.parse('$_baseURL/$path'),
        headers: headers, body: jsonEncode(data));

    var json = this._getResponseJSON(response);
    this._handleError(response.statusCode, json);

    return json;
  }
}
