enum SubscriptionTier {
  free,
  premium,
}

extension SubscriptionTierX on SubscriptionTier {
  String get label {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  String get storageValue {
    switch (this) {
      case SubscriptionTier.free:
        return 'free';
      case SubscriptionTier.premium:
        return 'premium';
    }
  }

  static SubscriptionTier fromStorage(String? value) {
    switch (value) {
      case 'premium':
        return SubscriptionTier.premium;
      case 'free':
      default:
        return SubscriptionTier.free;
    }
  }
}
