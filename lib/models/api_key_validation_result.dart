import 'package:statuspageapp/clients/pages_client.dart';

class APIKeyValidationResult {
  bool valid;
  String error;
  String apiKey;
  Page page;

  APIKeyValidationResult({this.valid, this.error, this.apiKey, this.page});
}
