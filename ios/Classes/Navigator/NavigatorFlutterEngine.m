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

#import "NavigatorFlutterEngine.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorLogger.h"
#import "NavigatorRouteObserverChannel.h"
#import "NSPointerArray+Thrio.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterEngine ()

@property (nonatomic, copy, readwrite) NSString *entrypoint;

@property (nonatomic, readwrite) ThrioFlutterEngine *flutterEngine;

@property (nonatomic) ThrioChannel *channel;

@property (nonatomic, readwrite) ThrioChannel *moduleContextChannel;

@property (nonatomic, readwrite) NavigatorRouteReceiveChannel *receiveChannel;

@property (nonatomic, readwrite) NavigatorRouteSendChannel *sendChannel;

@property (nonatomic, readwrite) NavigatorPageObserverChannel *pageChannel;

@property (nonatomic) NavigatorRouteObserverChannel *routeChannel;

@property (nonatomic, strong) NSPointerArray *flutterViewControllers;

@end

@implementation NavigatorFlutterEngine

- (instancetype)initWithEntrypoint:(NSString *)entrypoint
                        withEngine:(ThrioFlutterEngine *)flutterEngine {
    self = [super init];
    if (self) {
        _flutterViewControllers = [NSPointerArray weakObjectsPointerArray];
        _entrypoint = entrypoint;
        _flutterEngine = flutterEngine;
    }
    return self;
}

// 启动引擎
- (void)startupWithReadyBlock:(ThrioEngineReadyCallback _Nullable)block {
    if (_flutterEngine) {
        // flutter 引擎初始化
        [self startupFlutterEngine];
        // 插件注册
        [self registerPlugins];
        // 启动channel
        [self setupChannelWithReadyBlock:block];
    }
}

- (void)pushViewController:(NavigatorFlutterViewController *)viewController {
    NavigatorVerbose(@"NavigatorFlutterEngine: enter pushViewController");
    if (viewController != nil && (_flutterEngine.viewController == nil || _flutterEngine.viewController != viewController)) {
        if (_flutterEngine.viewController) {
            [(NavigatorFlutterViewController *)_flutterEngine.viewController surfaceUpdated:NO];
            [_flutterViewControllers removeLastObject:_flutterEngine.viewController];
            _flutterEngine.viewController = nil;
        }
        NavigatorVerbose(@"NavigatorFlutterEngine: set new %@", viewController);
        _flutterEngine.viewController = viewController;
        [_flutterViewControllers addObject:viewController];
        [(NavigatorFlutterViewController *)_flutterEngine.viewController surfaceUpdated:YES];
        [[_flutterEngine lifecycleChannel] performSelector:@selector(sendMessage:) withObject: @"AppLifecycleState.resumed"];
    }
}

- (NSUInteger)popViewController:(NavigatorFlutterViewController *)viewController {
    NavigatorVerbose(@"NavigatorFlutterEngine: enter popViewController");
    if (viewController != nil && _flutterEngine.viewController == viewController) {
        NavigatorVerbose(@"NavigatorFlutterEngine: unset %@", viewController);
        if (viewController) {
            [viewController surfaceUpdated:NO];
            [_flutterViewControllers removeLastObject:viewController];
            _flutterEngine.viewController = nil;
        }
        NavigatorFlutterViewController *vc = _flutterViewControllers.last;
        if (viewController != vc) {
            _flutterEngine.viewController = vc;
            if (vc && vc.isFirstResponder) {
                [vc surfaceUpdated:YES];
            }
        }
    }
    return _flutterViewControllers.count;
}

#pragma mark - private methods
//启动 flutter 引擎
- (void)startupFlutterEngine {
    BOOL result = NO;
    if (NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
        // 多引擎启动，根据入口名
        result = [_flutterEngine runWithEntrypoint:_entrypoint];
    } else {
        // 单引擎启动
        result = [_flutterEngine run];
    }
    if (!result) {
        // 引擎启动失败，抛出异常
        @throw [NSException exceptionWithName:@"FlutterFailedException"
                                       reason:@"run flutter engine failed!"
                                     userInfo:nil];
    }
}

// 插件注册
- (void)registerPlugins {
    Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
    if (clazz) {
        if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                        withObject:_flutterEngine];
#pragma clang diagnostic pop
        }
    }
}

/**
 * 启动channel
 */
- (void)setupChannelWithReadyBlock:(ThrioIdCallback _Nullable)block {
    NSString *channelName = [NSString stringWithFormat:@"__thrio_app__%@", self.entrypoint];
    _channel = [ThrioChannel channelWithEngine:self name:channelName];
    // 设置Event Channel
    [_channel setupEventChannel];
    // 设置Method Channel
    [_channel setupMethodChannel];
    
    NSString *moduleContextChannelName =
    [NSString stringWithFormat:@"__thrio_module_context__%@", self.entrypoint];
    _moduleContextChannel = [ThrioChannel channelWithEngine:self name:moduleContextChannelName];
    // 设置Method Channel
    [_moduleContextChannel setupMethodChannel];
    
    // 接收channel
    _receiveChannel = [[NavigatorRouteReceiveChannel alloc] initWithChannel:_channel withReadyBlock:block];
    // 发送channel
    _sendChannel = [[NavigatorRouteSendChannel alloc] initWithChannel:_channel];
    
    // 路由channel
    channelName = [NSString stringWithFormat:@"__thrio_route_channel__%@", self.entrypoint];
    ThrioChannel *routeChannel = [ThrioChannel channelWithEngine:self name:channelName];
    [routeChannel setupMethodChannel];
    _routeChannel = [[NavigatorRouteObserverChannel alloc] initWithChannel:routeChannel];
    
    // 页面channel
    channelName = [NSString stringWithFormat:@"__thrio_page_channel__%@", self.entrypoint];
    ThrioChannel *pageChannel = [ThrioChannel channelWithEngine:self name:channelName];
    [pageChannel setupMethodChannel];
    _pageChannel = [[NavigatorPageObserverChannel alloc] initWithChannel:pageChannel];
}

- (void)dealloc {
    NavigatorVerbose(@"NavigatorFlutterEngine: dealloc %@", self);
}

- (void)destroyContext {
    if (_flutterEngine) {
        _flutterEngine.viewController = nil;
        [_flutterEngine destroyContext];
        _flutterEngine = nil;
    }
}

@end

NS_ASSUME_NONNULL_END
