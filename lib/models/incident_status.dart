class IncidentStatus {
  final String key;
  final String name;

  const IncidentStatus({this.key, this.name});
}

const IncidentStatusInvestigating = IncidentStatus(key: 'investigating', name: 'Investigating');
const IncidentStatusIdentified = IncidentStatus(key: 'identified', name: 'Identified');
const IncidentStatusMonitoring = IncidentStatus(key: 'monitoring', name: 'Monitoring');
const IncidentStatusResolved = IncidentStatus(key: 'resolved', name: 'Resolved');

const List<IncidentStatus> IncidentStatusList = [
  IncidentStatusInvestigating,
  IncidentStatusIdentified,
  IncidentStatusMonitoring,
  IncidentStatusResolved,
];
