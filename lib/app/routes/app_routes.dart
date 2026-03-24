part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SPLASH = _Paths.SPLASH;
  static const SPLASH2 = _Paths.SPLASH2;
  static const SPLASH3 = _Paths.SPLASH3;
  static const ONBOARDING = _Paths.ONBOARDING;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const SPLASH2 = '/splash2';
  static const SPLASH3 = '/splash3';
  static const ONBOARDING = '/onboarding';
}
