// lib/core/constants/api_endpoint.dart

/// Définition de tous les endpoints de l'API GESTORE
/// Basé sur l'API Django backend
class ApiEndpoints {
  // Base path
  static const String basePath = '/api';

  // ==================== AUTHENTICATION ====================

  /// Authentication endpoints
  static const String authLogin = '/auth/login/';
  static const String authLogout = '/auth/logout/';
  static const String authRefresh = '/auth/token/refresh/';
  static const String authMe = '/auth/me/';

  /// Users management
  static const String users = '/auth/users/';
  static String userDetail(String id) => '/auth/users/$id/';
  static String userActiveSessions(String id) => '/auth/users/$id/active-sessions/';
  static String userAuditLog(String id) => '/auth/users/$id/audit-log/';

  /// Roles management
  static const String roles = '/auth/roles/';
  static String roleDetail(String id) => '/auth/roles/$id/';

  /// Profiles
  static const String profiles = '/auth/profiles/';
  static String profileDetail(String id) => '/auth/profiles/$id/';

  // ==================== INVENTORY ====================

  /// Categories
  static const String categories = '/inventory/categories/';
  static String categoryDetail(String id) => '/inventory/categories/$id/';

  /// Units of Measure
  static const String units = '/inventory/units/';
  static String unitDetail(String id) => '/inventory/units/$id/';
  static const String unitConversions = '/inventory/unit-conversions/';

  /// Brands
  static const String brands = '/inventory/brands/';
  static String brandDetail(String id) => '/inventory/brands/$id/';

  /// Articles
  static const String articles = '/inventory/articles/';
  static String articleDetail(String id) => '/inventory/articles/$id/';
  static String articleVariants(String id) => '/inventory/articles/$id/variants/';
  static String articleStockLevels(String id) => '/inventory/articles/$id/stock-levels/';
  static String articleMovements(String id) => '/inventory/articles/$id/movements/';
  static const String articlesLowStock = '/inventory/articles/low-stock/';
  static const String articlesExpiringSoon = '/inventory/articles/expiring-soon/';
  static const String articlesBulkUpdate = '/inventory/articles/bulk-update/';

  /// Article Variants
  static const String articleVariantsList = '/inventory/article-variants/';
  static String articleVariantDetail(String id) => '/inventory/article-variants/$id/';

  // ==================== LOCATIONS (WAREHOUSES) ====================

  /// Emplacements (Locations dans le backend, mais appelés "warehouses" dans les URLs)
  static const String locations = '/inventory/locations/';
  static String locationDetail(String id) => '/inventory/locations/$id/';
  static String locationStocks(String id) => '/inventory/locations/$id/stocks/';

  /// Warehouses
  static const String warehouses = '/inventory/warehouses/';
  static String warehouseDetail(String id) => '/inventory/warehouses/$id/';
  static String warehouseStock(String id) => '/inventory/warehouses/$id/stock/';

  // ==================== STOCKS ====================

  /// Stocks
  static const String stocks = '/inventory/stocks/';
  static String stockDetail(String id) => '/inventory/stocks/$id/';

  /// Opérations sur les stocks
  static const String stockAdjustment = '/inventory/stocks/adjustment/';
  static const String stockTransfer = '/inventory/stocks/transfer/';
  static const String stockValuation = '/inventory/stocks/valuation/';
  static const String stockLowStock = '/inventory/stocks/low-stock/';
  static const String stockByWarehouse = '/inventory/stocks/by-warehouse/';

  // ==================== STOCK ALERTS ====================

  /// Stock Alerts
  static const String stockAlerts = '/inventory/alerts/';
  static String stockAlertDetail(String id) => '/inventory/alerts/$id/';
  static String stockAlertAcknowledge(String id) => '/inventory/alerts/$id/acknowledge/';
  static const String stockAlertsBulkAcknowledge = '/inventory/alerts/bulk_acknowledge/';
  static const String stockAlertsDashboard = '/inventory/alerts/dashboard/';

  /// Stock Movements
  static const String stockMovements = '/inventory/stock-movements/';
  static String stockMovementDetail(String id) => '/inventory/stock-movements/$id/';

  /// Stock Adjustments
  static const String stockAdjustments = '/inventory/stock-adjustments/';
  static String stockAdjustmentDetail(String id) => '/inventory/stock-adjustments/$id/';

  /// Stock Transfers
  static const String stockTransfers = '/inventory/stock-transfers/';
  static String stockTransferDetail(String id) => '/inventory/stock-transfers/$id/';
  static String stockTransferConfirm(String id) => '/inventory/stock-transfers/$id/confirm/';
  static String stockTransferCancel(String id) => '/inventory/stock-transfers/$id/cancel/';

  // ==================== SALES ====================

  /// Customers
  static const String customers = '/sales/customers/';
  static String customerDetail(String id) => '/sales/customers/$id/';
  static String customerSalesHistory(String id) => '/sales/customers/$id/sales-history/';
  static String customerLoyaltyPoints(String id) => '/sales/customers/$id/loyalty-points/';

  /// Sales
  static const String sales = '/sales/sales/';
  static String saleDetail(String id) => '/sales/sales/$id/';
  static String saleVoid(String id) => '/sales/sales/$id/void/';
  static String saleReturn(String id) => '/sales/sales/$id/return/';
  static const String salesToday = '/sales/sales/today/';
  static const String salesByPeriod = '/sales/sales/by-period/';

  /// Sale Items
  static const String saleItems = '/sales/sale-items/';
  static String saleItemDetail(String id) => '/sales/sale-items/$id/';

  static const String paymentMethods = '/sales/payment-methods/';
  static String paymentMethodDetail(String id) => '/sales/payment-methods/$id/';

  /// Payments (Paiements d'une vente)
  static const String payments = '/sales/payments/';
  static String paymentDetail(String id) => '/sales/payments/$id/';

  /// Discounts
  static const String discounts = '/sales/discounts/';
  static String discountDetail(String id) => '/sales/discounts/$id/';
  static const String discountsActive = '/sales/discounts/active/';

  /// POS (Point of Sale)
  static const String posCheckout = '/sales/pos/checkout/';
  static const String posCalculate = '/sales/pos/calculate/';
  static const String posOpenSession = '/sales/pos/open-session/';
  static const String posCloseSession = '/sales/pos/close-session/';

  // ==================== SUPPLIERS (À venir) ====================

  static const String suppliers = '/suppliers/suppliers/';
  static const String purchaseOrders = '/suppliers/purchase-orders/';

  // ==================== REPORTING (À venir) ====================

  static const String reports = '/reporting/reports/';
  static const String dashboards = '/reporting/dashboards/';

  // ==================== SYNC (À venir) ====================

  static const String syncStatus = '/sync/status/';
  static const String syncPush = '/sync/push/';
  static const String syncPull = '/sync/pull/';

  // ==================== SYSTEM ====================

  /// Health check
  static const String health = '/health/';

  /// API Documentation
  static const String apiDocs = '/docs/';
  static const String apiSchema = '/schema/';
}