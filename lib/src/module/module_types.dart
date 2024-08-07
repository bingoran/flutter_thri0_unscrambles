// The MIT License (MIT)
//
// Copyright (c) 2020 foxsofter
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

import 'dart:async';

import '../navigator/navigator_types.dart';

/// 该类定义了Module处理相关的一些类型

/// Signature of callbacks for json serializer.
/// json序列化器的回调签名。
///
typedef JsonSerializer = Map<String, dynamic> Function(T Function<T>() factory);

/// Signature of callbacks for json deserializer.
/// json反序列化器的回调签名。
///
typedef JsonDeserializer<T> = T? Function(Map<String, dynamic> params);

/// Signature of route custom handler.
/// 路由自定义处理程序签名。
///
/// Can be used to handle deeplink or route redirection.
/// 可以用来处理深链接或路由重定向
///
typedef NavigatorRouteCustomHandler = FutureOr<TPopParams?>
    Function<TParams, TPopParams>(
  String url,
  Map<String, List<String>> queryParams, {
  TParams? params,
  bool animated,
  NavigatorIntCallback? result,
  String? fromURL,
  String? innerURL,
});

final _queryParamsDecodedOf = Expando<bool>();

extension NavigatorRouteCustomHandlerX on NavigatorRouteCustomHandler {
  bool get queryParamsDecoded => _queryParamsDecodedOf[this] ?? true;

  set queryParamsDecoded(bool value) => _queryParamsDecodedOf[this] = value;
}

typedef RegisterRouteCustomHandlerFunc = void Function(
  String,
  NavigatorRouteCustomHandler, {
  bool queryParamsDecoded,
});

const navigatorResultTypeHandled = 0;
const navigatorResultTypeNotHandled = -1;

/// Signature of route action.
/// 路由操作的签名
///
/// Can be used to handle route action.
/// 可以用来处理路由操作
///
typedef NavigatorRouteAction = FutureOr<TResult?> Function<TParams, TResult>(
  String url,
  String action,
  Map<String, List<String>> queryParams, {
  TParams? params,
});
