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

#import "NavigatorConsts.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorFlutterViewController.h"
#import "NavigatorNavigationController.h"
#import "ThrioModule+PageBuilders.h"
#import "ThrioModule+private.h"
#import "FlutterThrioTypes.h"
#import "UIViewController+Internal.h"
#import "UIViewController+Navigator.h"
#import "UIViewController+ThrioInjection.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorNavigationController ()

@property (nonatomic) NSString *initialUrl;
@property (nonatomic, nullable) id initialParams;

@end

@implementation NavigatorNavigationController
// 引擎初始化
- (instancetype)initWithUrl:(NSString *)url params:(id _Nullable)params {
    // 初始化的时候，要初始化加载的page url
    _initialUrl = url;
    // 初始化页面携带的参数
    _initialParams = params;
    UIViewController *viewController;
    //根据url获取是否有注册Native VC
    NavigatorPageBuilder builder = [ThrioModule pageBuilders][url];
    if (builder) {
        // 拿到native VC
        viewController = builder(params);
        // 设置导航栏掩藏状态为NO
        if (viewController.thrio_hidesNavigationBar_ == nil) {
            viewController.thrio_hidesNavigationBar_ = @NO;
        }
    }
    // 初始化的不是原生页面
    if (!viewController) {
        NSString *entrypoint = kNavigatorDefaultEntrypoint;
        // 如果启用了多引擎
        if (NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
            // 引擎名使用传入url的第二个：例如 a/b/c 这样处理后，引擎名就是b
            entrypoint = [url componentsSeparatedByString:@"/"][1];
        }
        __weak typeof(self) weakself = self;
        __block ThrioEngineReadyCallback readyBlock = ^(NavigatorFlutterEngine *engine) {
            __strong typeof(weakself) strongSelf = weakself;
            // 初始化准备完成后，push到initialUrl页面
            [strongSelf.topViewController thrio_pushUrl:strongSelf.initialUrl
                                                  index:@1
                                                 params:strongSelf.initialParams
                                               animated:NO
                                         fromEntrypoint:entrypoint
                                                 result:nil
                                                fromURL:nil
                                                prevURL:nil
                                               innerURL:nil
                                           poppedResult:nil];
        };
        
        NavigatorFlutterEngine *engine =
        [ThrioModule.rootModule startupFlutterEngineWithEntrypoint:entrypoint readyBlock:readyBlock];
        // 承载 flutter 的 VC
        NavigatorFlutterPageBuilder flutterBuilder = [ThrioModule flutterPageBuilder];
        if (flutterBuilder) {
            // 如果注册了 flutter VC,则使用flutter VC
            viewController = flutterBuilder(engine);
        } else {
            //内部初始化一个默认的 NavigatorFlutterViewController
            viewController = [[NavigatorFlutterViewController alloc] initWithEngine:engine];
        }
    } else {
        // 初始化的是native页面
        __weak typeof(self) weakSelf = self;
        [viewController registerInjectionBlock:^(UIViewController *vc, BOOL animated) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!vc.thrio_lastRoute) {
                [vc thrio_pushUrl:strongSelf.initialUrl
                            index:@1
                           params:strongSelf.initialParams
                         animated:NO
                   fromEntrypoint:nil
                           result:nil
                          fromURL:nil
                          prevURL:nil
                         innerURL:nil
                     poppedResult:nil];
            }
        } afterLifecycle:ThrioViewControllerLifecycleViewDidAppear];
    }
    // 将VC作为根VC
    return [super initWithRootViewController:viewController];
}

//确定视图控制器是否支持自动旋转
- (BOOL)shouldAutorotate {
    return [self.viewControllers.lastObject shouldAutorotate];
}
//指定视图控制器支持的界面方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}
//指定视图控制器在呈现时的首选界面方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

@end

NS_ASSUME_NONNULL_END
