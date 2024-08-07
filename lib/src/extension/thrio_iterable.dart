// The MIT License (MIT)
//
// Copyright (c) 2021 foxsofter.
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

/// thrio迭代器
extension ThrioIterable<E> on Iterable<E> {
  ///返回第一个元素。 
  /// 
  ///如果' this '为空，返回' null '
  ///否则返回迭代顺序的第一个元素， 
  ///
  E? get firstOrNull => isEmpty ? null : first;

  ///返回最后一个元素。 
  /// 
  ///如果' this '为空，返回' null '
  ///否则可以遍历元素并返回最后一个 
  ///
  E? get lastOrNull => isEmpty ? null : last;

  ///返回满足给定[predicate]的第一个元素。 
  /// 
  ///如果没有元素满足[test]，返回' null '
  ///
  E? firstWhereOrNull(bool Function(E it) predicate) {
    for (final it in this) {
      if (predicate(it)) {
        return it;
      }
    }
    return null;
  }

  ///返回最后一个满足给定[predicate]的元素。 
  /// 
  ///如果没有元素满足[test]，返回' null '
  ///
  E? lastWhereOrNull(bool Function(E it) predicate) {
    final reversed = toList().reversed;
    for (final it in reversed) {
      if (predicate(it)) {
        return it;
      }
    }
    return null;
  }
}
