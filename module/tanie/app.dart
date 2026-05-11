import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tanie/tanie/bloc/auth/auth_bloc.dart';
import 'package:tanie/tanie/bloc/auth/auth_event.dart';
import 'package:tanie/tanie/bloc/content/content_bloc.dart';
import 'package:tanie/tanie/routes/app_router.dart';
import 'package:tanie/tanie/theme/app_theme.dart';

/// Main App - Photo Reflection Application
/// Integrates routing, theme, and state management
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => ContentBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Photo Reflection',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
