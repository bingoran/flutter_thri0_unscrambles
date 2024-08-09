// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter
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

import 'package:flutter/foundation.dart';

import '../navigator/navigator_url_template.dart';
import 'module_anchor.dart';
import 'module_types.dart';
import 'thrio_module.dart';

// module 路由自定义处理
mixin ModuleRouteCustomHandler on ThrioModule {
  /// Register a route custom handler.
  /// 注册一个路由自定义处理程序
  ///
  /// format of `template` is 'scheme://foxsofter.com/login{userName?,password}'
  /// 'template'的格式为'scheme://foxsofter.com/ogin{userName?,password}'
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  /// 通过调用返回值' VoidCallback '取消注册。
  ///
  @protected
  VoidCallback registerRouteCustomHandler(
    String template,
    NavigatorRouteCustomHandler handler, {
      //查询参数解码
      bool queryParamsDecoded = false,
  }) {
    final key = NavigatorUrlTemplate(template: template);
    handler.queryParamsDecoded = queryParamsDecoded;
    // 保存自定义路由处理集合
    return anchor.routeCustomHandlers.registry(key, handler);
  }

  /// A function for register a `NavigatorRouteCustomHandler` .
  ///
  @protected
  void onRouteCustomHandlerRegister(ModuleContext moduleContext) {}
}
