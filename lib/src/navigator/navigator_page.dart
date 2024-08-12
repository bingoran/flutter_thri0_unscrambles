// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter.
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

import '../exception/thrio_exception.dart';
import '../extension/thrio_dynamic.dart';
import '../module/thrio_module.dart';
import 'navigator_material_app.dart';
import 'navigator_route_settings.dart';

mixin NavigatorPage {
  /// 模块上下文
  ModuleContext get moduleContext;
  /// 路由对象
  RouteSettings get settings;

  /// Get parameter from params, throw ArgumentError when`key`'s value  not found .
  /// 将参数从 params 中获取，如果 key 的值未找到，则抛出 ArgumentError
  ///
  T getParam<T>(String key) => getValue(settings.params, key);

  /// Get parameter from params, return `defaultValue` when`key`'s value  not found .
  /// 从 params 中获取参数，如果 key 的值未找到，则返回 defaultValue
  ///
  T getParamOrDefault<T>(String key, T defaultValue) =>
      getValueOrDefault(settings.params, key, defaultValue);

  /// Get parameter from params.
  ///
  T? getParamOrNull<T>(String key) => getValueOrNull(settings.params, key);

  List<E> getListParam<E>(String key) => getListValue<E>(settings.params, key);

  Map<K, V> getMapParam<K, V>(String key) =>
      getMapValue<K, V>(settings.params, key);

  /// Get moduleContext from current page.
  /// 获取当前页面的 moduleContext
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  /// 此方法不应在 [State.deactivate] 或 [State.dispose] 中调用，
  /// 因为此时元素树已不再稳定。要从这些方法中引用一个祖先，
  /// 请通过在 [State.didChangeDependencies] 中调用 [visitAncestorElements] 保存对该祖先的引用。
  ///
  static ModuleContext moduleContextOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) {
    // 根据context获取当前页面widget
    final page = of(context, pageModuleContext: pageModuleContext);
    if (page != null) {
      // 找到了page,返回moduleContext
      return page.moduleContext;
    }
    // 触发兜底逻辑
    final widget = context.widget;
    // 如果当前context对应的widget是NavigatorMaterialApp，返回context
    if (widget is NavigatorMaterialApp) {
      return widget.moduleContext;
    }
    NavigatorMaterialApp? app;
    // 遍历该context的父组件，寻找是否有NavigatorMaterialApp类型的widget
    context.visitAncestorElements((it) {
      final widget = it.widget;
      if (widget is NavigatorMaterialApp) {
        app = widget;
        return false;
      }
      return true;
    });
    if (app == null) {
      throw ThrioException('no moduleContext on the app');
    }
    return app!.moduleContext;
  }

  /// Get params of current page.
  /// 获取当前page的传入参数
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static dynamic paramsOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      routeSettingsOf(context, pageModuleContext: pageModuleContext).params;

  /// Get RouteSettings of current page.
  /// 根据当前上下文，获取RouteSettings
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static RouteSettings routeSettingsOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      of(context, pageModuleContext: pageModuleContext)?.settings ??
      (throw ThrioException('no RouteSettings on the page'));

  /// Get url of current page.
  /// 返回当前page的url
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static String urlOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      routeSettingsOf(context, pageModuleContext: pageModuleContext).url;

  /// Get index of current page.
  /// 通过index获取当前页面
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  ///
  static int indexOf(
    BuildContext context, {
    bool pageModuleContext = false,
  }) =>
      routeSettingsOf(context, pageModuleContext: pageModuleContext).index;

  /// Get current page.
  /// 获取当前页面。
  ///
  /// This method should not be called from [State.deactivate] or [State.dispose]
  /// because the element tree is no longer stable at that time. To refer to
  /// an ancestor from one of those methods, save a reference to the ancestor
  /// by calling [visitAncestorElements] in [State.didChangeDependencies].
  /// 此方法不应在 [State.deactivate] 或 [State.dispose] 中调用，因为此时元素树已不再稳定。
  /// 要在这些方法中引用一个祖先，请在 [State.didChangeDependencies] 中通过调用 [visitAncestorElements] 来保存对该祖先的引用。
  ///
  static NavigatorPage? of(
    BuildContext context, {
    bool pageModuleContext = false,
  }) {
    NavigatorPage? page;
    // 获取当前context的对应的widget
    final widget = context.widget;
    // 如果widget是NavigatorPage类型(页面实现了 NavigatorPage 这个minxi)
    if (widget is NavigatorPage) {
      page = widget as NavigatorPage;
      // pageModuleContext 为true
      if (pageModuleContext) {
        if (page.settings.isPushed) {
          return page;
        }
      } else {
        return page;
      }
      // 如果
      page = null;
    }

    //遍历当前 BuildContext 的祖先元素
    context.visitAncestorElements((it) {
      final widget = it.widget;
      if (widget is NavigatorPage) {
        page = widget as NavigatorPage;
        if (pageModuleContext) {
          return page!.settings.isPushed;
        }
        //返回 false 以停止遍历
        return false;
      }
      //返回 true 以继续遍历
      return true;
    });
    return page;
  }

  static List<RouteSettings> routeSettingsListOf(BuildContext context) {
    final settingsList = <RouteSettings>[];
    if (context.widget is NavigatorPage) {
      final settings = (context.widget as NavigatorPage).settings;
      if (settings.isSelected != null || !settings.isBuilt) {
        settingsList.add(settings);
      }
    }
    context.visitAncestorElements((it) {
      if (it.widget is NavigatorPage) {
        final settings = (it.widget as NavigatorPage).settings;
        if (settings.isSelected != null || !settings.isBuilt) {
          // 如果已存在，则干掉并新增，因为带相同的 RouteSettings 的 NavigatorPage 会重复出现在链路上
          settingsList
            ..removeWhere((it) => it.name == settings.name)
            ..add(settings);
        }
        return settings.isBuilt;
      }
      return true;
    });
    return settingsList;
  }
}
