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

import 'dart:async';

import '../extension/thrio_iterable.dart';

//异步任务队列
class AsyncTaskQueue {
  final _queue = <Completer<dynamic>>[];

  Future<T?> add<T>(Future<T> Function() task, {Duration? timeLimit}) {
    final completer = Completer<T?>();

    void complete(T? value) {
      if (!completer.isCompleted) {
        _queue.remove(completer);
        completer.complete(value);
      }
    }

    // 取出队尾
    final last = _queue.lastOrNull;
    // 在队尾添加这个异步任务
    _queue.insert(_queue.length, completer);
    // 如果前面没有任务，当前任务就是唯一任务，则执行这个任务
    if (last == null) {
      final f = task().then(complete).catchError((_) => complete(null));
      if (timeLimit != null) {
        // 超时处理
        f.timeout(timeLimit, onTimeout: () => complete(null));
      }
    } else {
      // 如果前面有任务，则执行前面取出来的任务
      last.future.whenComplete(() {
        final f = task().then(complete).catchError((_) => complete(null));
        if (timeLimit != null) {
           // 超时处理
          f.timeout(timeLimit, onTimeout: () => complete(null));
        }
      });
    }

    return completer.future;
  }
}
