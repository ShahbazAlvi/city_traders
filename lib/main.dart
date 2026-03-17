
import 'package:demo_distribution/Provider/setup/tax_types_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Provider/AmountReceivableDetailsProvider/AmountReceivableDetailsProvider.dart';
import 'Provider/AuthProvider/LoginProvider.dart';
import 'Provider/BankProvider/BankListProvider.dart';
import 'Provider/BankProvider/PaymentVoucherProvider.dart';
import 'Provider/BankProvider/ReceiptVoucherProvider.dart';
import 'Provider/CreditAgingReportProvider/AgingProvider.dart';
import 'Provider/CustomerLedgerProvider/LedgerProvider.dart';
import 'Provider/CustomerProvider/CustomerProvider.dart';
import 'Provider/DailySaleReport/DailySaleReportProvider.dart';
import 'Provider/DashBoardProvider.dart';
import 'Provider/OrderTakingProvider/OrderTakingProvider.dart';
import 'Provider/ProductProvider/ItemCategoriesProvider.dart';
import 'Provider/ProductProvider/ItemListsProvider.dart';
import 'Provider/ProductProvider/ItemTypeProvider.dart';
import 'Provider/ProductProvider/ItemUnitProvider.dart';
import 'Provider/ProductProvider/ProducProvider.dart';
import 'Provider/ProductProvider/manufactures_provider.dart';
import 'Provider/ProductProvider/sub_category.dart';
import 'Provider/Purchase_Order_Provider/Purchase_order_provider.dart';

import 'Provider/Purchase_Provider/GRNProvider/GRN_Provider.dart';
import 'Provider/Purchase_Provider/PayaAmountProvider/PayaAmountProvider.dart';
import 'Provider/Purchase_Provider/Payment_TO_Supplier_Provider/PaymentSupplierProvider.dart';
import 'Provider/Purchase_Provider/StockPositionProvider/StockPositionProvider.dart';
import 'Provider/Purchase_Provider/SupplierLedgerProvider/SupplierLedgerProvider.dart';

import 'Provider/RecoveryProvider/RecoveryProvider.dart';
import 'Provider/SaleInvoiceProvider/SaleInvoicesProvider.dart';
import 'Provider/SaleManProvider/SaleManProvider.dart';
import 'Provider/SalemanRecoveryReport/salemanReport.dart';
import 'Provider/SalessProvider/SalessProvider.dart';
import 'Provider/SupplierProvider/supplierProvider.dart';
import 'Provider/customer_Payment/customer_payment_provider.dart';
import 'Provider/setup/location_provider.dart';
import 'Provider/stock_provider/stock_position_provider.dart';
import 'Screen/splashview/splashLogo.dart';


void main()async {


  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize SharedPreferences safely
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  runApp(MyApp(token: token));

}
class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, this.token});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderTakingProvider()),
        ChangeNotifierProvider(create: (_) => SaleManProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ItemDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SaleInvoicesProvider()),
        ChangeNotifierProvider(create: (_) => RecoveryProvider()),
        ChangeNotifierProvider(create: (_) => ReceivableProvider()),
        ChangeNotifierProvider(create: (_) => CustomerLedgerProvider()),
        ChangeNotifierProvider(create: (_) => CreditAgingProvider()),
        ChangeNotifierProvider(create: (_) => GRNProvider()),
        ChangeNotifierProvider(create: (_) => PaymentToSupplierProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => SupplierLedgerProvider()),
        ChangeNotifierProvider(create: (_)=>PayableAmountProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ItemTypeProvider()),
        ChangeNotifierProvider(create: (_) => ItemUnitProvider()),
        ChangeNotifierProvider(create: (_) => BankProvider()),
        ChangeNotifierProvider(create: (_) => DailySaleReportProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptVoucherProvider()),
        ChangeNotifierProvider(create: (_) => PaymentVoucherProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
    ChangeNotifierProvider(create: (_) => PurchaseOrderProvider()),
        ChangeNotifierProvider(create: (_) => SubCategory()),
        ChangeNotifierProvider(create: (_) => ManufacturesProvider()),
        ChangeNotifierProvider(create: (_) => CustomerPaymentProvider()),
        ChangeNotifierProvider(create: (_) => StockPositionProvider(),),
        ChangeNotifierProvider(
          create: (_) => TaxTypesProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(create: (_) => SaleManRecoveryProvider()),



      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Distribution System',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B86E5)),
        ),
        // ✅ If token found → go to dashboard, otherwise splash
        home: token != null ? const SplashLogo() : const SplashLogo(),
      ),
    );
  }
}


