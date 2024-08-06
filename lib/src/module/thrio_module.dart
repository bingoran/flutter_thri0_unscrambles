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

// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../exception/thrio_exception.dart';
import '../navigator/navigator_logger.dart';
import '../navigator/navigator_types.dart';
import 'module_anchor.dart';
import 'module_expando.dart';
import 'module_json_deserializer.dart';
import 'module_json_serializer.dart';
import 'module_jsonable.dart';
import 'module_page_builder.dart';
import 'module_page_observer.dart';
import 'module_param_scheme.dart';
import 'module_route_action.dart';
import 'module_route_builder.dart';
import 'module_route_custom_handler.dart';
import 'module_route_observer.dart';
import 'module_route_transitions_builder.dart';

part 'module_context.dart';

mixin ThrioModule {
  ///
  ///模块化初始化函数，需要在应用初始化时调用一次
  ///
  static Future<void> init(
    ThrioModule rootModule, {
    String? entrypoint,
    void Function(String)? onModuleInitStart,
    void Function(String)? onModuleInitEnd,
  }) async {
    if (anchor.modules.length == 1) {
      // 初始化方法只能调用一次
      throw ThrioException('init method can only be called once.');
    }
    ThrioModule._onModuleInitStart = onModuleInitStart;
    ThrioModule._onModuleInitEnd = onModuleInitEnd;

    final moduleContext = entrypoint == null
        ? ModuleContext()
        : ModuleContext(entrypoint: entrypoint);
    moduleOf[moduleContext] = anchor;
    anchor
      .._moduleContext = moduleContext
      ..registerModule(rootModule, moduleContext);
    await anchor.onModuleInit(moduleContext);
    await anchor.initModule();
  }

  ///通过' T '，' url '和' key '获取实例。 
  /// 
  /// ' T '可以是' ThrioModule '， ' NavigatorPageBuilder '， ' JsonSerializer '， 
  /// ' JsonDeserializer '， ' ProtobufSerializer '， ' ProtobufDeserializer '， 
  /// ' RouteTransitionsBuilder '，默认为' ThrioModule '。 
  /// 
  ///如果' T '是' ThrioModule '，返回与' url '匹配的最后一个模块。 
  /// 
  ///如果' T '是' ThrioModule '， ' RouteTransitionsBuilder '或 
  /// ' NavigatorPageBuilder '，那么' url '不能为null或空。 
  /// 
  ///如果' T '不是' ThrioModule '， ' RouteTransitionsBuilder '或 
  /// ' NavigatorPageBuilder '和' url '为空或null，查找' T '的实例 
  ///在所有模块中。 
  ///
  static T? get<T>({String? url, String? key}) =>
      anchor.get<T>(url: url, key: key);

  /// Returns true if the `url` has been registered.
  ///
  static bool contains(String url) =>
      anchor.get<NavigatorPageBuilder>(url: url) != null;

  ///通过' T '和' url '获取实例。 
  /// 
  /// ' T '不能为可选项。可以是' NavigatorPageObserver '， 
  /// “NavigatorRouteObserver”。 
  /// 
  ///如果' T '是' NavigatorPageObserver '，返回所有的页面观察者 
  ///匹配' url '。 
  /// 
  ///如果' T '是' NavigatorRouteObserver '，返回所有的路由观察者 
  ///匹配' url '。 
  ///
  static Iterable<T> gets<T>({required String url}) => anchor.gets<T>(url);

  @protected
  final modules = <String, ThrioModule>{};

  /// [Key]是模块的标识符
  ///
  @protected
  String get key => '';

  ///获取父模块。
  ///
  @protected
  ThrioModule? get parent => parentOf[this];

  String? _url;

  ///通过join所有路由节点的名称获取路由url
  ///
  String get url {
    _initUrl(this);
    return _url!;
  }

  ///当前模块的' ModuleContext '。
  ///
  @protected
  ModuleContext get moduleContext => _moduleContext;
  late ModuleContext _moduleContext;

  ///调用module init start。
  ///
  static void Function(String)? get onModuleInitStart => _onModuleInitStart;
  static void Function(String)? _onModuleInitStart;

  ///在模块init结束时调用。
  static void Function(String)? get onModuleInitEnd => _onModuleInitEnd;
  static void Function(String)? _onModuleInitEnd;

  ///一个用于注册模块的函数，该函数将调用 
  ///模块的' onmodulereregister '函数。 
  ///
  @protected
  void registerModule(
    ThrioModule module,
    ModuleContext moduleContext,
  ) {
    if (modules.containsKey(module.key)) {
      throw ThrioException(
          'A module with the same key ${module.key} already exists');
    } else {
      final submoduleContext =
          ModuleContext(entrypoint: moduleContext.entrypoint);
      moduleOf[submoduleContext] = module;
      modules[module.key] = module;
      parentOf[module] = this;
      module
        .._moduleContext = submoduleContext
        ..onModuleRegister(submoduleContext);
    }
  }

  ///一个用于模块初始化的函数，它将调用 
  /// ' onModuleInit '， ' onPageBuilderRegister '， 
  /// ' onRouteTransitionsBuilderRegister '， ' onPageObserverRegister ' 
  /// ' onRouteObserverRegister '， ' onJsonSerializerRegister '， 
  /// ' onJsonDeserializerRegister '， ' onProtobufSerializerRegister '， 
  /// ' onProtobufDeserializerRegister '和' onModuleAsyncInit ' 
  ///所有模块的方法。 
  ///
  @protected
  Future<void> initModule() async {
    final values = modules.values;
    for (final module in values) {
      if (module is ModuleParamScheme) {
        module.onParamSchemeRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModuleRouteAction) {
        module.onRouteActionRegister(module._moduleContext);
      }
      if (module is ModuleRouteCustomHandler) {
        module.onRouteCustomHandlerRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModulePageBuilder) {
        module.onPageBuilderSetting(module._moduleContext);
      }
      if (module is ModuleRouteBuilder) {
        module.onRouteBuilderSetting(module._moduleContext);
      }
      if (module is ModuleRouteTransitionsBuilder) {
        module.onRouteTransitionsBuilderSetting(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModulePageObserver) {
        module.onPageObserverRegister(module._moduleContext);
      }
      if (module is ModuleRouteObserver) {
        module.onRouteObserverRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModuleJsonSerializer) {
        module.onJsonSerializerRegister(module._moduleContext);
      }
      if (module is ModuleJsonDeserializer) {
        module.onJsonDeserializerRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModuleJsonable) {
        module.onJsonableRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      onModuleInitStart?.call(module.url);
      if (kDebugMode) {
        final sw = Stopwatch()..start();
        await module.onModuleInit(module._moduleContext);
        verbose('init: ${module.key} = ${sw.elapsedMicroseconds} µs');
        sw.stop();
      } else {
        await module.onModuleInit(module._moduleContext);
      }
      onModuleInitEnd?.call(module.url);
      await module.initModule();
    }
    for (final module in values) {
      unawaited(module.onModuleAsyncInit(module._moduleContext));
    }
  }

  ///注册子模块的函数
  ///
  @protected
  void onModuleRegister(ModuleContext moduleContext) {}

  ///用于模块初始化的函数
  ///
  @protected
  Future<void> onModuleInit(ModuleContext moduleContext) async {}

  ///返回模块是否被加载。
  ///
  @protected
  bool isLoaded = false;

  ///当模块中的第一页即将被推送时调用
  ///
  @protected
  Future<void> onModuleLoading(ModuleContext moduleContext) async =>
      verbose('onModuleLoading: $key');

  ///当模块中的最后一页被关闭时调用
  ///
  @protected
  Future<void> onModuleUnloading(ModuleContext moduleContext) async =>
      verbose('onModuleUnloading: $key');

  /// A用于模块异步初始化的函数
  ///
  @protected
  Future<void> onModuleAsyncInit(ModuleContext moduleContext) async {}

  @protected
  bool get navigatorLogEnabled => navigatorLogging;

  @protected
  set navigatorLogEnabled(bool enabled) => navigatorLogging = enabled;

  @override
  String toString() => '$key: ${modules.keys.toString()}';

  void _initUrl(ThrioModule module) {
    if (module._url == null) {
      var parentUrl = '';
      final parentModule = module.parent;
      if (parentModule != null &&
          parentModule != anchor &&
          parentModule.key.isNotEmpty) {
        parentUrl = parentModule.url;
      }
      module._url = '$parentUrl/${module.key}';
    }
  }
}
