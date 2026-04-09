class LeaveTypeItem {
  final int leaveTypeId;
  final String name;

  const LeaveTypeItem({required this.leaveTypeId, required this.name});

  factory LeaveTypeItem.fromJson(Map<String, dynamic> json) {
    return LeaveTypeItem(
      leaveTypeId: json['leaveTypeId'] as int,
      name: (json['name'] ?? '').toString(),
    );
  }
}
