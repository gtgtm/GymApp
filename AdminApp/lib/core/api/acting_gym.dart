/// Mirrors the X-Gym-Id header the backend's ResolveActingGym middleware
/// reads (see Backend/app/Http/Middleware/ResolveActingGym.php): the gym,
/// among the login's memberships, that every request is scoped to.
class ActingGym {
  const ActingGym({required this.id, required this.name});

  final int id;
  final String name;
}

/// Holds the currently "entered" gym so ApiClient can attach it as a header,
/// without ApiClient depending on the auth feature directly. Mirrors the
/// UnauthorizedNotifier hub pattern in api_providers.dart.
class ActingGymHub {
  ActingGym? _current;

  ActingGym? get current => _current;

  void set(ActingGym gym) => _current = gym;

  void clear() => _current = null;
}
