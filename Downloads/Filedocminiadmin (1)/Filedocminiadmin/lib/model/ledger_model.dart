class LedgerModel {
  final int approvedAmount;
  final int availableAmount;
  final int paidAmount;
  final int pendingAmount;
  final int totalEarnings;
  final String userId;

  LedgerModel({
    required this.approvedAmount,
    required this.availableAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.totalEarnings,
    required this.userId,
  });

  factory LedgerModel.fromMap(Map<String, dynamic> data) {
    return LedgerModel(
      approvedAmount: data['approvedAmount'] ?? 0,
      availableAmount: data['availableAmount'] ?? 0,
      paidAmount: data['paidAmount'] ?? 0,
      pendingAmount: data['pendingAmount'] ?? 0,
      totalEarnings: data['totalEarnings'] ?? 0,
      userId: data['userId'] ?? "",
    );
  }
}
