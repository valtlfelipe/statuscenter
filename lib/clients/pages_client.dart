import 'package:statuscenter/clients/http_client.dart';
import 'package:statuscenter/models/page.dart';

class PagesClient extends HTTPClient {
  String apiKey;

  PagesClient(this.apiKey);

  Future<List<Page>> getPages() async {
    this.setCustomAPIKey(apiKey);
    List responseJSON = await this.requestGet('/pages');
    return responseJSON.map((p) => new Page.fromJson(p)).toList();
  }
}
