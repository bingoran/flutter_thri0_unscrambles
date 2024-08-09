// The MIT License (MIT)
//
// Copyright (c) 2019 foxsofter
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

import 'package:flutter/material.dart';

import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

// 定义了5中路由类型
enum NavigatorRouteType { push, pop, popTo, remove, replace }

/// A route managed by the `ThrioNavigatorImplement`.
/// 通过 ThrioNavigatorImplement 关联的路由管理器
/// 主要功能是提供路由settings，以及路由拦截相关操作
///
mixin NavigatorRoute on PageRoute<bool> {
  /// 路由状态
  NavigatorRouteType? routeType;

  @override
  RouteSettings get settings;
  
  //pop回调
  NavigatorParamsCallback? poppedResult;
  
  /// 保存pop禁用状态
  final _popDisableds = <String, bool>{};
  /// 保存
  final _popDisabledFutures = <String, Future<dynamic>>{};
  
  // 设置pop是否禁用
  @protected
  void setPopDisabled({bool disabled = false}) {
    if (_popDisableds[settings.name!] == disabled) {
      return;
    }
    _popDisableds[settings.name!] = disabled;

    // 延迟300ms执行，避免因为WillPopScope依赖变更导致发送过多的Channel消息
    _popDisabledFutures[settings.name!] ??=
        Future.delayed(const Duration(milliseconds: 300), () {
      _popDisabledFutures.remove(settings.name); // ignore: unawaited_futures
      final disabled = _popDisableds.remove(settings.name);
      if (disabled != null) {
        ThrioNavigatorImplement.shared().setPopDisabled(
          url: settings.url,
          index: settings.index,
          disabled: disabled,
        );
      }
    });
  }
  
  // 清空
  @protected
  void clearPopDisabledFutures() {
    _popDisabledFutures.clear();
  }
}
