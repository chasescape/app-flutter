import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/coin_manager.dart';
import 'services/purchase_service.dart';
import 'light_handle.dart';
import 'widgets/common_widgets.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'NailVibe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerDelegate: AppRoutes.router.routerDelegate,
      routeInformationParser: AppRoutes.router.routeInformationParser,
      routeInformationProvider: AppRoutes.router.routeInformationProvider,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ValueListenableBuilder<String?>(
            valueListenable: LightHandle.globalLoadingMessage,
            builder: (context, loadingMessage, _) {
              final page = child ?? const SizedBox.shrink();
              return Stack(
                children: [
                  page,
                  if (loadingMessage != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black54,
                        child: Center(
                          child: PopScope(
                            canPop: false,
                            child: Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: PulseLoading(message: loadingMessage),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
      initialBinding: InitialBinding(),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CoinManager());
    Get.put(PurchaseService());
  }
}
