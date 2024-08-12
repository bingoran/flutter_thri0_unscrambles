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
    ThrioModule rootModule, { // 业务根model,从业务根model可以遍历完整个业务线依赖的model
    String? entrypoint, // 业务入口标识
    void Function(String)? onModuleInitStart, // 模块初始化开始回调
    void Function(String)? onModuleInitEnd, // 模块初始化完成回调
  }) async {
    if (anchor.modules.length == 1) {
      // 初始化方法只能调用一次
      throw ThrioException('init method can only be called once.');
    }

    /// 保存初始化回调
    ThrioModule._onModuleInitStart = onModuleInitStart;
    ThrioModule._onModuleInitEnd = onModuleInitEnd;

    // 初始化的时候，初始化模块上线文
    final moduleContext = entrypoint == null
        ? ModuleContext()
        : ModuleContext(entrypoint: entrypoint);
    // 把锚通过Expando存到moduleContext对象上，在ModuleContext内部，通过moduleOf[this]即可获取到anchor
    // anchor 是继承自ThrioModule，因此，在内部返回类型表示为ThrioModule
    moduleOf[moduleContext] = anchor;
    
    /// 1、绑定上下文
    /// 2、注册app依赖的model
    anchor
      .._moduleContext = moduleContext
      ..registerModule(rootModule, moduleContext);
    /// 模块初始化，导航器初始化，通讯channel初始化
    await anchor.onModuleInit(moduleContext);
    await anchor.initModule();
  }

  ///通过' T '，' url '和' key '获取实例对应的保存的 T。 
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

  /// 如果' url '已注册，则返回true。
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
  
  ///保存当前 moduel 的子moduel
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

  ///当前模块的' ModuleContext '
  ///
  @protected
  ModuleContext get moduleContext => _moduleContext;
  /// 初始化的时候设置上下文
  late ModuleContext _moduleContext;

  ///调用模块 init 开始。
  static void Function(String)? get onModuleInitStart => _onModuleInitStart;
  static void Function(String)? _onModuleInitStart;

  ///在模块 init 结束时调用。
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
      // 抛出异常，具有相同key的模块已经存在
      throw ThrioException(
          'A module with the same key ${module.key} already exists');
    } else {
      // 初始化子模块的上下文，入口名保持一致
      final submoduleContext =
          ModuleContext(entrypoint: moduleContext.entrypoint);
      /// 将模块存储在 Expando 里, 在context内部，通过moduleOf[this]就可以获取到这个moudule
      moduleOf[submoduleContext] = module;
      // 将model保存在modules里
      modules[module.key] = module;
      // 在注册子模块的时候，当前model就是父model，在model内部， 通过 parentOf[this] 就可以获取父moduel
      parentOf[module] = this;
      // 对module进行上下文绑定，并对开始从根model的onModuleRegister方法开始注册APP依赖的所有model
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
    //对子模块进行处理
    final values = modules.values;
    /// 注册模块对应的Param Scheme，Param Scheme主要作用是在moduelContext上新增属性，以及对熟悉进行监听
    for (final module in values) {
      if (module is ModuleParamScheme) {
        module.onParamSchemeRegister(module._moduleContext);
      }
    }
    /// 注册路由Route Action 和自定义的路由处理
    for (final module in values) {
      if (module is ModuleRouteAction) {
        module.onRouteActionRegister(module._moduleContext);
      }
      if (module is ModuleRouteCustomHandler) {
        module.onRouteCustomHandlerRegister(module._moduleContext);
      }
    }

    /// 页面注册
    for (final module in values) {
      // 注册页面
      if (module is ModulePageBuilder) {
        module.onPageBuilderSetting(module._moduleContext);
      }
      //注册路由builder，返回的是 NavigatorRoute 对象，在执行路由操作的时候，如果有重写，优先使用重写
      if (module is ModuleRouteBuilder) {
        module.onRouteBuilderSetting(module._moduleContext);
      }
      //注册页面过渡动画
      if (module is ModuleRouteTransitionsBuilder) {
        module.onRouteTransitionsBuilderSetting(module._moduleContext);
      }
    }
    
    // 监听
    for (final module in values) {
      // 页面生命周期监听， 用于module生命周期监听
      if (module is ModulePageObserver) {
        module.onPageObserverRegister(module._moduleContext);
      }
      // 路由生命周期监听，用于module支持路由监听
      if (module is ModuleRouteObserver) {
        module.onRouteObserverRegister(module._moduleContext);
      }
    }
    
    // 注册编解码对象，一般它们是成对出现的
    for (final module in values) {
      /// 注册编码器
      if (module is ModuleJsonSerializer) {
        module.onJsonSerializerRegister(module._moduleContext);
      }
      // 注册解码器
      if (module is ModuleJsonDeserializer) {
        module.onJsonDeserializerRegister(module._moduleContext);
      }
    }
    
    // 注册 ModuleJsonable：应该是通过Jsonable简化上面编解码的使用
    for (final module in values) {
      if (module is ModuleJsonable) {
        module.onJsonableRegister(module._moduleContext);
      }
    }

    for (final module in values) {
      // 回调正在初始化哪个模块（同步初始化）
      onModuleInitStart?.call(module.url);
      // debug 环境打印模块初始化事件，正是环境不打印
      if (kDebugMode) {
        final sw = Stopwatch()..start();
        await module.onModuleInit(module._moduleContext);
        verbose('init: ${module.key} = ${sw.elapsedMicroseconds} µs');
        sw.stop();
      } else {
        await module.onModuleInit(module._moduleContext);
      }
      // 回调module为url的模块初始化结束
      onModuleInitEnd?.call(module.url);
      // 继续初始化子模块
      await module.initModule();
    }
    
    //模块异步初始化
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

  ///返回模块是否被加载
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
