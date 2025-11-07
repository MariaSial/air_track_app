// lib/models/auth_models.dart

/// This file contains all authentication-related models:
/// - UserModel
/// - SignUpRequest
/// - SignInRequest
/// - ForgotPasswordRequest

// ---------------------------
// 🧑‍💼 User Model
// ---------------------------
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? token; // Optional (e.g. JWT token from API)

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      city: json['city'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "city": city,
      "token": token,
    };
  }
}

// ---------------------------
// 📝 Sign Up Request
// ---------------------------
class SignUpRequest {
  final String name;
  final String email;
  final String password;
  final String cnic;
  final String phone;
  final String city;

  SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.cnic,
    required this.phone,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "cnic": cnic,
      "phone": phone,
      "city": city,
    };
  }
}

// ---------------------------
// 🔐 Sign In Request
// ---------------------------
class SignInRequest {
  final String email;
  final String password;

  SignInRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }
}

// ---------------------------
// ✉️ Forgot Password Request
// ---------------------------
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {"email": email};
}
