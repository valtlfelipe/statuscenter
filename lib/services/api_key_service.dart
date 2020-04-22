import 'package:statuspageapp/clients/pages_client.dart';
import 'package:statuspageapp/models/api_key_validation_result.dart';

class APIKeyValidationService {
  static Future<APIKeyValidationResult> validate(String apiKey) async {
    List<Page> pages = await new PagesClient(apiKey).getPages();
    if (pages != null && pages.length >= 1) {
      return new APIKeyValidationResult(
          valid: true, apiKey: apiKey, page: pages[0]);
    }

    return new APIKeyValidationResult(
        valid: false); // TODO: handle errors better
  }
}
