class PaymentModel {
  final int id;
  final int userId;
  final int eventId;
  final int? invitationId;
  final int guestCount;
  final int unitPrice;
  final int totalAmount;
  final String? paymentMethod;
  final String paymentStatus;
  final String? transactionReference;
  final String? paidAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.eventId,
    this.invitationId,
    required this.guestCount,
    required this.unitPrice,
    required this.totalAmount,
    this.paymentMethod,
    required this.paymentStatus,
    this.transactionReference,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      invitationId: json['invitation_id'],
      guestCount: json['guest_count'],
      unitPrice: json['unit_price'],
      totalAmount: json['total_amount'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'] ?? 'pending',
      transactionReference: json['transaction_reference'],
      paidAt: json['paid_at'],
    );
  }
}
