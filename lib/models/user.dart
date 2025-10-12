class UserModel {
  final String name;
  final String username;
  final String email;
  double mainBalance;
  final String accNumber;
  final String accName;
  final String bankName;
  String? token;
  int hasPin;

  UserModel({
    required this.name,
    required this.username,
    required this.email,
    required this.mainBalance,
    required this.accNumber,
    required this.accName,
    required this.bankName,
    this.token,
    required this.hasPin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
  //  final balanceValue = json['mainBalance'] ?? json['wallet_balance'] ?? 0.0;
  //   final parsedBalance = (balanceValue is String)
  //       ? double.tryParse(balanceValue) ?? 0.0
  //       : (balanceValue is num ? balanceValue.toDouble() : 0.0);

    return UserModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      mainBalance: double.tryParse(json['wallet_balance'].toString()) ?? 0.0,
      accNumber: json['accNumber'] ?? '',
      accName: json['accName'] ?? '',
      bankName: json['bankName'] ?? '',
      token: json['token'],
      hasPin: json['has_set_pin'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'mainBalance': mainBalance,
      'accNumber': accNumber,
      'accName': accName,
      'bankName': bankName,
      'token': token,
      'has_set_pin': hasPin,
    };
  }
}
