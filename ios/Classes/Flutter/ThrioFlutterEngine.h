// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter
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

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioFlutterEngine : FlutterEngine

/**
 * Initialize this FlutterEngine.
 *
 * A newly initialized engine will not run until either `-runWithEntrypoint:` or `-runWithEntrypoint:libraryURI:` is called.
 *
 * @param labelPrefix The label prefix used to identify threads for this instance. Should
 *   be unique across FlutterEngine instances, and is used in instrumentation to label
 *   the threads used by this FlutterEngine.
 * @param allowHeadlessExecution Whether or not to allow this instance to continue
 *   running after passing a nil `FlutterViewController` to `-setViewController:`.
 */
/**
 * 初始化这个 FlutterEngine。
 *
 * 一个新初始化的引擎在调用 `-runWithEntrypoint:` 或 `-runWithEntrypoint:libraryURI:` 之前不会运行。
 *
 * labelPrefix 用于标识此实例线程的标签前缀。应该在 FlutterEngine 实例之间唯一，并用于仪器监测中标记该 FlutterEngine 使用的线程。
 * allowHeadlessExecution 是否允许此实例在传递 nil `FlutterViewController` 到 `-setViewController:` 后继续运行。
 */
- (instancetype)initWithName:(NSString *)labelPrefix
      allowHeadlessExecution:(BOOL)allowHeadlessExecution;

/**
 * Creates a running `FlutterEngine` that shares components with this engine
 * @param entrypoint The name of a top-level function from a Dart library.  If this is
 *   FlutterDefaultDartEntrypoint (or nil); this will default to `main()`.  If it is not the app's
 *   main() function, that function must be decorated with `@pragma(vm:entry-point)` to ensure the
 *   method is not tree-shaken by the Dart compiler..
 */
/**
 * 创建一个运行中的 `FlutterEngine`，该引擎与当前引擎共享组件。
 * entrypoint Dart 库中的顶级函数的名称。如果是 FlutterDefaultDartEntrypoint（或 nil），则默认为 `main()`。如果不是应用程序的 `main()` 函数，该函数必须用 `@pragma(vm:entry-point)` 装饰，以确保 Dart 编译器不会对该方法进行树摇优化（tree-shaking）。
 */
- (ThrioFlutterEngine*)forkWithEntrypoint:(NSString *)entrypoint
                         withInitialRoute:(nullable NSString *)initialRoute
                            withArguments:(nullable NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
