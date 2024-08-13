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

#import <Foundation/Foundation.h>
#import "FlutterThrioTypes.h"
#import "ThrioModuleContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioModule : NSObject

@property (nonatomic, readonly) ThrioModuleContext *moduleContext;

///一个用于模块初始化的函数，它将调用' onPageBuilderRegister: '， ' onModuleInit: '
///和所有模块的' onModuleAsyncInit: '方法。
///
///只在应用启动时调用一次。
///
+ (void)init:(ThrioModule *)module preboot:(BOOL)preboot;

/// 初始化多引擎
+ (void)initMultiEngine:(ThrioModule *)module;

///一个注册模块的函数。
///
///应该在' onModuleRegister: '中调用。
///
- (void)registerModule:(ThrioModule *)module
     withModuleContext:(ThrioModuleContext *)moduleContext;

///注册子模块的函数。
///
- (void)onModuleRegister:(ThrioModuleContext *)moduleContext;

///用于模块初始化的函数。
///
- (void)onModuleInit:(ThrioModuleContext *)moduleContext;

///异步初始化模块的函数。
///
- (void)onModuleAsyncInit:(ThrioModuleContext *)moduleContext;

@end

NS_ASSUME_NONNULL_END
