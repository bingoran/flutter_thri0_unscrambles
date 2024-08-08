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

import 'package:flutter/widgets.dart';

import 'thrio_module.dart';

/// 路由过渡builder
/// 支持 Flutter 端自定义转场动画
mixin ModuleRouteTransitionsBuilder on ThrioModule {
  @protected
  RouteTransitionsBuilder? routeTransitionsBuilder;

  @protected
  bool get routeTransitionsDisabled => routeTransitionsBuilder == null;

  /// A function for setting a `RouteTransitionsBuilder` .
  /// 设置RouteTransitionsBuilder函数
  ///
  @protected
  void onRouteTransitionsBuilderSetting(ModuleContext moduleContext) {}
}

// 使用示例
// 添加自定义转场动画的示例如下，可以定义正则表达式来作为自定义转场的匹配字符串，只要满足该正字符串的 URL 的都会使用该自定义的转场动画。
// 需要注意的是，规则先注册先生效。通过正则可以灵活的匹配自己整个模块的所有页面的 URL 或者一个特定的 URL

// ```dart
// class Module
//     with
//         ThrioModule,
//         ModuleRouteTransitionsBuilder,
//   @override
//   void onRouteTransitionsBuilderRegister() {
//     registerRouteTransitionsBuilder(
//         '\/biz1\/flutter[0-9]*',
//         (
//           context,
//           animation,
//           secondaryAnimation,
//           child,
//         ) =>
//             SlideTransition(
//               transformHitTests: false,
//               position: Tween<Offset>(
//                 begin: const Offset(0, -1),
//                 end: Offset.zero,
//               ).animate(animation),
//               child: SlideTransition(
//                 position: Tween<Offset>(
//                   begin: Offset.zero,
//                   end: const Offset(0, 1),
//                 ).animate(secondaryAnimation),
//                 child: child,
//               ),
//             ));
//   }
// }