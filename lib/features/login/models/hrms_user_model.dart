class HrmsUserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String employeeCode;
  final bool isLoggedIn;
  final int? attendanceId;

  HrmsUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.employeeCode,
    required this.isLoggedIn,
    this.attendanceId,
  });

  factory HrmsUserModel.fromJson(Map<String, dynamic> json) {
    return HrmsUserModel(
      id: json["id"],
      email: json["email"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      employeeCode: json["employeeCode"],
      isLoggedIn: json["isLoggedIn"] ?? false,
      attendanceId: json["attendanceId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "employeeCode": employeeCode,
        "isLoggedIn": isLoggedIn,
        "attendanceId": attendanceId,
      };
}
