class ReportSummary {
  ReportSummary({
    required this.totalSales,
    required this.totalExpenses,
    required this.estimatedProfit,
    required this.topProducts,
    required this.lowStockProducts,
    required this.totalProduction,
    required this.salesByCategory,
  });

  final double totalSales;
  final double totalExpenses;
  final double estimatedProfit;
  final List<String> topProducts;
  final List<String> lowStockProducts;
  final double totalProduction;
  final List<String> salesByCategory;
}
