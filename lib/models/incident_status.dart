class IncidentStatus {
  final String key;
  final String name;

  const IncidentStatus({this.key, this.name});
}

const IncidentStatusInvestigating =
    IncidentStatus(key: 'investigating', name: 'Investigating');
const IncidentStatusIdentified =
    IncidentStatus(key: 'identified', name: 'Identified');
const IncidentStatusMonitoring =
    IncidentStatus(key: 'monitoring', name: 'Monitoring');
const IncidentStatusResolved =
    IncidentStatus(key: 'resolved', name: 'Resolved');
const IncidentStatusCompleted =
    IncidentStatus(key: 'completed', name: 'Completed');
const IncidentStatusPostmortem =
    IncidentStatus(key: 'postmortem', name: 'Resolved');
const IncidentStatusUpdate = IncidentStatus(key: 'update', name: 'Update');
const IncidentStatusScheduled =
    IncidentStatus(key: 'scheduled', name: 'Scheduled');
const IncidentStatusInProgres =
    IncidentStatus(key: 'in_progress', name: 'In progress');
const IncidentStatusVerifying =
    IncidentStatus(key: 'verifying', name: 'Verifying');

const List<IncidentStatus> AllIncidentStatusList = [
  IncidentStatusInvestigating,
  IncidentStatusIdentified,
  IncidentStatusMonitoring,
  IncidentStatusResolved,
  IncidentStatusCompleted,
  IncidentStatusPostmortem,
  IncidentStatusUpdate,
  IncidentStatusScheduled,
  IncidentStatusInProgres,
  IncidentStatusVerifying,
];

const List<IncidentStatus> IncidentStatusList = [
  IncidentStatusInvestigating,
  IncidentStatusIdentified,
  IncidentStatusMonitoring,
  IncidentStatusResolved
];
