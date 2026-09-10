import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/service/firebase_service.dart';
import 'package:softai/service/lessons_service.dart';
import 'package:softai/service/subscription_service.dart';

final GetIt locator = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  locator.registerLazySingleton<FirebaseService>(() => FirebaseService());
  locator.registerLazySingleton<LessonService>(() => LessonService());
  locator
      .registerLazySingleton<SubscriptionService>(() => SubscriptionService());
  // Cubits
  locator.registerLazySingleton<AuthCubit>(
    () => AuthCubit(locator<FirebaseService>()),
  );

  locator.registerLazySingleton<UserCubit>(
    () => UserCubit(locator<FirebaseService>(),
        locator<LessonService>()), // <-- Registracija UserCubita
  );
}

/// This method returns all BlocProviders
List<BlocProvider> getBlocProviders() {
  return [
    BlocProvider<AuthCubit>(
      create: (_) => locator<AuthCubit>(),
    ),
    BlocProvider<UserCubit>(
      create: (_) => locator<UserCubit>(),
    ),
    // Add other BlocProviders when needed
    // BlocProvider<OtherCubit>(
    //   create: (_) => locator<OtherCubit>(),
    // ),
  ];
}
