import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../features/home/providers/lash_provider.dart';
import '../features/history/providers/history_provider.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/coin_store/providers/coin_provider.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  if (!getIt.isRegistered<http.Client>()) {
    getIt.registerLazySingleton<http.Client>(() => http.Client());
  }

  if (!getIt.isRegistered<LashProvider>()) {
    getIt.registerFactory<LashProvider>(() => LashProvider(getIt));
  }
  if (!getIt.isRegistered<HistoryProvider>()) {
    getIt.registerFactory<HistoryProvider>(() => HistoryProvider(getIt));
  }
  if (!getIt.isRegistered<ProfileProvider>()) {
    getIt.registerFactory<ProfileProvider>(() => ProfileProvider(getIt));
  }
  if (!getIt.isRegistered<CoinProvider>()) {
    getIt.registerFactory<CoinProvider>(() => CoinProvider(getIt));
  }
}
