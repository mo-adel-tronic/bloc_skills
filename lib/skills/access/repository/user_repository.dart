class UserData {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

/// UserRepository acts as the data layer interface.
/// In production, this would call REST APIs (Dio/http) or local storage (Hive/SQLite).
class UserRepository {
  Future<UserData> fetchUser(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (id == 'user_1') {
      return const UserData(
        id: 'user_1',
        name: 'Sarah Connor',
        email: 'sarah.connor@sky.net',
        role: 'Lead Architect',
      );
    } else if (id == 'user_2') {
      return const UserData(
        id: 'user_2',
        name: 'John Doe',
        email: 'john.doe@flutter.io',
        role: 'Mobile Engineer',
      );
    } else {
      throw Exception('User with ID "$id" not found in database.');
    }
  }
}
