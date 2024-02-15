import 'package:go_router/go_router.dart';

class NavigationService {
  final GoRouter router;

  NavigationService(this.router);

  void navigateTo(String route) {
    router.go(route);
  }

  void navigateToNamed(String name, {Map<String, dynamic>? extra}) {
    router.pushNamed(name, extra: extra);
  }
}
