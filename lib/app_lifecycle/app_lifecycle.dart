import 'package:digitos/services/app_lifecycle_service.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:flutter/widgets.dart';

typedef AppLifecycleStateNotifier = ValueNotifier<AppLifecycleState>;

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  final AppLifecycleService appLifecycleService;

  const AppLifecycleObserver(
      {required this.child, required this.appLifecycleService, super.key});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  static final _log = AppLogger('AppLifecycleObserver');

  final ValueNotifier<AppLifecycleState> lifecycleListenable =
      ValueNotifier(AppLifecycleState.inactive);

  @override
  void initState() {
    _log.info('initState');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.appLifecycleService.handleAppStart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    widget.appLifecycleService.handleAppLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
