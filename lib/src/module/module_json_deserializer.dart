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

import 'package:flutter/foundation.dart';

import '../registry/registry_map.dart';
import 'module_types.dart';
import 'thrio_module.dart';

mixin ModuleJsonDeserializer on ThrioModule {
  /// Json deserializer registered in the current Module
  /// 当前模块中注册的 JSON 反序列化器
  final _jsonDeserializers = RegistryMap<Type, JsonDeserializer<dynamic>>();

  /// Get json deserializer by type string.
  /// 根据类型字符串获取 JSON 反序列化器
  @protected
  JsonDeserializer<dynamic>? getJsonDeserializer(String typeString) {
    final type = _jsonDeserializers.keys.lastWhere(
        (it) =>
            it.toString() == typeString || typeString.endsWith(it.toString()),
        orElse: () => Null);
    return _jsonDeserializers[type];
  }

  /// A function for register a json deserializer.
  /// 一个用于注册 JSON 反序列化器的函数，子类实现，初始化的时候会统一调用
  ///
  @protected
  void onJsonDeserializerRegister(ModuleContext moduleContext) {}

  /// Register a json deserializer for the module.
  /// 注册模块的 JSON 反序列化器。
  /// Unregistry by calling the return value `VoidCallback`.
  /// 通过调用返回的 VoidCallback 取消注册。
  ///
  @protected
  VoidCallback registerJsonDeserializer<T>(JsonDeserializer<T> deserializer) =>
      _jsonDeserializers.registry(T, deserializer);
}
