class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'ADMIN', 'MAHASISWA', 'DOSEN', 'STAF'
  final String? department;
  final String? phone;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Pengguna',
      email: json['email'] as String? ?? '',
      role: (json['role'] as String? ?? 'MAHASISWA').toUpperCase(),
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  bool get isAdmin => role == 'ADMIN';

  String get roleLabel {
    switch (role) {
      case 'ADMIN':
        return 'Administrator';
      case 'DOSEN':
        return 'Dosen';
      case 'STAF':
        return 'Staf Kampus';
      case 'MAHASISWA':
      default:
        return 'Mahasiswa';
    }
  }
}
