import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statuscenter/clients/pages_client.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/models/page.dart';

class AuthService {
  static const String APIKEY_KEY = 'apiKey';
  static const String PAGEDATA_KEY = 'pageData';

  static Future<bool> isLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthService.APIKEY_KEY) != null &&
        prefs.getString(AuthService.PAGEDATA_KEY) != null;
  }

  static Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthService.APIKEY_KEY);
    await prefs.remove(AuthService.PAGEDATA_KEY);
  }

  static Future login(String apiKey, Page page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthService.APIKEY_KEY, apiKey);
    await prefs.setString(AuthService.PAGEDATA_KEY, jsonEncode(page.toJson()));
  }

  static Future<AuthData> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString(AuthService.APIKEY_KEY);
    Page page = new Page.fromJson(
        json.decode(prefs.getString(AuthService.PAGEDATA_KEY)));
    return new AuthData(apiKey: apiKey, page: page);
  }

  static getUpdatedData() async {
    AuthData data = await AuthService.getData();
    data.page = await new PagesClient(data.apiKey).getPage(data.page.id);
    await AuthService.login(data.apiKey, data.page);
    return data;
  }
}
