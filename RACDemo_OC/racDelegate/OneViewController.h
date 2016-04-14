//
//  OneViewController.h
//  RACDemo_OC
//
//  Created by shaozehao on 16/4/13.
//  Copyright © 2016年 shaozehao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"
@interface OneViewController : UIViewController
@property (nonatomic,strong) RACSubject *delegateSignal;
@end
