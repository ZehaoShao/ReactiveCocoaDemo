//
//  SHViewController.m
//  RACDemo_OC
//
//  Created by shaozehao on 16/4/5.
//  Copyright © 2016年 shaozehao. All rights reserved.
//

//http://www.cocoachina.com/ios/20160330/15823.html

//http://blog.leichunfeng.com/blog/2015/12/25/reactivecocoa-v2-dot-5-yuan-ma-jie-xi-zhi-jia-gou-zong-lan/

//http://benbeng.leanote.com/post/ReactiveCocoaTutorial-part1

//http://limboy.me/ios/2013/06/19/frp-reactivecocoa.html

//http://blog.csdn.net/xdrt81y/article/details/30624469

//http://limboy.me/image/FRP_ReactiveCocoa_large.png

//http://www.jianshu.com/p/87ef6720a096

/**可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的不会出现并发情况)。水龙头的开关认是关的，除非有了接收方(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给接收方。可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，也可以加一个改动装置，把球改变成符合自己的需求(map)。也可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球
 
 接收方(subscriber)
 next 从水龙头里流出的新玻璃球（value）
 error 获取新的玻璃球发生了错误，一般要发送一个NSError对象，表明哪里错了
 completed 全部玻璃球已经顺利抵达，没有更多的玻璃球加入了
 
 一个生命周期的Signal可以发送任意多个“next”事件，和一个“error”或者“completed”事件（当然“error”和“completed”只可能出现一种）
 

 */


#import "SHViewController.h"
#import "ReactiveCocoa.h"
#import "OneViewController.h"
#import "personModel.h"
@interface SHViewController ()
@property (weak, nonatomic) IBOutlet UIButton *mBtn;
@property (weak, nonatomic) IBOutlet UITextField *mField;
@property (weak, nonatomic) IBOutlet UITextField *mField1;
@property (copy, nonatomic) NSString *userName;
@property (weak, nonatomic) IBOutlet UIView *mView;

@end

@implementation SHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self createSignal];
//    [self createSubject];
//    [self createReplaySubject];
//    [self createCommond];
//    [self createConnection];
    
//    [self rac_tFliedMethod];
//    
    [self rac_btnMethod];
    [self btnClick];
//    
//    [self rac_notify];
//    
//    [self rac_kvo];
//    
//    [self rac_arr];
//    [self rac_model];
    
    
    
 //   @weakify(self)
 //   @strongify(self)
    
    
}


-(void)createSignal{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        [subscriber sendNext:@"1"];
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            
            NSLog(@"信号被销毁~");
        }];
    }];
    
    // 3.订阅信号,才会激活信号.
    [signal subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"createSignal x = %@",x);
    } completed:^{
        NSLog(@"信号完成 ");
    }];
    
}

/**
    RACSubject
    RACSubject使用步骤
    1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    3.发送信号 sendNext:(id)value
 
    RACSubject:底层实现和RACSignal不一样。
    1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
 */

-(void)createSubject{
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者 %@",x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者 %@",x);
    }];
    
     [subject sendNext:@"1"];
}


//通过自定义信号，也就是RACSubject(继承自RACSignal，可以理解为自由度更高的signal)来搞定。比如一个异步网络操作，可以返回一个subject，然后将这个subject绑定到一个subscriber或另一个信号
-(void)rac_subject{
    RACSubject *subject = [self doRequest];
    [subject subscribeNext:^(id x) {
        NSLog(@"rac_subject  %@",x);
    }];
    
    
    
}
-(RACSubject*)doRequest{
    RACSubject *subject = [RACSubject subject];
    // 模拟2秒后得到请求内容
    // 只触发1次
    // 尽管subscribeNext什么也没做，但如果没有的话map是不会执行的
    
    // subscribeNext就是定义了一个接收体
    
    [[[[RACSignal interval:2] take:1] map:^id(id _) {
        NSString *value = @"content fetched from web";
        [subject sendNext:value];
        return nil;
    }]subscribeNext:^(id x) {
        
    }];
    return subject;
}

-(void)rac_liftSignals{
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送请2"];
        return nil;
    }];

    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
    
}

- (void)updateUIWithR1:(id)data1 r2:(id)data2{
    NSLog(@"更新   %@ ,%@",data1,data2);
}





/**
    RACReplaySubject
    RACReplaySubject使用步骤:
    1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    2.可以先订阅信号，也可以先发送信号。
    2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    2.2 发送信号 sendNext:(id)value
 
    RACReplaySubject:底层实现和RACSubject不一样。
    1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
 
    如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    也就是先保存值，在订阅值。
 */


-(void)createReplaySubject{
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    [replaySubject sendNext:@"1"];
    [replaySubject sendNext:@"2"];
    
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"replaySubject 第一个订阅者 %@",x);
    }];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"replaySubject  第二个订阅者 %@",x);
    }];
}

-(void)createCommond{
    // 一、RACCommand使用步骤:
    // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
    // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
    // 3.执行命令 - (RACSignal *)execute:(id)input
    RACCommand *commond = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
      //  return [RACSignal empty];//不能返回nil
      
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"请求数据"];
            
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            return nil;
        }];
        
        
    } ];
    [commond.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
    }];
    
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [commond.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"============ x = %@",x);
    }];
    
    
    
     //.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[commond.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue]) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"执行完成");
        }
    }];
    
    
    
    [commond execute:@"1"];
    
  
}

//RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理
//RACMulticastConnection通过RACSignal的-publish或者-muticast:方法创建.
-(void)createConnection{
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
       [subscriber sendNext:@"1"];
        return nil;
    }];
    
    
    
    // RACMulticastConnection:解决重复请求问题
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    RACMulticastConnection *connect = [signal publish];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"接受数据");
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"接受数据");
    }];
    
    //连接 激活信号
    [connect connect];
    
    //connect 未建立 运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    
    
    
}

























-(void)rac_tFliedMethod{
    [[self.mField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(id x) {
        NSLog(@"changge ");
        UITextField *field = x ;
        NSLog(@"    : UIControlEventEditingChanged   text   %@",field.text);
    }];
    
    
    
    /**
     
     UIControlEventEditingDidBegin                                   = 1 << 16,     // UITextField
     UIControlEventEditingChanged                                    = 1 << 17,
     UIControlEventEditingDidEnd                                     = 1 << 18,
     UIControlEventEditingDidEndOnExit                               = 1 << 19,     // 'return key' ending editing
     */
    
    [[self.mField rac_textSignal] subscribeNext:^(id x) {
       NSLog(@"signal : rac_textSignal       %@",x);
    }];
    
    
    
//    [[self.mField rac_textSignal] subscribeNext:^(id x) {
//    } completed:^{
//        NSLog(@"signal : completed  block ");
//
//    }];
    
    
    [[[self.mField rac_textSignal] filter:^BOOL(id value) {
        NSString *text = value;
        return text.length < 5;
    }]subscribeNext:^(id x) {
        NSLog(@"text.lenght<5  x= %@",x);
    }];
    
// -map: 映射，可以看做对玻璃球的变换、重新组装
    
     [[[self.mField.rac_textSignal map:^id(id value) {
              NSString * text = value;
             return @(text.length);      //map从上一个next事件接收数据，通过执行block把返回值传给下一个next事件
     }] filter:^BOOL(NSNumber* length) {
             return  [length integerValue]>5;
      }] subscribeNext:^(id x) {
             NSLog(@"      %@",x);//@()返回NSNumber 类型的数据
      }];
    

    [[RACSignal combineLatest:@[self.mField.rac_textSignal,self.mField1.rac_textSignal] reduce:^(NSString *text1,NSString * text2){
        return @(text1.length >2 && text2.length >2);
    }] subscribeNext:^(id x) {
        NSLog(@"rac_textField  combineLatest  %@",x);
    }];
    
    
    
    
}

-(void)rac_btnMethod{
    [[self.mBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"  btn  click ");
    }];
   // self.mBtn.rac_command
   // 需求：自定义redView,监听红色view中按钮点击
   // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
   // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
   // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
    [[self rac_signalForSelector:@selector(btnClick)]subscribeNext:^(id x) {
        NSLog(@"-----------------------------");
    }];
}
-(void)btnClick{
    NSLog(@"btnClick btnClick btnClick");
}


-(void)rac_notify{
    
    //RAC中的通知不需要remove observer，因为在rac_add方法中他已经写了remove
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"notify" object:nil]subscribeNext:^(NSNotification *notifytion) {
        NSLog(@"notifytion    @%@",notifytion);
    }];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:UIKeyboardWillShowNotification object:nil ] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    
}


-(void)rac_kvo{
    
    //observeValueForKeyPath:ofObject:change:context:
     RAC(self.mBtn,enabled) = [RACSignal combineLatest:@[self.mField.rac_textSignal,self.mField1.rac_textSignal] reduce:^(NSString *text1,NSString * text2){
        return @(text1.length >2 && text2.length >2);
    }];

    
    
    [[self.mView rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        NSLog(@"center 改变 ");
    }];
    
    
    
    
    [[RACSignal combineLatest:@[self.mField.rac_textSignal,self.mField1.rac_textSignal] reduce:^(NSString *text1,NSString * text2){
        return @(text1.length >2 && text2.length >2);
    }] subscribeNext:^(NSNumber * res) {
        if (res.boolValue) {
            NSLog(@" 发出请求  -- --- --  ");
        }
    }];


    
    [RACObserve(self.mField,text)subscribeNext:^(id x) {
        NSLog(@"rac_kvo    x   =  %@",x);
    }];
    
    
   [[ RACObserve(self, userName) filter:^BOOL(NSString* name) {
       return [name hasPrefix:@"a"];
    }]subscribeNext:^(NSString *newName) {
        NSLog(@"rac_kvo %@",newName);
    }];
    
    
    
}


//Subscription 接收 -subscribeNext: -subscribeError: -subscribeCompleted:
-(void)rac_arr{
    NSArray *arr = @[@"a",@"b",@"c",@"d",@"e"];
    [arr.rac_sequence.signal subscribeNext:^(id x) {
         NSLog(@"arr  x= %@",x );  //依次输出 A B C D…
    }];
    
    
    NSDictionary *dic =  @{@"name":@"a",@"age":@"20"};
    [dic.rac_sequence.signal subscribeNext:^(id x) {
        RACTupleUnpack(NSString*key1,NSString*value1) =x ;//RACTuple:元组类,类似NSArray,用来包装值.
        NSLog(@"============    key1 = %@ value1 = %@",key1,value1);
        
        
        NSString *key = x[0];
        NSString *Value =x[1];
        NSLog(@"key = %@ value = %@",key,Value);
        
    }];
    
    
    
    
    
    
    [[[arr.rac_sequence.signal map:^id(id value) {
        NSString *str =  value;
        return [str stringByAppendingString:str];
    }] filter:^BOOL(NSString* value) {
        return (value.intValue%2) == 0;
    }] subscribeNext:^(id x) {
        NSLog(@"string  = %@",x);
    }] ;
    
    //-concat: 把一个水管拼接到另一个水管之后
     NSArray *arr1 = @[@"a1",@"b1",@"c1",@"d1",@"e1"];
    [[arr.rac_sequence concat:arr1.rac_sequence].signal subscribeNext:^(id x) {
        NSLog(@"concar ..   %@",x);
    }];
    
    
   // Signals are merged （merge可以理解成把几个水管的龙头合并成一个，哪个水管中的玻璃球哪个先到先吐哪个玻璃球
    
    
    //Mapping and flattening    -flattenMap: 先 map 再 flatten
    
    
}

-(void)rac_model{
    NSArray * dicArr =@[@{@"name":@"1",@"age":@"20"},@{@"name":@"2",@"age":@"20"},@{@"name":@"3",@"age":@"20"},@{@"name":@"4",@"age":@"20"}];
   
    NSArray *arr = [[ dicArr.rac_sequence map:^id(id value) {
        return [personModel  flagWithDict:value];
    }] array];
    
    
    [arr.rac_sequence.signal subscribeNext:^(personModel* model) {
        NSLog(@"^_^ name = %@",model.name);;
    }];
    
    
}




- (IBAction)racDelegateBtnClick:(UIButton *)sender {
    OneViewController *oneVC = [[OneViewController alloc] initWithNibName:NSStringFromClass([OneViewController class]) bundle:nil];
    oneVC.delegateSignal = [RACSubject subject];
    [oneVC.delegateSignal subscribeNext:^(id x) {
        NSLog(@"点击了通知按钮.....");
    }];
    [self.navigationController pushViewController:oneVC animated:YES];
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
