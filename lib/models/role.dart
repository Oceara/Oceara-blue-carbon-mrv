enum UserRole {
  landOwner,
  buyer,
  admin,
}

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.landOwner:
        return 'Land Owner';
      case UserRole.buyer:
        return 'Carbon Credit Buyer';
      case UserRole.admin:
        return 'Admin';
    }
  }
}


