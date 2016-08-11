////
////  ViewController.m
////  YX_WebViewStudy
////
////  Created by yang on 16/8/9.
////  Copyright © 2016年 poplary. All rights reserved.

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic)UIWebView *webView;
@property (nonatomic)JSContext *jsContext;
@property (nonnull,strong) UIButton *btn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:_webView];
    NSString *str = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:str]]];
    //    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.59:8020/Online-Booking/index.html"]]];
    
    //  在上面添加一个按钮，实现oc端控制h5实现弹alert方法框
    self.btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 400, 100, 40)];
    self.btn.backgroundColor = [UIColor redColor];
    [self.btn addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn];
    
    
}
- (void)showAlert
{
    //要将script的alert()方法转化为string类型
    NSString *alertJs=@"alert('Hello Word')";
    [_jsContext evaluateScript:alertJs];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _jsContext[@"startFunction"] =^(id obj){
        ////这里通过block回调从而获得h5传来的json数据
        /*block中捕获JSContexts
         我们知道block会默认强引用它所捕获的对象，如下代码所示，如果block中直接使用context也会造成循环引用，这使用我们最好采用[JSContext currentContext]来获取当前的JSContext:
         */
        [JSContext currentContext];
        NSData *data = [(NSString *)obj dataUsingEncoding:NSUTF8StringEncoding ];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@" data   %@   ======  ShareUrl %@",obj,dict[@"shareUrl"]);
    };
    //
    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        //比如把js中的方法名改掉，OC找不到相应方法，这里就会打印异常信息
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
