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

import 'dart:async';

import 'package:flutter/services.dart';

import '../navigator/navigator_logger.dart';
import '../registry/registry_map.dart';

typedef MethodHandler = Future<dynamic> Function([
  Map<String, dynamic>? arguments,
]);

/// 事件名前缀
const String _kEventNameKey = '__event_name__';

class ThrioChannel {
  // 工厂方法，初始化Channel对象
  factory ThrioChannel({String channel = '__thrio_channel__'}) =>
      ThrioChannel._(channel: channel);

  ThrioChannel._({required String channel}) : _channel = channel;

  final String _channel;
  
  // methodHandler Map
  final _methodHandlers = RegistryMap<String, MethodHandler>();
  
  /// Method Channel
  MethodChannel? _methodChannel;
  /// 事件Channel
  EventChannel? _eventChannel;

  final _eventControllers = <String, List<StreamController<dynamic>>>{};
  
  /// channel 调用（发送）期望返回 List 类型数据
  Future<List<T>?> invokeListMethod<T>(String method,
      [final Map<String, dynamic>? arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel?.invokeListMethod<T>(method, arguments) ??
        Future.value();
  }
  
  ///  channel 调用（发送）期望返回 Map 类型数据
  Future<Map<K, V>?> invokeMapMethod<K, V>(String method,
      [Map<String, dynamic>? arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel?.invokeMapMethod<K, V>(method, arguments) ??
        Future.value();
  }
  
  ///  channel 调用（发送）期望返回 T 类型数据
  Future<T?> invokeMethod<T>(String method, [Map<String, dynamic>? arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel?.invokeMethod<T>(method, arguments) ?? Future.value();
  }
  
  // 注册回调
  VoidCallback registryMethodCall(String method, MethodHandler handler) {
    _setupMethodChannelIfNeeded();
    return _methodHandlers.registry(method, handler);
  }
  
  /// 发送事件channel
  void sendEvent(String name, [Map<String, dynamic>? arguments]) {
    _setupEventChannelIfNeeded();
    final controllers = _eventControllers[name];
    if (controllers != null && controllers.isNotEmpty) {
      for (final controller in controllers) {
        controller.add(<String, dynamic>{
          if (arguments != null) ...arguments,
          _kEventNameKey: name
        });
      }
    }
  }
  
  /// 注册Event事件流
  Stream<Map<String, dynamic>> onEventStream(String name) {
    _setupEventChannelIfNeeded();
    final controller = StreamController<Map<String, dynamic>>();
    // onListen 触发时机是 controller.stream.listen 注册监听器的时候会触发
    // onCancel 触发时机是调用 controller.stream.cancel() 时候会触发
    controller
      ..onListen = () {  
        _eventControllers[name] ??= <StreamController<dynamic>>[];
        _eventControllers[name]?.add(controller);
      }
      ..onCancel = () {
        controller.close();
        _eventControllers[name]?.remove(controller);
      };
    return controller.stream;
  }
  
  /// 如果需要，初始化MethodChannel
  void _setupMethodChannelIfNeeded() {
    if (_methodChannel != null) {
      return;
    }
    _methodChannel = MethodChannel('_method_$_channel')
      ..setMethodCallHandler((call) {
        /// 注册监听，native 调用 flutter
        final handler = _methodHandlers[call.method];
        final args = call.arguments;
        if (handler != null) {
          if (args is Map) {
            final arguments = args.cast<String, dynamic>();
            return handler(arguments);
          } else {
            return handler(null);
          }
        }
        return Future.value();
      });
  }
  
  /// 如果需要，初始化EventChannel
  void _setupEventChannelIfNeeded() {
    if (_eventChannel != null) {
      return;
    }
    _eventChannel = EventChannel('_event_$_channel')
      ..receiveBroadcastStream() // 接收广播流
          .map<Map<String, dynamic>>((data) =>
              data is Map ? data.cast<String, dynamic>() : <String, dynamic>{})
          .where((data) => data.containsKey(_kEventNameKey))
          .listen((data) {
        /// 处理从原生平台接收到的事件或数据
        verbose('Notify on $_channel $data');
        final eventName = data.remove(_kEventNameKey);
        final controllers = _eventControllers[eventName];
        if (controllers != null && controllers.isNotEmpty) {
          for (final controller in controllers) {
            controller.add(data);
          }
        }
      });
  }
}
