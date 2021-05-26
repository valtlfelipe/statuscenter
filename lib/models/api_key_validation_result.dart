import 'package:statuscenter/models/page.dart';

class APIKeyValidationResult {
  bool valid;
  String error;
  List<Page> pages;

  APIKeyValidationResult({this.valid, this.error, this.pages});
}
