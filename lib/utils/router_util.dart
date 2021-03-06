import 'package:cargo_flutter_app/nav/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';

class RouteUtils {
  // 避免 弹 出 多个 登录界面。
  static var _isGoLogin = false;

  static disLogin() {
    _isGoLogin = false;
  }

  static goLogin(BuildContext context) {
    context = context ?? navigatorKey.currentState.context;
    go(context, 'login');
  }

  static go(BuildContext context, String path) {
    if (path == 'login') {
      if (_isGoLogin) {
        // 如果已经 去了 登录界面。
        print("已经去了登录界面");
        return;
      }
      _isGoLogin = true;
    }

    Application.router.navigateTo(
      context,
      '/$path',
      transition: TransitionType.inFromRight,
    );
  }
}
