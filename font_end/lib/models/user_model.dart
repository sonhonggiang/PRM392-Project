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
  final int xp;
  final int streakCount;
  final int dailyMedals;
  final int weeklyTrophies;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = UserRole.guest,
    this.avatarUrl = '',
    this.xp = 0,
    this.streakCount = 0,
    this.dailyMedals = 0,
    this.weeklyTrophies = 0,
  });


  // Mock users
  static final UserModel mockAdmin = UserModel(
    id: 'admin_1',
    email: 'admin@origami.com',
    displayName: 'Admin trang gấp giấy',
    role: UserRole.admin,
    xp: 500,
    streakCount: 5,
  );

  static final UserModel mockCreator = UserModel(
    id: 'creator_1',
    email: 'master@origami.com',
    displayName: 'Nghệ nhân Gấp Giấy',
    role: UserRole.creator,
    xp: 250,
    streakCount: 3,
  );

  static final UserModel mockUser = UserModel(
    id: 'user_1',
    email: 'user@origami.com',
    displayName: 'Sơn Giang',
    role: UserRole.user,
    xp: 120,
    streakCount: 7,
  );

  static final UserModel mockGuest = UserModel(
    id: 'guest_0',
    email: '',
    displayName: '?????',
    role: UserRole.guest,
    xp: 0,
    streakCount: 0,
  );
}
