// The MIT License (MIT)
//
// Copyright (c) 2021 foxsofter
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

/// object 类的拓展
/// 1、对象是否是bool类型
/// 2、对象是否是int类型
/// 3、对象是否是double类型
/// 4、对象是否是num类型
/// 5、对象是否是String类型
/// 6、对象是否是List类型
/// 7、对象是否是只包含简单数据List类型
/// 8、对象是否是Map类型
/// 9、对象是否是只包含简单Map类型
/// 10、对象是否是基础数据类型（bool、num、String）
/// 11、是否是简单类型（bool、num、String、简单List、简单Map）
/// 12、是否是负责类型，和11相反
extension ThrioObject on Object {
  ///判断当前实例是否为bool类型。 
  /// 
  ///可以通过以下方式调用: 
  /// ' true.isDouble ' 
  /// ' false.runtimeType.isDouble ' 
  ///
  bool get isBool {
    if (this is Type) {
      return this == bool;
    } else {
      return this is bool;
    }
  }

  ///判断当前实例是否为int类型。 
  /// 
  ///可以通过以下方式调用: 
  /// ' 2. isint ' 
  /// ' 2. runtimetype.isint ' 
  ///
  bool get isInt {
    if (this is Type) {
      return this == int;
    } else {
      return this is int;
    }
  }

  /// 判断当前实例是否是双精度类型。
  ///
  /// 可以通过以下方式调用:
  /// `2.0.isDouble`
  /// `2.0.runtimeType.isDouble`
  ///
  bool get isDouble {
    if (this is Type) {
      return this == double;
    } else {
      return this is double;
    }
  }

  /// 确定当前实例是整型还是双精度类型。
  ///
  /// 可以通过以下方式调用，
  /// `2.isNumber`
  /// `2.0.runtimeType.isNumber`
  ///
  bool get isNumber {
    if (this is Type) {
      return this == double || this == int;
    } else {
      return this is num;
    }
  }

  /// 确定当前实例是否为String。
  ///
  /// 可以通过以下方式调用，
  /// `'2'.isString`
  /// `'2'.runtimeType.isString`
  ///
  bool get isString {
    if (this is Type) {
      return this == String;
    } else {
      return this is String;
    }
  }

  /// 确定当前实例是否是List。
  ///
  /// 可以通过以下方式调用，
  /// `[ 'k', '2' ].isString`
  /// `[ 'k', '2' ].runtimeType.isString`
  ///
  bool get isList {
    if (this is Type) {
      return toString().contains('List');
    } else {
      return this is List;
    }
  }

  /// 确定当前实例是否是一个简单的List。
  ///
  /// 可以通过以下方式调用，
  /// `[ 'k', '2' ].isString`
  ///
  bool get isSimpleList {
    final ts = this;
    if (ts is! List) {
      return false;
    }
    for (final it in ts) {
      if (it is Object && it.isSimpleType == false) {
        return false;
      }
    }
    return true;
  }

  /// 确定当前实例是否是Map。
  ///
  /// 可以通过以下方式调用，
  /// `{ 'k': 2 }.isMap`
  /// `{ 'k': 2 }.runtimeType.isMap`
  ///
  bool get isMap {
    if (this is Type) {
      return toString().contains('Map');
    } else {
      return this is Map;
    }
  }

  /// 确定当前实例是否是一个简单的Map。
  ///
  /// 可以通过以下方式调用，
  /// `{ 'k': 2 }.isMap`
  ///
  bool get isSimpleMap {
    final ts = this;
    if (ts is! Map) {
      return false;
    }
    for (final it in ts.values) {
      if (it is Object && it.isSimpleType == false) {
        return false;
      }
    }
    return true;
  }

  /// 确定当前实例是否是基本类型，
  /// 包括bool, int, double, String。
  ///
  /// 可以通过以下方式调用，
  /// `2.isPrimitiveType`
  /// `2.runtimeType.isPrimitiveType`
  ///
  bool get isPrimitiveType {
    if (this is Type) {
      return this == bool || this == int || this == double || this == String;
    } else {
      return this is bool || this is num || this is String;
    }
  }

  /// 确定当前实例是否是简单类型，
  /// 包括bool, int, double, String, Map, List。
  ///
  /// 可以通过以下方式调用，
  /// `2.isSimpleType`
  ///
  bool get isSimpleType => isPrimitiveType || isSimpleList || isSimpleMap;

  /// 确定当前实例是否是复杂类型，
  /// 不是bool, int, double, String, Map, List。
  ///
  /// 可以通过以下方式调用，
  /// `2.isComplexType`
  ///
  bool get isComplexType => !isSimpleType;
}
