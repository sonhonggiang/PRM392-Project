enum UserRole {
  guest,
  user,
  creator,
  admin,
}

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = UserRole.guest,
    this.avatarUrl = '',
  });

  // Mock users
  static final UserModel mockAdmin = UserModel(
    id: 'admin_1',
    email: 'admin@origami.com',
    displayName: 'Admin Origami',
    role: UserRole.admin,
  );

  static final UserModel mockCreator = UserModel(
    id: 'creator_1',
    email: 'master@origami.com',
    displayName: 'Nghệ nhân Gấp Giấy',
    role: UserRole.creator,
  );

  static final UserModel mockUser = UserModel(
    id: 'user_1',
    email: 'user@origami.com',
    displayName: 'Sơn Giang',
    role: UserRole.user,
  );

  static final UserModel mockGuest = UserModel(
    id: 'guest_0',
    email: '',
    displayName: 'Khách',
    role: UserRole.guest,
  );
}
