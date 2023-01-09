import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(
    this.address, [
    this.email,
    this.name,
    this.profileImage,
  ]);

  final String address;
  final String? email;
  final String? name;
  final String? profileImage;

  @override
  List<Object> get props => [address];

  static const empty = User('');

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'email': email,
      'name': name,
      'profileImage': profileImage,
    };
  }

  User? fromJson(Map<String, dynamic> json) {
    final address = json['address']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final profileImage = json['profileImage']?.toString() ?? '';
    if (address.isNotEmpty) {
      return User(address, email, name, profileImage);
    }
    return null;
  }
}
