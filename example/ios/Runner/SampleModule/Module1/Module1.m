//
//  Module1.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import "Module1.h"
#import <UIKit/UIKit.h>

@implementation Module1

- (void)onPageBuilderRegister:(ThrioModuleContext *)moduleContext {
    [self registerPageBuilder:^UIViewController *_Nullable (id params) {
        ThrioLogI(@"/biz1/native1 pushed params: %@", params);
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];
    } forUrl:@"/biz1/native1"];
}

- (void)onPageObserverRegister:(ThrioModuleContext *)moduleContext {
    [self registerPageObserver:self];
}

- (void)onRouteObserverRegister:(ThrioModuleContext *)moduleContext {
    [self registerRouteObserver:self];
}

- (void)didPop:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>didPop == 1  %@",routeSettings.url);
}

- (void)didPopTo:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>didPopTo == 1  %@",routeSettings.url);
}

- (void)didPush:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>didPush == 1  %@",routeSettings.url);
}

- (void)didRemove:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>didRemove == 1  %@",routeSettings.url);
}

- (void)willAppear:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>willAppear == 1  %@",routeSettings.url);
}

- (void)didAppear:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>didAppear == 1  %@",routeSettings.url);
}

- (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>willDisappear == 1  %@",routeSettings.url);
}

- (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
    NSLog(@"====>>>didDisappear == 1  %@",routeSettings.url);
}

@end
