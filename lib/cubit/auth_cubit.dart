// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:softai/model/user.dart';
// import 'package:softai/service/firebase_service.dart';

// part 'auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   final FirebaseService _firebaseService;

//   AuthCubit(this._firebaseService) : super(AuthInitial());

//   Future<void> checkAuth() async {
//     emit(AuthLoading());
//     try {
//       final user = await _firebaseService.getUser();
//       if (user != null) {
//         await _firebaseService.saveTokenForUid(user.uid);
//         _firebaseService.startTokenRefreshListener(user.uid);
//         emit(AuthAuthenticated(user));
//       } else {
//         emit(AuthUnauthenticated());
//       }
//     } catch (e) {
//       emit(AuthUnauthenticated()); // ← never leave user on black screen
//     }
//   }

//   Future<void> signInWithGoogle() async {
//     emit(AuthLoading());
//     try {
//       final user = await _firebaseService.signInWithGoogle();

//       if (user != null) {
//         // ✅ Save FCM token and start listener
//         await _firebaseService.saveTokenForUid(user.uid);
//         _firebaseService.startTokenRefreshListener(user.uid);

//         emit(AuthAuthenticated(user));
//       } else {
//         // User canceled sign-in
//         emit(AuthUnauthenticated());
//       }
//     } catch (e) {
//       emit(AuthError('Google Sign-In failed: ${e.toString()}'));
//     }
//   }

//   Future<void> login(String email, String password) async {
//     emit(AuthLoading());
//     try {
//       final user =
//           await _firebaseService.login(email: email, password: password);
//       if (user != null) {
//         await _firebaseService.saveTokenForUid(user.uid);
//         _firebaseService.startTokenRefreshListener(user.uid);
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
//     if (name.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty) {
//       emit(const AuthError("Please fill all fields"));
//       return;
//     }

//     if (password != confirmPassword) {
//       emit(const AuthError("Passwords do not match"));
//       return;
//     }

//     emit(AuthLoading());
//     try {
//       final user = await _firebaseService.signUp(
//         fullName: name,
//         email: email,
//         password: password,
//       );
//       if (user != null) {
//         await _firebaseService.saveTokenForUid(user.uid);
//         _firebaseService.startTokenRefreshListener(user.uid);
//         emit(AuthAuthenticated(user));
//       } else {
//         emit(const AuthError("Sign-up failed, please try again"));
//       }
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

//   Future<void> signOut() async {
//     // emit(AuthLoading());
//     try {
//       _firebaseService.stopTokenRefreshListener();
//       await _firebaseService.signOut();
//       emit(AuthUnauthenticated());
//     } catch (e) {
//       emit(AuthError("Error signing out: $e"));
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
// }
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
        await _firebaseService.saveTokenForUid(user.uid);
        _firebaseService.startTokenRefreshListener(user.uid);
        await _identifyRevenueCat(user.uid);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _firebaseService.signInWithGoogle();

      if (user != null) {
        await _firebaseService.saveTokenForUid(user.uid);
        _firebaseService.startTokenRefreshListener(user.uid);
        await _identifyRevenueCat(user.uid);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Google Sign-In failed: ${e.toString()}'));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user =
          await _firebaseService.login(email: email, password: password);
      if (user != null) {
        await _firebaseService.saveTokenForUid(user.uid);
        _firebaseService.startTokenRefreshListener(user.uid);
        await _identifyRevenueCat(user.uid);
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
        await _firebaseService.saveTokenForUid(user.uid);
        _firebaseService.startTokenRefreshListener(user.uid);
        await _identifyRevenueCat(user.uid);
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError("Sign-up failed, please try again"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      _firebaseService.stopTokenRefreshListener();
      await _firebaseService.signOut();
      await _logoutRevenueCat();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError("Error signing out: $e"));
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseService.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────
  // RevenueCat identity — links purchases to Firebase UID
  // so subscriptions persist across devices and reinstalls
  // ────────────────────────────────────────────────────

  Future<void> _identifyRevenueCat(String uid) async {
    try {
      await Purchases.logIn(uid);
    } catch (e) {
      // Non-fatal — log but don't block auth
      // ignore: avoid_print
      print('RevenueCat logIn failed: $e');
    }
  }

  Future<void> _logoutRevenueCat() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      // ignore: avoid_print
      print('RevenueCat logOut failed: $e');
    }
  }
}
