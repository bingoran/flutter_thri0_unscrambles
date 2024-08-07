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

import 'navigator_route.dart';

/// 该类定义了一些导航相关的一些类型

/// 用routessettings签名页面生成器
///
typedef NavigatorPageBuilder = Widget Function(RouteSettings settings);

/// 用NavigatorPageBuilder和routessettings签名路由构建器
///
typedef NavigatorRouteBuilder = NavigatorRoute Function(
  NavigatorPageBuilder pageBuilder,
  RouteSettings settings,
);

/// 带bool参数的回调签名
///
typedef NavigatorBoolCallback = void Function(bool result);

/// 带int形参的回调签名
///
typedef NavigatorIntCallback = void Function(int index);

/// 带动态参数的回调签名
///
typedef NavigatorParamsCallback = void Function(dynamic params);

/// 用routessettings签名页面观察者回调
///
typedef NavigatorPageObserverCallback = void Function(RouteSettings settings);

enum NavigatorRoutePushHandleType {
  none, // 不阻止路由操作继续进行
  prevention, // 防止路由行为继续
}

/// 用routessettings签名路由推送处理程序
///
typedef NavigatorRoutePushHandle = Future<NavigatorRoutePushHandleType>
    Function(
  RouteSettings settings, {
  bool animated,
});


/// 用url签名push begin/return处理程序
/// 
typedef NavigatorPushHandle = Future<void> Function<TParams>(
  String url, {
  TParams? params,
  String? fromURL,
  String? innerURL,
});
