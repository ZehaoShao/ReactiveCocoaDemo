//
//  personModel.h
//  RACDemo_OC
//
//  Created by shaozehao on 16/4/13.
//  Copyright © 2016年 shaozehao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface personModel : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *age;

+(personModel*)flagWithDict:(NSDictionary*)dict;
@end
