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

// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';

import 'package:flutter/material.dart';

import 'navigator_route.dart';
import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

abstract class ThrioNavigator {
  /// Register a handle called before push.
  /// 注册一个在push之前调用的handle
  ///
  static VoidCallback registerPushBeginHandle(NavigatorPushHandle handle) =>
      ThrioNavigatorImplement.shared().registerPushBeginHandle(handle);

  /// Register a handle called before the push return.
  /// 在push返回之前注册一个called
  ///
  static VoidCallback registerPushReturnHandle(NavigatorPushHandle handle) =>
      ThrioNavigatorImplement.shared().registerPushReturnHandle(handle);

  /// Push the page onto the navigation stack.
  /// 将页面推送到导航堆栈。
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// 如果' url '存在native页面构建器，打开native页面;
  /// otherwise open the flutter page.
  /// 否则打开flutter页面
  ///
  static Future<TPopParams?> push<TParams, TPopParams>({
    required String url,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) =>
      ThrioNavigatorImplement.shared().push<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
        fromURL: fromURL,
        innerURL: innerURL,
      );

  /// Push the page onto the navigation stack, and remove all old page.
  /// 将页面推送到导航栈上，并移除所有旧页面
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// 如果存在用于 url 的native页面构建器，则打开native页面；
  /// otherwise open the flutter page.
  /// 否则打开flutter页面
  ///
  static Future<TPopParams?> pushSingle<TParams, TPopParams>({
    required String url,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) =>
      ThrioNavigatorImplement.shared().pushSingle<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
        fromURL: fromURL,
        innerURL: innerURL,
      );

  /// Push the page onto the navigation stack, and remove the top page.
  /// 将页面推送到导航栈上，并移除顶部页面。
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// 如果存在用于 url 的native页面构建器，则打开native页面；
  /// otherwise open the flutter page.
  /// 否则打开flutter页面
  ///
  static Future<TPopParams?> pushReplace<TParams, TPopParams>({
    required String url,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
  }) =>
      ThrioNavigatorImplement.shared().pushReplace<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
        fromURL: fromURL,
      );

  /// Push the page onto the navigation stack, and remove until the last page with `toUrl`.
  /// 将页面推送到导航栈，并移除直到最后一个具有 toUrl 的页面。
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// 如果存在用于 url 的native页面构建器，则打开native页面；
  /// otherwise open the flutter page.
  /// 否则打开flutter页面
  ///
  static Future<TPopParams?> pushAndRemoveTo<TParams, TPopParams>({
    required String url,
    required String toUrl,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
  }) =>
      ThrioNavigatorImplement.shared().pushAndRemoveTo<TParams, TPopParams>(
        url: url,
        toUrl: toUrl,
        params: params,
        animated: animated,
        result: result,
        fromURL: fromURL,
      );

  /// Push the page onto the navigation stack, and remove until the first page with `toUrl`.
  /// 将页面推送到导航栈，并移除直到第一个具有 toUrl 的页面。
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> pushAndRemoveToFirst<TParams, TPopParams>({
    required String url,
    required String toUrl,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
  }) =>
      ThrioNavigatorImplement.shared()
          .pushAndRemoveToFirst<TParams, TPopParams>(
        url: url,
        toUrl: toUrl,
        params: params,
        animated: animated,
        result: result,
        fromURL: fromURL,
      );

  /// Push the page onto the navigation stack, and remove until the last page with `toUrl` satisfies the `predicate`.
  /// 将页面推送到导航栈，并移除直到最后一个满足 predicate 的 toUrl 页面
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> pushAndRemoveUntil<TParams, TPopParams>({
    required String url,
    required bool Function(String url) predicate,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
  }) =>
      ThrioNavigatorImplement.shared().pushAndRemoveUntil<TParams, TPopParams>(
        url: url,
        predicate: predicate,
        params: params,
        animated: animated,
        result: result,
        fromURL: fromURL,
      );

  /// Push the page onto the navigation stack, and remove until the first page with `toUrl` satisfies the `predicate`.
  /// 将页面推送到导航栈，并移除直到第一个满足 predicate 的 toUrl 页面。
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<TPopParams?> pushAndRemoveUntilFirst<TParams, TPopParams>({
    required String url,
    required bool Function(String url) predicate,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
  }) =>
      ThrioNavigatorImplement.shared()
          .pushAndRemoveUntilFirst<TParams, TPopParams>(
        url: url,
        predicate: predicate,
        params: params,
        animated: animated,
        result: result,
        fromURL: fromURL,
      );

  ///向所有页面发送通知。 
  /// 
  ///当页面进入前台时将触发通知。 
  ///具有相同' name '的通知将被覆盖。 
  ///
  static Future<bool> notifyAll<TParams>({
    required String name,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared()
          .notifyAll<TParams>(name: name, params: params);

  ///用' url '向最后一个页面发送通知。 
  /// 
  ///当页面进入前台时将触发通知。 
  ///具有相同' name '的通知将被覆盖。 
  ///
  static Future<bool> notify<TParams>({
    required String url,
    required String name,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyLast<TParams>(
        url: url,
        name: name,
        params: params,
      );

  /// Send a notification to the first page with `url`.
  /// 向第一个具有 url 的页面发送通知
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyFrist<TParams>({
    required String url,
    required String name,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyFirst<TParams>(
        url: url,
        name: name,
        params: params,
      );

  /// Send a notification to the first page with `url` satisfies the `predicate`.
  /// 向第一个满足 predicate 的 url 页面发送通知。
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyFirstWhere<TParams>({
    required bool Function(String url) predicate,
    required String name,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyFirstWhere<TParams>(
        predicate: predicate,
        name: name,
        params: params,
      );

  /// Send a notification to all pages with `url` satisfies the `predicate`.
  /// 向所有满足 predicate 的 url 页面发送通知。
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyWhere<TParams>({
    required bool Function(String url) predicate,
    required String name,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyWhere<TParams>(
        predicate: predicate,
        name: name,
        params: params,
      );

  /// Send a notification to the last page with `url` satisfies the `predicate`.
  /// 向最后一个满足 predicate 的 url 页面发送通知。
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notifyLastWhere<TParams>({
    required bool Function(String url) predicate,
    required String name,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().notifyLastWhere<TParams>(
        predicate: predicate,
        name: name,
        params: params,
      );
  

  /// 生产一个 NavigatorRouteAction
  static Future<TResult?> act<TParams, TResult>({
    required String url,
    required String action,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared()
          .act<TParams, TResult>(url: url, action: action, params: params);

  /// Maybe pop a page from the navigation stack.
  /// 尝试从导航堆栈中弹出一个页面。
  ///
  static Future<bool> maybePop<TParams>({
    TParams? params,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().maybePop<TParams>(
        params: params,
        animated: animated,
      );

  /// Pop a page from the navigation stack.
  /// 从导航堆栈中弹出一个页面。
  ///
  static Future<bool> pop<TParams>({
    TParams? params,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().pop<TParams>(
        params: params,
        animated: animated,
      );

  /// Pop the top Flutter page.
  /// 弹出顶部的 Flutter 页面
  ///
  static Future<bool> popFlutter<TParams>({
    TParams? params,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().popFlutter<TParams>(
        params: params,
        animated: animated,
      );

  /// Pop the page in the navigation stack until the first page.
  /// 从导航栈中弹出页面，直到第一个页面
  ///
  static Future<bool> popToRoot({bool animated = true}) =>
      ThrioNavigatorImplement.shared().popToRoot(animated: animated);

  /// Pop the page in the navigation stack until the last page with `url`.
  /// 在导航堆栈中弹出页面，直到最后一个页面使用' url '。
  ///
  static Future<bool> popTo({
    required String url,
    int? index,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().popTo(
        url: url,
        index: index,
        animated: animated,
      );

  /// Pop the page in the navigation stack until the first page with `url`.
  /// 在导航堆栈中弹出页面，直到第一个带有' url '的页面。
  ///
  static Future<bool> popToFirst({
    required String url,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().popToFirst(
        url: url,
        animated: animated,
      );

  /// Pop the page in the navigation stack until the last page with `url` satisfies the `predicate`.
  /// 在导航堆栈中弹出页面，直到最后一个带有' url '的页面满足 'predicate'。
  ///
  static Future<bool> popUntil({
    required bool Function(String url) predicate,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared()
          .popUntil(predicate: predicate, animated: animated);

  /// Pop the page in the navigation stack until the first page with `url` satisfies the `predicate`.
  /// 从导航栈中弹出页面，直到第一个满足 predicate 的 url 页面。
  ///
  static Future<bool> popUntilFirst({
    required bool Function(String url) predicate,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared()
          .popUntilFirst(predicate: predicate, animated: animated);

  /// Remove the last page with `url` in the navigation stack.
  /// 从导航栈中移除最后一个具有 url 的页面。
  ///
  static Future<bool> remove({
    required String url,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().remove(
        url: url,
        animated: animated,
      );

  /// Remove the first page with `url` in the navigation stack.
  /// 从导航栈中移除第一个具有 url 的页面。
  ///
  static Future<bool> removeFirst({
    required String url,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().removeFirst(
        url: url,
        animated: animated,
      );

  /// Remove pages below the last page in the navigation stack.
  /// 移除导航栈中位于最后一个页面下方的所有页面。
  /// Until the last page with `url` satisfies the `predicate`.
  /// 直到最后一个满足 predicate 的 url 页面。
  ///
  static Future<bool> removeBelowUntil({
    required bool Function(String url) predicate,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().removeBelowUntil(
        predicate: predicate,
        animated: animated,
      );

  /// Remove pages below the last page  in the navigation stack.
  /// 移除导航栈中位于最后一个页面下方的所有页面。
  /// Until the first page with `url` satisfies the `predicate`.
  /// 直到第一个满足 predicate 的 url 页面。
  ///
  static Future<bool> removeBelowUntilFirst({
    required bool Function(String url) predicate,
    bool animated = true,
  }) =>
      ThrioNavigatorImplement.shared().removeBelowUntilFirst(
        predicate: predicate,
        animated: animated,
      );

  /// Remove all pages with `url` in the navigation stack, except the one with index equals to `excludeIndex`.
  /// 删除导航堆栈中所有带有' url '的页面，除了index等于' excludeIndex '的页面。
  ///
  static Future<int> removeAll({required String url, int excludeIndex = 0}) =>
      ThrioNavigatorImplement.shared()
          .removeAll(url: url, excludeIndex: excludeIndex);

  /// Replace the last flutter page with `newUrl` in the navigation stack.
  /// 在导航栈中，用 newUrl 替换最后一个 Flutter 页面。
  ///
  /// Both `url` and `newUrl` must be flutter page.
  /// url 和 newUrl 都必须是 Flutter 页面。
  ///
  static Future<int> replace({
    required String url,
    required String newUrl,
  }) =>
      ThrioNavigatorImplement.shared().replace(
        url: url,
        newUrl: newUrl,
      );

  /// Replace the first flutter page with `newUrl` in the navigation stack.
  /// 在导航栈中，用 newUrl 替换第一个 Flutter 页面。
  ///
  /// Both `url` and `newUrl` must be flutter page.
  /// url 和 newUrl 都必须是 Flutter 页面。
  ///
  static Future<int> replaceFirst({
    required String url,
    required String newUrl,
  }) =>
      ThrioNavigatorImplement.shared().replaceFirst(
        url: url,
        newUrl: newUrl,
      );

  /// Whether the navigator can be popped.
  /// 导航器是否可以被弹出。
  ///
  static Future<bool> canPop() => ThrioNavigatorImplement.shared().canPop();

  /// Build widget with `url` and `params`.
  /// 使用 url 和 params 构建小部件。
  ///
  static Widget? build<TParams>({
    required String url,
    int? index,
    TParams? params,
  }) =>
      ThrioNavigatorImplement.shared().build(
        url: url,
        index: index,
        params: params,
      );

  /// Returns the route of the page that was last pushed to the navigation stack.
  /// 返回最后一个推送到导航栈的页面的路由。
  ///
  static Future<RouteSettings?> lastRoute({String? url}) =>
      ThrioNavigatorImplement.shared().lastRoute(url: url);

  /// Returns all route of the page with `url` in the navigation stack.
  /// 返回导航栈中所有具有 url 的页面的路由。
  ///
  static Future<List<RouteSettings>> allRoutes({String? url}) =>
      ThrioNavigatorImplement.shared().allRoutes(url: url);

  /// Returns the flutter route of the page that was last pushed to the
  /// navigation stack matching `url` and `index`.
  /// 返回最后一个推送到导航栈中，匹配 url 和 index 的 Flutter 路由。
  ///
  static NavigatorRoute? lastFlutterRoute({String? url, int? index}) =>
      ThrioNavigatorImplement.shared().lastFlutterRoute(url: url, index: index);

  /// Returns all flutter route of the page with `url` and `index` in the navigation stack.
  /// 返回导航栈中所有具有 url 和 index 的 Flutter 路由。
  ///
  static List<NavigatorRoute> allFlutterRoutes({String? url, int? index}) =>
      ThrioNavigatorImplement.shared().allFlutterRoutes(url: url, index: index);

  /// Returns true if there is a dialog route on the last matching `url` and `index`.
  /// 如果在最后一个匹配的 url 和 index 上存在对话框路由，则返回 true。
  static bool isDialogAbove({String? url, int? index}) =>
      ThrioNavigatorImplement.shared().isDialogAbove(url: url, index: index);
}
