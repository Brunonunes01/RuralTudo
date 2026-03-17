import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/categories/data/datasources/category_local_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/delete_category_usecase.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/domain/usecases/upsert_category_usecase.dart';
import '../../features/categories/presentation/controllers/category_controller.dart';
import '../../features/customers/data/datasources/customer_local_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/entities/customer.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/upsert_customer_usecase.dart';
import '../../features/customers/presentation/controllers/customer_controller.dart';
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/entities/dashboard_summary.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/delete_expense_usecase.dart';
import '../../features/expenses/domain/usecases/get_expenses_usecase.dart';
import '../../features/expenses/domain/usecases/upsert_expense_usecase.dart';
import '../../features/expenses/presentation/controllers/expense_controller.dart';
import '../../features/farm/data/datasources/farm_local_datasource.dart';
import '../../features/farm/domain/entities/farm_area.dart';
import '../../features/farm/domain/entities/farm_expense.dart';
import '../../features/farm/domain/entities/harvest.dart';
import '../../features/farm/domain/entities/harvest_sale.dart';
import '../../features/farm/domain/entities/modules_config.dart';
import '../../features/farm/domain/entities/planting.dart';
import '../../features/farm/presentation/controllers/areas_controller.dart';
import '../../features/farm/presentation/controllers/farm_expenses_controller.dart';
import '../../features/farm/presentation/controllers/farm_sales_controller.dart';
import '../../features/farm/presentation/controllers/harvests_controller.dart';
import '../../features/farm/presentation/controllers/modules_settings_controller.dart';
import '../../features/farm/presentation/controllers/plantings_controller.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/delete_product_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/upsert_product_usecase.dart';
import '../../features/products/presentation/controllers/product_controller.dart';
import '../../features/production/data/datasources/production_local_datasource.dart';
import '../../features/production/data/repositories/production_repository_impl.dart';
import '../../features/production/domain/entities/production_record.dart';
import '../../features/production/domain/repositories/production_repository.dart';
import '../../features/production/domain/usecases/get_production_records_usecase.dart';
import '../../features/production/domain/usecases/register_production_usecase.dart';
import '../../features/production/presentation/controllers/production_controller.dart';
import '../../features/reports/data/datasources/reports_local_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/entities/report_summary.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_report_summary_usecase.dart';
import '../../features/reports/presentation/controllers/reports_controller.dart';
import '../../features/sales/data/datasources/sales_local_datasource.dart';
import '../../features/sales/data/repositories/sales_repository_impl.dart';
import '../../features/sales/domain/entities/sale.dart';
import '../../features/sales/domain/repositories/sales_repository.dart';
import '../../features/sales/domain/usecases/cancel_sale_usecase.dart';
import '../../features/sales/domain/usecases/get_sales_usecase.dart';
import '../../features/sales/domain/usecases/register_sale_usecase.dart';
import '../../features/sales/presentation/controllers/sales_controller.dart';
import '../../features/stock/data/datasources/stock_local_datasource.dart';
import '../../features/stock/data/repositories/stock_repository_impl.dart';
import '../../features/stock/domain/entities/stock_movement.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/stock/domain/usecases/get_stock_movements_usecase.dart';
import '../../features/stock/presentation/controllers/stock_controller.dart';
import '../database/database_service.dart';
import '../services/inventory_service.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);
final inventoryServiceProvider = Provider<InventoryService>(
  (ref) => InventoryService(),
);

final categoryDatasourceProvider = Provider<CategoryLocalDatasource>(
  (ref) => CategoryLocalDatasource(ref.read(databaseServiceProvider)),
);
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.read(categoryDatasourceProvider)),
);
final categoryControllerProvider =
    StateNotifierProvider<CategoryController, AsyncValue<List<Category>>>(
      (ref) => CategoryController(
        GetCategoriesUseCase(ref.read(categoryRepositoryProvider)),
        UpsertCategoryUseCase(ref.read(categoryRepositoryProvider)),
        DeleteCategoryUseCase(ref.read(categoryRepositoryProvider)),
      ),
    );

final productDatasourceProvider = Provider<ProductLocalDatasource>(
  (ref) => ProductLocalDatasource(ref.read(databaseServiceProvider)),
);
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ref.read(productDatasourceProvider)),
);
final productControllerProvider =
    StateNotifierProvider<ProductController, AsyncValue<List<Product>>>(
      (ref) => ProductController(
        GetProductsUseCase(ref.read(productRepositoryProvider)),
        UpsertProductUseCase(ref.read(productRepositoryProvider)),
        DeleteProductUseCase(ref.read(productRepositoryProvider)),
      ),
    );
final lowStockProductsProvider = FutureProvider<List<Product>>(
  (ref) => ref.read(productRepositoryProvider).getLowStock(),
);

final customerDatasourceProvider = Provider<CustomerLocalDatasource>(
  (ref) => CustomerLocalDatasource(ref.read(databaseServiceProvider)),
);
final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepositoryImpl(ref.read(customerDatasourceProvider)),
);
final customerControllerProvider =
    StateNotifierProvider<CustomerController, AsyncValue<List<Customer>>>(
      (ref) => CustomerController(
        GetCustomersUseCase(ref.read(customerRepositoryProvider)),
        UpsertCustomerUseCase(ref.read(customerRepositoryProvider)),
        DeleteCustomerUseCase(ref.read(customerRepositoryProvider)),
      ),
    );

final expenseDatasourceProvider = Provider<ExpenseLocalDatasource>(
  (ref) => ExpenseLocalDatasource(ref.read(databaseServiceProvider)),
);
final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepositoryImpl(ref.read(expenseDatasourceProvider)),
);
final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, AsyncValue<List<Expense>>>(
      (ref) => ExpenseController(
        GetExpensesUseCase(ref.read(expenseRepositoryProvider)),
        UpsertExpenseUseCase(ref.read(expenseRepositoryProvider)),
        DeleteExpenseUseCase(ref.read(expenseRepositoryProvider)),
      ),
    );

final stockDatasourceProvider = Provider<StockLocalDatasource>(
  (ref) => StockLocalDatasource(ref.read(databaseServiceProvider)),
);
final stockRepositoryProvider = Provider<StockRepository>(
  (ref) => StockRepositoryImpl(ref.read(stockDatasourceProvider)),
);
final stockControllerProvider =
    StateNotifierProvider<StockController, AsyncValue<List<StockMovement>>>(
      (ref) => StockController(
        GetStockMovementsUseCase(ref.read(stockRepositoryProvider)),
      ),
    );

final productionDatasourceProvider = Provider<ProductionLocalDatasource>(
  (ref) => ProductionLocalDatasource(
    ref.read(databaseServiceProvider),
    ref.read(inventoryServiceProvider),
  ),
);
final productionRepositoryProvider = Provider<ProductionRepository>(
  (ref) => ProductionRepositoryImpl(ref.read(productionDatasourceProvider)),
);
final productionControllerProvider =
    StateNotifierProvider<
      ProductionController,
      AsyncValue<List<ProductionRecord>>
    >(
      (ref) => ProductionController(
        GetProductionRecordsUseCase(ref.read(productionRepositoryProvider)),
        RegisterProductionUseCase(ref.read(productionRepositoryProvider)),
      ),
    );

final salesDatasourceProvider = Provider<SalesLocalDatasource>(
  (ref) => SalesLocalDatasource(
    ref.read(databaseServiceProvider),
    ref.read(inventoryServiceProvider),
  ),
);
final salesRepositoryProvider = Provider<SalesRepository>(
  (ref) => SalesRepositoryImpl(ref.read(salesDatasourceProvider)),
);
final salesControllerProvider =
    StateNotifierProvider<SalesController, AsyncValue<List<Sale>>>(
      (ref) => SalesController(
        GetSalesUseCase(ref.read(salesRepositoryProvider)),
        RegisterSaleUseCase(ref.read(salesRepositoryProvider)),
        CancelSaleUseCase(ref.read(salesRepositoryProvider)),
      ),
    );

final dashboardDatasourceProvider = Provider<DashboardLocalDatasource>(
  (ref) => DashboardLocalDatasource(ref.read(databaseServiceProvider)),
);
final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(ref.read(dashboardDatasourceProvider)),
);
final dashboardSummaryProvider =
    StateNotifierProvider<DashboardController, AsyncValue<DashboardSummary>>(
      (ref) => DashboardController(
        GetDashboardSummaryUseCase(ref.read(dashboardRepositoryProvider)),
      ),
    );

final reportsDatasourceProvider = Provider<ReportsLocalDatasource>(
  (ref) => ReportsLocalDatasource(ref.read(databaseServiceProvider)),
);
final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => ReportsRepositoryImpl(ref.read(reportsDatasourceProvider)),
);
final reportsControllerProvider =
    StateNotifierProvider<ReportsController, AsyncValue<ReportSummary>>(
      (ref) => ReportsController(
        GetReportSummaryUseCase(ref.read(reportsRepositoryProvider)),
      ),
    );

final farmDatasourceProvider = Provider<FarmLocalDatasource>(
  (ref) => FarmLocalDatasource(ref.read(databaseServiceProvider)),
);

final areasControllerProvider =
    StateNotifierProvider<AreasController, AsyncValue<List<FarmArea>>>(
      (ref) => AreasController(ref.read(farmDatasourceProvider)),
    );

final plantingsControllerProvider =
    StateNotifierProvider<PlantingsController, AsyncValue<List<Planting>>>(
      (ref) => PlantingsController(ref.read(farmDatasourceProvider)),
    );

final harvestsControllerProvider =
    StateNotifierProvider<HarvestsController, AsyncValue<List<Harvest>>>(
      (ref) => HarvestsController(ref.read(farmDatasourceProvider)),
    );

final farmSalesControllerProvider =
    StateNotifierProvider<FarmSalesController, AsyncValue<List<HarvestSale>>>(
      (ref) => FarmSalesController(ref.read(farmDatasourceProvider)),
    );

final farmExpensesControllerProvider =
    StateNotifierProvider<
      FarmExpensesController,
      AsyncValue<List<FarmExpense>>
    >((ref) => FarmExpensesController(ref.read(farmDatasourceProvider)));

final modulesSettingsProvider =
    StateNotifierProvider<ModulesSettingsController, AsyncValue<ModulesConfig>>(
      (ref) => ModulesSettingsController(ref.read(farmDatasourceProvider)),
    );
