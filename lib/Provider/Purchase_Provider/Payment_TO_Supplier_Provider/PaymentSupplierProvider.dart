import 'package:flutter/material.dart';

import '../../../model/Purchase_Model/paymentToSupplierModel/PaymentSupplierModel.dart';
import 'PaymentSupplierServices.dart';

class PaymentToSupplierProvider extends ChangeNotifier {

  List<PaymentToSupplierModel> paymentList = [];

  bool isLoading = false;

  Future<void> loadPayments() async {

    isLoading = true;
    notifyListeners();

    try {

      paymentList = await PaymentToSupplierApi.fetchPayments();

    } catch (e) {

      debugPrint("Error loading payments: $e");

    }

    isLoading = false;
    notifyListeners();
  }

  /// ✅ Delete payment
  Future<void> deletePayment(int id) async {

    bool success = await PaymentToSupplierApi.deletePayment(id);

    if (success) {

      paymentList.removeWhere((item) => item.id == id);

      notifyListeners();

    }
  }
}