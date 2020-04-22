import 'package:http/http.dart' as http;
import 'dart:convert';

class PagesClient {
  String apiKey;

  PagesClient(this.apiKey);

  Future<List<Page>> getPages() async {
    http.Response response = await http
        .get('https://api.statuspage.io/v1/pages?api_key=${this.apiKey}');
    List responseJson = json.decode(response.body);
    return responseJson.map((p) => new Page.fromJson(p)).toList();
  }
}

class Page {
  final String id;
  final String name;

  Page({this.id, this.name});

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
