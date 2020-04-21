import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:statuspageapp/models/component.dart';

class ComponentsClient {
  String apiKey;
  String pageId;

  ComponentsClient(this.apiKey, this.pageId);

  Future<List<Component>> getAll() async {
    http.Response response = await http.get(
        'https://api.statuspage.io/v1/pages/${this.pageId}/components?api_key=${this.apiKey}');
    // TODO: if (response.statusCode == 200) {
    List responseJson = json.decode(utf8.decode(response.bodyBytes));
    List<Component> components =
        responseJson.map((p) => new Component.fromJson(p)).toList();
    return components.where((c) => c.group == false).toList();
  }
}
