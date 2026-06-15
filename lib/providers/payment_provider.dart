import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepository = PaymentRepository();

  List<dynamic> _paymentEvents = [];
  Map<String, dynamic>? _calculation;
  PaymentModel? _payment;

  bool _isLoading = false;
  bool _isPaid = false;
  String? _errorMessage;

  List<dynamic> get paymentEvents => _paymentEvents;
  Map<String, dynamic>? get calculation => _calculation;
  PaymentModel? get payment => _payment;

  bool get isLoading => _isLoading;
  bool get isPaid => _isPaid;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPaymentEvents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _paymentEvents = await _paymentRepository.getPaymentEvents();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<bool> calculatePayment({required int eventId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _calculation = await _paymentRepository.calculatePayment(
        eventId: eventId,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<bool> confirmPayment({
    required int eventId,
    required int invitationId,
    required String paymentMethod,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _payment = await _paymentRepository.confirmPayment(
        eventId: eventId,
        invitationId: invitationId,
        paymentMethod: paymentMethod,
      );

      _isPaid = true;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();

      return false;
    }
  }

  Future<void> checkPaymentStatus({required int eventId}) async {
    try {
      _errorMessage = null;

      final data = await _paymentRepository.getPaymentStatus(eventId: eventId);

      _isPaid = data['isPaid'] == true;

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void clearCalculation() {
    _calculation = null;
    notifyListeners();
  }
}
