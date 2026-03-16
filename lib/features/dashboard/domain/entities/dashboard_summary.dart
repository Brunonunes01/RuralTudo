class DashboardSummary {
  DashboardSummary({
    required this.soldToday,
    required this.soldMonth,
    required this.expensesMonth,
    required this.estimatedProfit,
    required this.lowStockCount,
    required this.pendingOrders,
    required this.totalProducts,
  });

  final double soldToday;
  final double soldMonth;
  final double expensesMonth;
  final double estimatedProfit;
  final int lowStockCount;
  final int pendingOrders;
  final int totalProducts;
}
