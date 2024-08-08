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

import 'package:flutter/foundation.dart';

import '../navigator/navigator_types.dart';
import 'module_anchor.dart';
import 'thrio_module.dart';

mixin ModulePageBuilder on ThrioModule {
  NavigatorPageBuilder? _pageBuilder;

  NavigatorPageBuilder? get pageBuilder => _pageBuilder;

  /// If there is a ModulePageBuilder in a module, there can be no submodules.
  /// 如果模块中有ModulePageBuilder，则不能有子模块
  /// 在设置pageBuilder的同时，将module对应的路径（url）缓存起来
  ///
  set pageBuilder(NavigatorPageBuilder? builder) {
    _pageBuilder = builder;
    
    // 当前页面url component
    final urlComponents = <String>['/$key'];
    // 父模块
    var parentModule = parent;
    // 根据当前模块，得到模块的完整路径
    while (parentModule != null && parentModule.key.isNotEmpty) {
      urlComponents.insert(0, '/${parentModule.key}');
      parentModule = parentModule.parent;
    }
    final url = (StringBuffer()..writeAll(urlComponents)).toString();
    if (builder == null) {
       // 如果builder是空的，在全局保存的allUrls中移除这个url
      anchor.allUrls.remove(url);
    } else {
       // 如果builder不为空，在allUrls中添加这个url
      anchor.allUrls.add(url);
    }
  }

  /// A function for setting a `NavigatorPageBuilder`.
  /// 设置NavigatorPageBuilder
  ///
  @protected
  void onPageBuilderSetting(ModuleContext moduleContext) {}
}
