
// Enums for type safety
enum UserStatus {
  active,
  suspended,
  inactive;

  static UserStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'suspended':
        return UserStatus.suspended;
      case 'inactive':
        return UserStatus.inactive;
      default:
        return UserStatus.active; // Default fallback
    }
  }

  String get value {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.inactive:
        return 'inactive';
    }
  }
}

enum UserRole {
  user,
  peerSister,
  nurse,
  admin;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'user':
        return UserRole.user;
      case 'peer_sister':
        return UserRole.peerSister;
      case 'nurse':
        return UserRole.nurse;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user; // Default fallback
    }
  }

  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.peerSister:
        return 'peer_sister';
      case UserRole.nurse:
        return 'nurse';
      case UserRole.admin:
        return 'admin';
    }
  }
}

enum RiskLevel {
  low,
  moderate,
  high;

  static RiskLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'moderate':
        return RiskLevel.moderate;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.low; // Default fallback
    }
  }

  String get value {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.moderate:
        return 'Moderate';
      case RiskLevel.high:
        return 'High';
    }
  }
}

enum PrivacyLevel {
  public,
  private,
  friends;

  static PrivacyLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'public':
        return PrivacyLevel.public;
      case 'private':
        return PrivacyLevel.private;
      case 'friends':
        return PrivacyLevel.friends;
      default:
        return PrivacyLevel.private; // Default fallback
    }
  }

  String get value {
    switch (this) {
      case PrivacyLevel.public:
        return 'public';
      case PrivacyLevel.private:
        return 'private';
      case PrivacyLevel.friends:
        return 'friends';
    }
  }
}

// Health Preferences model
class HealthPreferences {
  final bool notifications;
  final PrivacyLevel privacyLevel;
  final String language;

  const HealthPreferences({
    this.notifications = true,
    this.privacyLevel = PrivacyLevel.private,
    this.language = 'en',
  });

  factory HealthPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HealthPreferences();
    
    return HealthPreferences(
      notifications: json['notifications'] as bool? ?? true,
      privacyLevel: PrivacyLevel.fromString(json['privacyLevel'] as String?),
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'privacyLevel': privacyLevel.value,
      'language': language,
    };
  }

  HealthPreferences copyWith({
    bool? notifications,
    PrivacyLevel? privacyLevel,
    String? language,
  }) {
    return HealthPreferences(
      notifications: notifications ?? this.notifications,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      language: language ?? this.language,
    );
  }
}

// Emergency Contact model
class EmergencyContact {
  final String? name;
  final String? phone;
  final String? relationship;

  const EmergencyContact({
    this.name,
    this.phone,
    this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EmergencyContact();
    
    return EmergencyContact(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      relationship: json['relationship'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (relationship != null) 'relationship': relationship,
    };
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? relationship,
  }) {
    return EmergencyContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
    );
  }
}

// Main User model
class User {
  final String? id;
  final String? username;
  final String? name;
  final String? email;
  final String? password; // Usually not included in responses
  final UserStatus status;
  final UserRole role;
  final String? phone;
  final DateTime? lastLogin;
  final String? avatar;
  final String? bio;
  final String? referredBy;
  
  // CodeHer specific fields
  final int? age;
  final String? language;
  final String? location;
  final RiskLevel riskLevel;
  final HealthPreferences healthPreferences;
  final EmergencyContact emergencyContact;
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    this.username,
    this.name,
    this.email,
    this.password,
    this.status = UserStatus.active,
    this.role = UserRole.user,
    this.phone,
    this.lastLogin,
    this.avatar,
    this.bio,
    this.referredBy,
    this.age,
    this.language,
    this.riskLevel = RiskLevel.low,
    this.healthPreferences = const HealthPreferences(),
    this.emergencyContact = const EmergencyContact(),
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const User();
    
    return User(
      id: json['_id'] as String? ?? json['id'] as String?,
      username: json['username'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      status: UserStatus.fromString(json['status'] as String?),
      role: UserRole.fromString(json['role'] as String?),
      phone: json['phone'] as String?,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin'].toString()) 
          : null,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      referredBy: json['referredBy'] as String?,
      age: json['age'] != null 
          ? (json['age'] is int ? json['age'] : int.tryParse(json['age'].toString()))
          : null,
      language: json['language'] as String?,
      location: json['location'] as String?,
      riskLevel: RiskLevel.fromString(json['riskLevel'] as String?),
      healthPreferences: HealthPreferences.fromJson(json['healthPreferences'] as Map<String, dynamic>?),
      emergencyContact: EmergencyContact.fromJson(json['emergencyContact'] as Map<String, dynamic>?),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      'status': status.value,
      'role': role.value,
      if (phone != null) 'phone': phone,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      if (avatar != null) 'avatar': avatar,
      if (bio != null) 'bio': bio,
      if (referredBy != null) 'referredBy': referredBy,
      if (age != null) 'age': age,
      if (language != null) 'language': language,
      if (location != null) 'location': location,
      'riskLevel': riskLevel.value,
      'healthPreferences': healthPreferences.toJson(),
      'emergencyContact': emergencyContact.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? password,
    UserStatus? status,
    UserRole? role,
    String? phone,
    DateTime? lastLogin,
    String? avatar,
    String? bio,
    String? referredBy,
    int? age,
    String? language,
    String? location,
    RiskLevel? riskLevel,
    HealthPreferences? healthPreferences,
    EmergencyContact? emergencyContact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      lastLogin: lastLogin ?? this.lastLogin,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      referredBy: referredBy ?? this.referredBy,
      age: age ?? this.age,
      language: language ?? this.language,
      location: location ?? this.location,
      riskLevel: riskLevel ?? this.riskLevel,
      healthPreferences: healthPreferences ?? this.healthPreferences,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  // Convenience getters
  bool get isActive => status == UserStatus.active;
  bool get isAdmin => role == UserRole.admin;
  bool get isNurse => role == UserRole.nurse;
  bool get isPeerSister => role == UserRole.peerSister;
  bool get hasEmergencyContact => emergencyContact.name != null && emergencyContact.phone != null;
  
  // Display name getter with fallback
  String get displayName => name ?? username ?? email ?? 'Unknown User';
  
  // Age range getter
  String get ageRange {
    if (age == null) return 'Unknown';
    if (age! < 18) return 'Under 18';
    if (age! < 25) return '18-24';
    if (age! < 35) return '25-34';
    if (age! < 45) return '35-44';
    if (age! < 55) return '45-54';
    return '55+';
  }
} 