import '../models/user_model.dart';
import '../sample_data/sample_products.dart';

class AuthRepository {
  UserModel? _currentUser = SampleData.currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<UserModel> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = SampleData.currentUser.copyWith(email: email);
    return _currentUser!;
  }

  Future<UserModel> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = SampleData.currentUser.copyWith(
      name: name,
      email: email,
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser == null) throw Exception('No user logged in');
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      defaultAddress: address,
    );
    return _currentUser!;
  }
}
