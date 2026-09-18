/// Dart port of Admin/src/lib/permissions.ts — keep both in sync.
enum NavKey {
  dashboard,
  members,
  trainers,
  plans,
  payments,
  attendance,
  enquiries,
  trials,
  expenses,
  equipment,
  reports,
}

const _adminNavKeys = [
  NavKey.dashboard,
  NavKey.members,
  NavKey.trainers,
  NavKey.plans,
  NavKey.payments,
  NavKey.attendance,
  NavKey.enquiries,
  NavKey.trials,
  NavKey.expenses,
  NavKey.equipment,
  NavKey.reports,
];

const _roleNavAccess = <String, List<NavKey>>{
  // super_admin only sees gym-admin nav once it has entered a gym (see
  // ActingGymHub); the platform (gym directory) screen sits outside this
  // nav entirely, reached via its own shell.
  'super_admin': _adminNavKeys,
  'admin': _adminNavKeys,
  'receptionist': [
    NavKey.dashboard,
    NavKey.members,
    NavKey.payments,
    NavKey.attendance,
    NavKey.enquiries,
    NavKey.trials,
  ],
  'trainer': [NavKey.dashboard, NavKey.members, NavKey.attendance],
};

bool canAccessNav(String? roleName, NavKey key) {
  if (roleName == null) return false;
  return _roleNavAccess[roleName]?.contains(key) ?? false;
}

/// Roles this app accepts at login. Member accounts must use the member app.
const staffRoleNames = ['super_admin', 'admin', 'receptionist', 'trainer'];
