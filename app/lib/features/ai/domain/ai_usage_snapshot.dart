class AiUsageSnapshot {
  const AiUsageSnapshot({
    required this.freeUsedToday,
    required this.freeDailyCap,
    required this.premiumUsedMonth,
    required this.premiumMonthlyCap,
  });

  final int freeUsedToday;
  final int freeDailyCap;
  final int premiumUsedMonth;
  final int premiumMonthlyCap;
}
