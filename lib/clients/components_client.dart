import 'package:statuscenter/clients/http_client.dart';
import 'package:statuscenter/models/component.dart';

class ComponentsClient extends HTTPClient {
  String apiKey;
  String pageId;

  ComponentsClient(this.apiKey, this.pageId);

  Future<List<Component>> getAll() async {
    String pageID = await this.getRequestPageId();
    List responseJSON = await this.requestGet('/pages/$pageID/components');
    List<Component> components =
        responseJSON.map((p) => new Component.fromJson(p)).toList();
    return components.where((c) => c.group == false).toList();
  }
}
