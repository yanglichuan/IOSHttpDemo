//
//  HMViewController.m
//  01-基本的HTTP请求
//
//  Created by apple on 14-9-18.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMViewController.h"
#import "MBProgressHUD+MJ.h"

@interface HMViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
- (IBAction)login;
@end

@implementation HMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)login {
    // 1.用户名
    NSString *usernameText = self.username.text;
    if (usernameText.length == 0) {
        [MBProgressHUD showError:@"请输入用户名"];
        return;
    }
    
    // 2.密码
    NSString *pwdText = self.pwd.text;
    if (pwdText.length == 0) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    
    /**
     接口文档：定义描述服务器端的请求接口
     1> 请求路径URL：客户端应该请求哪个路径  
     * http://localhost:8080/MJServer/login
     
     2> 请求参数：客户端要发给服务器的数据
     * username - 用户名
     * pwd - 密码
     
     3> 请求结果：服务器会返回什么东西给客户端
     */
    
    // 3.发送用户名和密码给服务器(走HTTP协议)
    // 创建一个URL ： 请求路径
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost:8080/MJServer/login?username=%@&pwd=%@",usernameText, pwdText];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 创建一个请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 发送一个同步请求(在主线程发送请求)
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSLog(@"%@", data);
}
@end
