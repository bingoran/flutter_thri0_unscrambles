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

#import "ThrioFlutterEngine.h"
#import <objc/message.h>

@interface ThrioFlutterEngine ()

- (id)performSelector:(SEL)aSelector withObject:(id)obj1 withObject:(id)obj2 withObject:(id)obj3 withObject:(id)obj4;

@end

@implementation ThrioFlutterEngine

/**
 * 初始化这个 FlutterEngine。
 *
 * 一个新初始化的引擎在调用 `-runWithEntrypoint:` 或 `-runWithEntrypoint:libraryURI:` 之前不会运行。
 *
 * labelPrefix 用于标识此实例线程的标签前缀。应该在 FlutterEngine 实例之间唯一，并用于仪器监测中标记该 FlutterEngine 使用的线程。
 * allowHeadlessExecution 是否允许此实例在传递 nil `FlutterViewController` 到 `-setViewController:` 后继续运行。
 */
- (instancetype)initWithName:(NSString *)labelPrefix
      allowHeadlessExecution:(BOOL)allowHeadlessExecution {
    return [super initWithName:labelPrefix project:nil allowHeadlessExecution:allowHeadlessExecution];
}

/**
 * 创建一个运行中的 `FlutterEngine`，该引擎与当前引擎共享组件。
 * entrypoint Dart 库中的顶级函数的名称。如果是 FlutterDefaultDartEntrypoint（或 nil），则默认为 `main()`。如果不是应用程序的 `main()` 函数，该函数必须用 `@pragma(vm:entry-point)` 装饰，以确保 Dart 编译器不会对该方法进行树摇优化（tree-shaking）。
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (ThrioFlutterEngine*)forkWithEntrypoint:(NSString *)entrypoint
                         withInitialRoute:(nullable NSString *)initialRoute
                            withArguments:(nullable NSArray *)arguments {
    SEL sel = @selector(spawnWithEntrypoint:libraryURI:initialRoute:entrypointArgs:);
    return [self performSelector:sel withObject:entrypoint withObject:nil withObject:initialRoute withObject:arguments];
}
#pragma clang diagnostic pop

- (id)performSelector:(SEL)aSelector withObject:(id)obj1 withObject:(id)obj2 withObject:(id)obj3 withObject:(id)obj4 {
    // 如果传递进来的选择器为空，则调用doesNotRecognizeSelector抛出异常
    if (!aSelector) [self doesNotRecognizeSelector:aSelector];
    return ((id(*)(id, SEL, id, id, id, id))objc_msgSend)(self, aSelector, obj1, obj2, obj3, obj4);
}

@end
