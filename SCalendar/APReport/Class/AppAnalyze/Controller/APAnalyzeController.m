//
//  APAnalyzeController.m
//  APReport
//
//  Created by 维信金科 on 2018/1/29.
//  Copyright © 2018年 Shanghai Aopai Data Technology Co., Ltd. All rights reserved.
//

#import "APAnalyzeController.h"
#import "APCalendarView.h"

@interface APAnalyzeController ()<XMCalendarViewDelegate>

@end

@implementation APAnalyzeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"查看日历" forState:UIControlStateNormal];
    [button sizeToFit];
    button.center = self.view.center;
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)buttonAction
{
    // 弹出日历选择框 (添加在当前View上)
    APCalendarView *calender = [[APCalendarView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.bounds dateType:@"-7" startStr:nil endStr:nil];
    calender.delegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:calender];
}

#pragma mark - <XMCalendarViewDelegate>
- (void)xmCalendar:(DayType)dayType data:(NSArray *)dataArray
{
    switch (dayType) {
        case dayType_Today:
        case dayType_Yesterday:
        case dayType_7Days:
        case dayType_30Days:
            {
                
            }
            break;
        case dayType_OtherDays:
            {
             
            }
            break;
    }
    
    /// TODO:
    NSLog(@"%@",dataArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
