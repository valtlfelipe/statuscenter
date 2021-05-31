import 'package:statuscenter/clients/http_client.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/models/status.dart';

class StatusClient extends HTTPClient {
  Future<Status> getStatus() async {
    AuthData authData = await this.getAuthData();
    this.setCustomBaseURL('https://${authData.page.subdomain}.statuspage.io/');
    Map responseJSON = await this
        .requestGet('/api/v2/summary.json?api_key=${authData.apiKey}');
    return new Status.fromJson(responseJSON);
  }
}
