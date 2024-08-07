// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/widgets.dart';

import '../navigator/navigator_route.dart';
import '../navigator/navigator_route_settings.dart';
import '../navigator/navigator_widget.dart';
import '../navigator/thrio_navigator_implement.dart';

/// BuildContext 的拓展
// 主要功能： 
// 1、提供获取组件State方法
// 2、
extension ThrioBuildContext on BuildContext {
  ///通过方法获取部件状态。 
  /// 
  ///如果' state.runtimeType '不是T，抛出' Exception '。 
  ///
  T stateOf<T extends State<StatefulWidget>>() {
    final state = findAncestorStateOfType<T>();
    if (state != null) {
      return state;
    }
    throw Exception('${state.runtimeType} is not a $T');
  }

  ///通过方法获取部件状态。
  ///
  T? tryStateOf<T extends State<StatefulWidget>>() {
    final state = findAncestorStateOfType<T>();
    if (state != null) {
      return state;
    }
    return null;
  }

  /// 使用' shouldCanPop '来决定是否显示后退箭头
  ///
  /// ```dart
  /// AppBar(
  ///   brightness: Brightness.light,
  ///   backgroundColor: Colors.blue,
  ///   title: const Text(
  ///     'thrio_example',
  ///     style: TextStyle(color: Colors.black)),
  ///   leading: context.shouldCanPop(const IconButton(
  ///     color: Colors.black,
  ///     tooltip: 'back',
  ///     icon: Icon(Icons.arrow_back_ios),
  ///     onPressed: ThrioNavigator.pop,
  ///   )),
  /// ))
  /// ```
  /// 显示弹出感知小部件
  Widget showPopAwareWidget(
    Widget trueWidget, {
    Widget falseWidget = const SizedBox(),
    void Function(bool)? canPopResult,
  }) =>
      FutureBuilder<bool>(
          future: _isInitialRoute(),
          builder: (context, snapshot) {
            // 通过call 显示调用回调函数
            canPopResult?.call(snapshot.data != true);

            if (snapshot.data == true) {
              return falseWidget;
            } else {
              return trueWidget;
            }
          });

  Future<bool> _isInitialRoute() {
    final state = stateOf<NavigatorWidgetState>();
    /// 拿到顶层路由
    final route = state.history.last;
    return route is NavigatorRoute
        ? ThrioNavigatorImplement.shared().isInitialRoute(
            url: route.settings.url,
            index: route.settings.index,
          )
        : Future<bool>.value(false);
  }
}
