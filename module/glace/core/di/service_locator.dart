import 'package:get_it/get_it.dart';
import '../storage/local_storage.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final storage = LocalStorage.instance;
  await storage.init();
  getIt.registerSingleton<LocalStorage>(storage);
}
