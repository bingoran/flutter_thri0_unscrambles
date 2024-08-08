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

// ignore_for_file: avoid_as

import 'package:flutter/widgets.dart';

import '../navigator/navigator_page_observer.dart';
import '../navigator/navigator_route.dart';
import '../navigator/navigator_route_observer.dart';
import '../navigator/navigator_route_settings.dart';
import '../navigator/navigator_types.dart';
import '../navigator/navigator_url_template.dart';
import '../navigator/thrio_navigator_implement.dart';
import '../registry/registry_order_map.dart';
import '../registry/registry_set.dart';
import '../registry/registry_set_map.dart';
import 'module_json_deserializer.dart';
import 'module_json_serializer.dart';
import 'module_page_builder.dart';
import 'module_page_observer.dart';
import 'module_param_scheme.dart';
import 'module_route_action.dart';
import 'module_route_builder.dart';
import 'module_route_observer.dart';
import 'module_route_transitions_builder.dart';
import 'module_types.dart';
import 'thrio_module.dart';

// 模块锚
final anchor = ModuleAnchor();

// 锚定类：相当于顶层类，保存一些全局状态
class ModuleAnchor
    with
        ThrioModule,
        ModuleJsonSerializer,
        ModuleJsonDeserializer,
        ModulePageObserver,
        ModuleParamScheme,
        ModuleRouteBuilder,
        ModuleRouteObserver,
        ModuleRouteTransitionsBuilder {

  /// 保存由' NavigatorPageLifecycle '注册的页面观察者
  final pageLifecycleObservers =
      RegistrySetMap<String, NavigatorPageObserver>();

  /// 持有由' NavigatorRoutePush '注册的PushHandler。
  final pushHandlers = RegistrySet<NavigatorRoutePushHandle>();

  /// 用于匹配键模式的路由处理程序的集合。
  final routeCustomHandlers =
      RegistryOrderMap<NavigatorUrlTemplate, NavigatorRouteCustomHandler>();

  /// All registered urls.
  /// 所有已注册的url。
  final allUrls = <String>[];

  ModuleContext get rootModuleContext => modules.values.first.moduleContext;
  
  /// 初始化导航类
  @override
  Future<void> onModuleInit(ModuleContext moduleContext) =>
      ThrioNavigatorImplement.shared().init(moduleContext);
  
  /// url 模块加载中（暂时没有用）
  Future<dynamic> loading(String url) async {
    final modules = _getModules(url: url);
    for (final module in modules) {
      if (!module.isLoaded) {
        module.isLoaded = true;
        await module.onModuleLoading(module.moduleContext);
      }
    }
  }
  
  // 模块卸载（暂时没有用）
  Future<dynamic> unloading(Iterable<NavigatorRoute> allRoutes) async {
    final urls = allRoutes.map<String>((it) => it.settings.url).toSet();
    final notPushedUrls = allUrls.where((it) => !urls.contains(it)).toList();
    final modules = <ThrioModule>{};
    for (final url in notPushedUrls) {
      modules.addAll(_getModules(url: url));
    }
    final notPushedModules = modules
        .where((it) => it is ModulePageBuilder && it.pageBuilder != null)
        .toSet();
    for (final module in notPushedModules) {
      // 页 Module onModuleUnloading
      if (module.isLoaded) {
        module.isLoaded = false;
        await module.onModuleUnloading(module.moduleContext);
        if (module is ModuleParamScheme) {
          module.paramStreamCtrls.clear();
        }
      }
      // 页 Module 的 父 Module onModuleUnloading
      var parentModule = module.parent;
      while (parentModule != null) {
        final leafModules = _getAllLeafModules(parentModule);
        if (notPushedModules.containsAll(leafModules)) {
          if (parentModule.isLoaded) {
            parentModule.isLoaded = false;
            await parentModule.onModuleUnloading(parentModule.moduleContext);
            if (parentModule is ModuleParamScheme) {
              parentModule.paramStreamCtrls.clear();
            }
          }
        }
        parentModule = parentModule.parent;
      }
    }
  }

  T? get<T>({String? url, String? key}) {
    var modules = <ThrioModule>[];
    /// url 不为空的时候的处理
    if (url != null && url.isNotEmpty) {
      final typeString = T.toString();
      modules = _getModules(url: url);
      if (T == ThrioModule || T == dynamic || T == Object) {
        // module 类型，返回最后一个，如果没有，就返回null
        return modules.isEmpty ? null : modules.last as T;
      } else if (typeString == (NavigatorPageBuilder).toString()) {
        // 如果是 NavigatorPageBuilder 类型，url 不能为空
        if (modules.isEmpty) {
          return null;
        }
        // 取出最后一个model
        final lastModule = modules.last;
        // 如果Module实现了 ModulePageBuilder
        if (lastModule is ModulePageBuilder) {
          final builder = lastModule.pageBuilder;
          // 取出pageBuilder，如果值存在，则返回
          if (builder is NavigatorPageBuilder) {
            return builder as T;
          }
        }
      } else if (typeString == (NavigatorRouteBuilder).toString()) {
        if (modules.isEmpty) {
          return null;
        }
        //倒序遍历
        for (final it in modules.reversed) {
          // 如果Module实现了ModuleRouteBuilder，则返回routeBuilder
          if (it is ModuleRouteBuilder) {
            if (it.routeBuilder != null) {
              return it.routeBuilder as T;
            }
          }
        }
        return null;
      } else if (typeString == (RouteTransitionsBuilder).toString()) {
        if (modules.isEmpty) {
          return null;
        }
        //倒序遍历
        for (final it in modules.reversed) {
          // 如果Module实现了ModuleRouteTransitionsBuilder，则返回routeTransitionsBuilder
          if (it is ModuleRouteTransitionsBuilder) {
            /// 是否实现了routeTransitionsBuilder
            if (it.routeTransitionsDisabled) {
              return null;
            }
            if (!it.routeTransitionsDisabled &&
                it.routeTransitionsBuilder != null) {
              return it.routeTransitionsBuilder as T;
            }
          }
        }
        return null;
      } else if (typeString == (NavigatorRouteAction).toString()) {
        // 路由操作
        if (modules.isEmpty || key == null) {
          return null;
        }
        //倒序遍历
        for (final it in modules.reversed) {
          // 如果moudel实现了ModuleRouteAction
          if (it is ModuleRouteAction) {
            // 通过key返回NavigatorRouteAction
            final routeAction = it.getRouteAction(key);
            if (routeAction != null) {
              return routeAction as T;
            }
          }
        }
        return null;
      }
    }
    
    /// modules为空，并且url也是空的情况
    if (modules.isEmpty &&
        (url == null || url.isEmpty || !ThrioModule.contains(url))) {
      modules = _getModules();
    }
    /// 如果key为空，直接返回null
    if (key == null || key.isEmpty) {
      return null;
    }
    return _get<T>(modules, key);
  }
  
  /// 返回路由观察者和页面观察者
  Iterable<T> gets<T>(String url) {
    final modules = _getModules(url: url);
    if (modules.isEmpty) {
      return <T>[];
    }
    final typeString = T.toString();
    if (typeString == (NavigatorPageObserver).toString()) {
      final observers = <NavigatorPageObserver>{};
      for (final module in modules) {
        // 如果moudel实现了ModulePageObserver
        if (module is ModulePageObserver) {
          observers.addAll(module.pageObservers);
        }
      }
      observers.addAll(pageLifecycleObservers[url]);
      //cast 类型转换，将observers里的元素转换为T，如果转换不了就忽略
      return observers.toList().cast<T>();
    } else if (typeString == (NavigatorRouteObserver).toString()) {
      final observers = <NavigatorRouteObserver>{};
      for (final module in modules) {
        // 如果moudel实现了ModuleRouteObserver
        if (module is ModuleRouteObserver) {
          observers.addAll(module.routeObservers);
        }
      }
      return observers.toList().cast<T>();
    }
    return <T>[];
  }

  void set<T>(Comparable<dynamic> key, T value) => setParam(key, value);

  T? remove<T>(Comparable<dynamic> key) => removeParam(key);

  /// 通过url获取所有modules
  /// 1、没传url，则返回所有moduel
  /// 2、传了url, 则获取当前url路径下对应的所有module
  List<ThrioModule> _getModules({String? url}) {
    if (modules.isEmpty) {
      return <ThrioModule>[];
    }
    // 根model
    final firstModule = modules.values.first;
    final allModules = [firstModule];

    if (url == null || url.isEmpty) {
      // 获取子节点所有的 module
      return allModules..addAll(_getAllModules(firstModule));
    }

    ///将类似于 1/2/3 的路径分解为[1、2、3]类型数组
    final components =
        url.isEmpty ? <String>[] : url.replaceAll('/', ' ').trim().split(' ');
    final length = components.length;
    ThrioModule? module = firstModule;
    // 确定根节点，根部允许连续的空节点
    if (components.isNotEmpty) {
      /// 拿出第一个key
      final key = components.removeAt(0);
      // 通过key获取当前模块保存的子模块module
      var m = module.modules[key];
      // 如果没获取到
      if (m == null) {
        // 看看子模块有没有key为 ‘’ 的模块
        m = module.modules[''];
        while (m != null) {
          // 添加进module
          allModules.add(m);
          // 继续检查子模块有没有对应key的模块
          final m0 = m.modules[key];
          // 如果没有
          if (m0 == null) {
            // 继续看看子模块有没有key为 ‘’ 的模块
            m = m.modules[''];
          } else {
            m = m0;
            break;
          }
        }
      }
      if (m == null) {
        return allModules;
      }
      module = m;
      allModules.add(module);
    }
    // 寻找剩余的节点
    while (components.isNotEmpty) {
      final key = components.removeAt(0);
      module = module?.modules[key];
      if (module != null) {
        allModules.add(module);
      }
    }

    // url 不能完全匹配到 module，可能是原生的 url 或者不存在的 url
    if (allModules.where((it) => it.key.isNotEmpty).length != length) {
      return <ThrioModule>[];
    }
    return allModules;
  }
  
  /// 子模块的module都是通过key去存储在父模块的modules中
  /// 这里只需递归遍历，就可以获取到所有的module类
  Iterable<ThrioModule> _getAllModules(ThrioModule module) {
    final subModules = module.modules.values;
    final allModules = [...subModules];
    for (final it in subModules) {
      allModules.addAll(_getAllModules(it));
    }
    return allModules;
  }
  
  /// 获取module的所有实现了ModulePageBuilder的叶子节点
  Iterable<ThrioModule> _getAllLeafModules(ThrioModule module) {
    final subModules = module.modules.values;
    final allLeafModules = <ThrioModule>[];
    for (final module in subModules) {
      if (module is ModulePageBuilder) {
        if (module.pageBuilder != null) {
          allLeafModules.add(module);
        }
      } else {
        allLeafModules.addAll(_getAllLeafModules(module));
      }
    }
    return allLeafModules;
  }
  
  
  // 获取序列化或者反序列化器
  T? _get<T>(List<ThrioModule> modules, String key) {
    /// 获取泛型类型
    final typeString = T.toString();
    ///json序列化类型
    if (typeString == (JsonSerializer).toString()) {
      /// 倒序遍历
      for (final it in modules.reversed) {
        // 如果model实现了序列化器
        if (it is ModuleJsonSerializer) {
          final jsonSerializer = it.getJsonSerializer(key);
          if (jsonSerializer != null) {
            return jsonSerializer as T;
          }
        }
      }
    } else if (typeString == (JsonDeserializer).toString()) {
      ///json反序列化类型
      for (final it in modules.reversed) {
        if (it is ModuleJsonDeserializer) {
          final jsonDeserializer = it.getJsonDeserializer(key);
          if (jsonDeserializer != null) {
            return jsonDeserializer as T;
          }
        }
      }
    }
    return null;
  }
}
