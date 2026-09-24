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

/// Gym staff roles — these get the staff shell (dashboard, members, ...).
const staffRoleNames = ['admin', 'receptionist', 'trainer'];

/// A gym member — gets the member portal shell (their own membership,
/// QR check-in code, plans, progress) instead of the staff screens.
const memberRoleName = 'member';

/// Every per-gym role this app accepts at login. The platform owner
/// (super_admin) has no gym role and must use the web dashboard.
const appRoleNames = [...staffRoleNames, memberRoleName];

bool isMemberRole(String? roleName) => roleName == memberRoleName;

/// Write actions gated beyond "can see the screen". Mirrors the backend
/// FormRequest authorize() checks (StoreMemberRequest,
/// RenewMembershipRequest) — a trainer can view members but not add or
/// renew them.
enum StaffAction { createMember, renewMembership }

const _actionRoles = <StaffAction, List<String>>{
  StaffAction.createMember: ['admin', 'receptionist'],
  StaffAction.renewMembership: ['admin', 'receptionist'],
};

bool canPerform(String? roleName, StaffAction action) {
  if (roleName == null) return false;
  return _actionRoles[action]?.contains(roleName) ?? false;
}
