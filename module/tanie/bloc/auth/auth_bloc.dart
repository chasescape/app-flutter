import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tanie/tanie/interface.dart';
import 'package:tanie/tanie/bloc/auth/auth_event.dart';
import 'package:tanie/tanie/bloc/auth/auth_state.dart';
import 'package:tanie/tanie/light_handle.dart';
import 'package:tanie/tanie/services/coins_manager.dart';
import 'package:tanie/tanie/services/reflection_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<UpdateCoinsEvent>(_onUpdateCoins);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final token = Interface().authToken?.trim();
    if (token != null && token.isNotEmpty) {
      // Initialize and get coins from CoinsManager
      await coinsManager.init();
      emit(state.copyWith(
        isAuthenticated: true,
        username: 'User',
        coins: coinsManager.currentCoins,
      ));
    } else {
      emit(state.copyWith(isAuthenticated: false));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Set and persist auth token
      await LightHandle.persistAuthToken('mock_token');

      // Initialize CoinsManager
      await coinsManager.init();

      emit(state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        username: 'User',
        coins: coinsManager.currentCoins,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed',
      ));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Clear persisted auth token
      await LightHandle.onAuthTokenRemoved();

      emit(state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Logout failed',
      ));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Clear all data
      await LightHandle.onAuthTokenRemoved();
      Interface().userId = null;
      Interface().deviceId = null;

      // Remove generated reflections and reset coins to the default amount.
      await reflectionStorageService.clearAll();
      await coinsManager.setCoins(CoinsManager.initialCoins);

      emit(const AuthState(
        isAuthenticated: false,
        isLoading: false,
        coins: CoinsManager.initialCoins,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Delete account failed',
      ));
    }
  }

  Future<void> _onUpdateCoins(
    UpdateCoinsEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Sync to CoinsManager
    await coinsManager.setCoins(event.coins);
    emit(state.copyWith(coins: event.coins));
  }
}
