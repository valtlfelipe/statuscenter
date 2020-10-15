import 'package:statuscenter/clients/http_client.dart';
import 'package:statuscenter/models/incident.dart';
import 'package:statuscenter/models/incident_history.dart';
import 'package:statuscenter/models/incident_impact.dart';
import 'package:statuscenter/models/incident_status.dart';

class IncidentsClient extends HTTPClient {
  Future<List<Incident>> getOpenIncidents() async {
    String pageID = await this.getRequestPageId();
    List responseJSON =
        await this.requestGet('/pages/$pageID/incidents/unresolved');
    return responseJSON.map((p) => new Incident.fromJson(p)).toList();
  }


  Future<List<Incident>> getIncidents() async {
    String pageID = await this.getRequestPageId();
    List responseJSON =
        await this.requestGet('/pages/$pageID/incidents?limit=5');
    return responseJSON.map((p) => new Incident.fromJson(p)).toList();
  }
  Future<Incident> deleteIncident(String id) async {
    String pageID = await this.getRequestPageId();
    Map responseJSON =
        await this.requestdelete('/pages/$pageID/incidents/$id');
    return new Incident.fromJson(responseJSON);
  }

  Future<List<Incident>> getMaintenaces() async {
    String pageID = await this.getRequestPageId();
    List responseJSON =
        await this.requestGet('/pages/$pageID/incidents/scheduled');
    return responseJSON.map((p) => new Incident.fromJson(p)).toList();
  }

  Future<Incident> getIncident(String id) async {
    String pageID = await this.getRequestPageId();
    Map responseJSON = await this.requestGet('/pages/$pageID/incidents/$id');
    return new Incident.fromJson(responseJSON);
  }

  Future<Incident> createNewUpdate(String id, IncidentHistory history) async {
    String pageID = await this.getRequestPageId();
    Map data = {
      'incident': {
        'status': history.status,
        'body': history.body,
        'components': Map.fromIterable(history.components,
            key: (c) => c.code, value: (c) => c.newStatus)
      }
    };
    Map responseJSON =
        await this.requestPatch('/pages/$pageID/incidents/$id', data);
    return new Incident.fromJson(responseJSON);
  }

  Future<Incident> createNew(Incident incident) async {
    String pageID = await this.getRequestPageId();
    Map data = {
      'incident': {
        'name': incident.name,
        'status': incident.status,
        'body': incident.body,
        'components': Map.fromIterable(incident.components,
            key: (c) => c.id, value: (c) => c.status),
        'component_ids': incident.components.map((c) => c.id).toList()
      }
    };
    Map responseJSON = await this.requestPost('/pages/$pageID/incidents', data);
    return new Incident.fromJson(responseJSON);
  }

  Future<Incident> createNewMaintenance(Incident incident) async {
    String pageID = await this.getRequestPageId();
    Map data = {
      'incident': {
        'name': incident.name,
        'body': incident.body,
        'scheduled_for': incident.scheduledFor.toIso8601String(),
        'scheduled_until': incident.scheduledUntil.toIso8601String(),
        'component_ids': incident.components.map((c) => c.id).toList(),
        'status': IncidentStatusScheduled.key,
        'impact_override': IncidentImpactMaintenance.key,
      }
    };
    Map responseJSON = await this.requestPost('/pages/$pageID/incidents', data);
    return new Incident.fromJson(responseJSON);
  }
}
