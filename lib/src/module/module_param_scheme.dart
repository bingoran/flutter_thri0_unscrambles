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

import 'package:flutter/foundation.dart';

import '../exception/thrio_exception.dart';
import '../registry/registry_map.dart';
import 'module_anchor.dart';
import 'thrio_module.dart';

mixin ModuleParamScheme on ThrioModule {
  /// Param schemes registered in the current Module
  /// 当前模块中注册的参数schemes
  ///
  final _paramSchemes = RegistryMap<Comparable<dynamic>, Type>();
  
  /// 校验key是否注册过
  @protected
  bool hasParamScheme<T>(Comparable<dynamic> key) {
    if (_paramSchemes.keys.contains(key)) {
      if (T == dynamic || T == Object) {
        return true;
      }
      //这里其实可以处理下，如果注册的时候没有指定类型，注册的默认类型就是dynamic
      //如果在使用的时候，监听属性如果指定了固定类型，如T此时是String；那么此时这里的 _paramSchemes[key] 为注册类型dynamic
      //就会返回false
      return _paramSchemes[key] == T;
    }
    return false;
  }
  
  /// 存储参数流controller
  @protected
  final paramStreamCtrls =
      <Comparable<dynamic>, Set<StreamController<dynamic>>>{};

  /// Subscribe to a series of param by `key`.
  /// 通过' key '订阅一系列参数。
  ///
  @protected
  Stream<T?>? onParam<T>(Comparable<dynamic> key, {T? initialValue}) {
    // 对传入key，
    paramStreamCtrls[key] ??= <StreamController<dynamic>>{};
    /// 
    final sc = StreamController<T?>();
    sc
      ..onListen = () {
        // 存入流数组，set 无序切不重复数据结构
        paramStreamCtrls[key]?.add(sc);
        // 取出key对应最新的值
        final value = getParam<T>(key);
        if (value != null) {
          // 添加进流中
          sc.add(value);
        } else if (initialValue != null) {
          // 如果有默认值，则默认值添加进流中
          sc.add(initialValue);
        }
      }
      ..onCancel = () {
        // 在关闭的时候，需要移除保存的流对象
        paramStreamCtrls[key]?.remove(sc);
      };
    return sc.stream;
  }
  
  // 存储值Map
  final _params = <Comparable<dynamic>, dynamic>{};

  /// Gets param by `key` & `T`.
  /// 获取键为 key 且类型为 T 的参数
  ///
  /// Throw `ThrioException` if `T` is not matched param scheme.
  /// 如果 T 不匹配参数方案，则抛出 ThrioException
  ///
  @protected
  T? getParam<T>(Comparable<dynamic> key) {
    // Anchor module does not need to get param scheme.
    // 锚定模块直接返回值
    if (this == anchor) {
      return _params[key] as T?;
    }
    // 非锚定模块，需要校验key是否注册过
    if (!_paramSchemes.keys.contains(key)) {
      return null;
    }

    ///取出值
    final value = _params[key];
    if (value == null) {
      return null;
    }
    // 如果需要返回的类型和取出来的类型不一致，则抛出异常提示 
    if (T != dynamic && T != Object && value is! T) {
      throw ThrioException(
          '$T does not match the param scheme type: ${value.runtimeType}');
    }
    return value as T?;
  }

  /// Sets param with `key` & `value`.
  /// 使用 key 和 value 设置参数。
  ///
  /// Return `false` if param scheme is not registered.
  /// 如果参数方案未注册，则返回 false。
  ///
  @protected
  bool setParam<T>(Comparable<dynamic> key, T value) {
    // Anchor module does not need to set param scheme.
    // 锚定模块不需要设置参数scheme
    if (this == anchor) {
      // 存储过值，如果当前将要存储的value和存储的类型不一致，返回false
      final oldValue = _params[key];
      if (oldValue != null && oldValue.runtimeType != value.runtimeType) {
        return false;
      }
      _setParam(key, value);
      return true;
    }

    /// 如果key未注册过，则返回直接返回false
    if (!_paramSchemes.keys.contains(key)) {
      return false;
    }

    /// 获取key对应的存储类型
    final schemeType = _paramSchemes[key];
    /// 如果是 dynamic 或者 Object 类型
    if (schemeType == dynamic || schemeType == Object) {
      // 如果当前的key对应有存储值
      final oldValue = _params[key];
      // 校验传入value类型是否和之前存储的一致，如果不一致，返回false
      if (oldValue != null && oldValue.runtimeType != value.runtimeType) {
        return false;
      }
    } else {
      // 如果key对应的存储类型和传入值的类型不一致，返回false
      if (schemeType.toString() != value.runtimeType.toString()) {
        return false;
      }
    }
    // 设置值
    _setParam(key, value);
    return true;
  }

  void _setParam(Comparable<dynamic> key, dynamic value) {
    // 如果值没存储过，进行存储;如果是相同的值，不重复通知
    if (_params[key] != value) {
      // 存储
      _params[key] = value;
      // 检查对应的key有没有steamCtr
      final scs = paramStreamCtrls[key];
      if (scs == null || scs.isEmpty) {
        return;
      }
      /// 如果有对应的steamCtr，则需要通知监听这个值的地方
      for (final sc in scs) {
        if (sc.hasListener && !sc.isPaused && !sc.isClosed) {
          // 将数据加入steam
          sc.add(value);
        }
      }
    }
  }

  /// Remove param by `key` & `T`, if exists, return the `value`.
  /// 如果存在，通过 key 和 T 移除参数，并返回 value。
  ///
  /// Throw `ThrioException` if `T` is not matched param scheme.
  /// 如果 T 不匹配参数scheme，则抛出 ThrioException。
  ///
  T? removeParam<T>(Comparable<dynamic> key) {
    // Anchor module does not need to get param scheme.
    // 锚定模块不需要获取参数scheme
    if (this == anchor) {
      return _params.remove(key) as T?;
    }
    if (T != dynamic &&
        T != Object &&
        _paramSchemes.keys.contains(key) &&
        _paramSchemes[key] != T) {
      throw ThrioException(
          '$T does not match the param scheme type: ${_paramSchemes[key]}');
    }
    final param = _params.remove(key) as T?;
    if (param != null) {
      _setParam(key, param);
    }
    return param;
  }

  /// A function for register a param scheme.
  /// 注册 param scheme，子module实现
  ///
  @protected
  void onParamSchemeRegister(ModuleContext moduleContext) {}

  /// Register a param scheme for the module.
  /// 为模块注册一个参数scheme
  ///
  /// `T` can be optional.
  /// T 可以是可选的。
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  /// 通过调用返回的 VoidCallback 取消注册
  /// Comparable<dynamic> 可比较类型的数据类型
  ///
  @protected
  VoidCallback registerParamScheme<T>(Comparable<dynamic> key) {
    /// 不能重复注册
    if (_paramSchemes.keys.contains(key)) {
      throw ThrioException(
          '$T is already registered for key ${_paramSchemes[key]}');
    }
    ///如果没有传递T，则默认是dynamic类型
    ///对当前key注册T类型
    final callback = _paramSchemes.registry(key, T);
    return () {
      callback();
      final scs = paramStreamCtrls.remove(key);
      if (scs != null && scs.isNotEmpty) {
        for (final sc in scs) {
          sc.close();
        }
      }
    };
  }
}
