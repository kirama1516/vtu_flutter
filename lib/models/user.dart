class UserModel {
  final String name;
  final String username;
  final String email;
  double walletBalance;
  final String accNumber;
  final String accName;
  final String bankName;
  String? token;

  UserModel({
    required this.name,
    required this.username,
    required this.email,
    required this.walletBalance,
    required this.accNumber,
    required this.accName,
    required this.bankName,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      walletBalance: double.tryParse(json['wallet_balance'].toString()) ?? 0.0,
      accNumber: json['accNumber'] ?? '',
      accName: json['accName'] ?? '',
      bankName: json['bankName'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'wallet_balance': walletBalance,
      'accNumber': accNumber,
      'accName': accName,
      'bankName': bankName,
      'token': token
    };
  }
}
