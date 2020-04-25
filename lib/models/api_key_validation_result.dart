import 'package:statuscenter/models/page.dart';

class APIKeyValidationResult {
  bool valid;
  String error;
  String apiKey;
  Page page;

  APIKeyValidationResult({this.valid, this.error, this.apiKey, this.page});
}
