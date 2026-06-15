import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _paymentService = PaymentService();

  Future<List<dynamic>> getPaymentEvents() async {
    return await _paymentService.getPaymentEvents();
  }

  Future<Map<String, dynamic>> calculatePayment({required int eventId}) async {
    return await _paymentService.calculatePayment(eventId: eventId);
  }

  Future<PaymentModel> confirmPayment({
    required int eventId,
    required int invitationId,
    required String paymentMethod,
  }) async {
    final data = await _paymentService.confirmPayment(
      eventId: eventId,
      invitationId: invitationId,
      paymentMethod: paymentMethod,
    );

    return PaymentModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getPaymentStatus({required int eventId}) async {
    return await _paymentService.getPaymentStatus(eventId: eventId);
  }
}
