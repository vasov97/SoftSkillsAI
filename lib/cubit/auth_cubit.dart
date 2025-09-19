// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:softai/model/user.dart';
// import 'package:softai/service/firebase_service.dart';

// part 'auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   final FirebaseService _firebaseService;

//   AuthCubit(this._firebaseService) : super(AuthInitial());

//   Future<void> login(String email, String password) async {
//     emit(AuthLoading());
//     try {
//       final user =
//           await _firebaseService.login(email: email, password: password);
//       if (user != null) {
//         emit(AuthAuthenticated(user));
//       } else {
//         emit(const AuthError('Login failed'));
//       }
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

//   Future<void> signUp(String name, String email, String password,
//       String confirmPassword) async {
//     // Validation checks
//     if (name.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty) {
//       emit(const AuthError("Please fill all fields"));
//       return;
//     }

//     if (password.length < 6) {
//       emit(const AuthError("Password must be at least 6 characters long"));
//       return;
//     }

//     if (password != confirmPassword) {
//       emit(const AuthError("Passwords do not match"));
//       return;
//     }

//     // If all checks pass, proceed
//     emit(AuthLoading());
//     try {
//       final user = await _firebaseService.signUp(
//         fullName: name,
//         email: email,
//         password: password,
//       );
//       if (user != null) {
//         emit(AuthAuthenticated(user));
//       } else {
//         emit(const AuthError("Sign-up failed, please try again"));
//       }
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

//   Future<void> forgotPassword(String email) async {
//     emit(AuthLoading());
//     try {
//       await _firebaseService.forgotPassword(email);
//       emit(const AuthError(
//           'Password reset link sent!')); // We reuse AuthError for messages
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

//   // Future<void> signOut() async {
//   //   await _firebaseService.signOut();
//   //   emit(AuthSignedOut());
//   // }
// }

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:softai/model/user.dart';
import 'package:softai/service/firebase_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseService _firebaseService;

  AuthCubit(this._firebaseService) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _firebaseService.getUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError("Error checking authentication: $e"));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user =
          await _firebaseService.login(email: email, password: password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String name, String email, String password,
      String confirmPassword) async {
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      emit(const AuthError("Please fill all fields"));
      return;
    }

    if (password != confirmPassword) {
      emit(const AuthError("Passwords do not match"));
      return;
    }

    emit(AuthLoading());
    try {
      final user = await _firebaseService.signUp(
        fullName: name,
        email: email,
        password: password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError("Sign-up failed, please try again"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _firebaseService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError("Error signing out: $e"));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await _firebaseService.forgotPassword(email);
      emit(const AuthError(
          'Password reset link sent!')); // We reuse AuthError for messages
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
