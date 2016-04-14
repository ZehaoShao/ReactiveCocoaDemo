//
//  personModel.m
//  RACDemo_OC
//
//  Created by shaozehao on 16/4/13.
//  Copyright © 2016年 shaozehao. All rights reserved.
//

#import "personModel.h"

@implementation personModel
+(personModel*)flagWithDict:(NSDictionary*)dict{
    personModel *model = [[personModel alloc]init ];
    NSDictionary *dic = dict;
    model.name = dic[@"name"];
    model.age = dic[@"age"];
    return model;
    
}
@end
