class BehaviorConstants {
  // Romantic Swipe Constraints
  static const int maxActiveRomanticMatches = 5;
  static const int romanticExpiryHours = 48;

  // Feed & Exposure Constraints
  static const double interactionScalingThreshold =
      0.5; // (e.g. 50% reply rate to boost capabilities)
  static const int intentSwitchCooldownDays = 7;

  // Weighting algorithm multipliers
  static const double targetIntentWeightFactor = 2.0;
  static const double lowExposureBoostFactor = 1.5;
}
