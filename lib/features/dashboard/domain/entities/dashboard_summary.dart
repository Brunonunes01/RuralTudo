class DashboardSummary {
  DashboardSummary({
    required this.plantingsInProgress,
    required this.plantingsReadyToHarvest,
    required this.recentHarvests,
    required this.recentSales,
    required this.recentExpenses,
    required this.availableFromRecentHarvests,
    required this.estimatedProfitPeriod,
  });

  final int plantingsInProgress;
  final int plantingsReadyToHarvest;
  final int recentHarvests;
  final int recentSales;
  final int recentExpenses;
  final double availableFromRecentHarvests;
  final double estimatedProfitPeriod;
}
