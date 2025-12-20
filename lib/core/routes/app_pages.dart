import 'package:aims_timekeeper/features/home/view/home_view.dart';
import 'package:get/get.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/login/views/login_view.dart';
import '../../features/login/bindings/login_binding.dart';
import '../../features/home/bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}