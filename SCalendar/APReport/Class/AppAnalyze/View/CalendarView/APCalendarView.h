//
//  APCalendarView.h
//  APReport
//
//  Created by 维信金科 on 2018/1/30.
//  Copyright © 2018年 Shanghai Aopai Data Technology Co., Ltd. All rights reserved.
//
/// ==========  ** 日历 ** ============

#import <UIKit/UIKit.h>
#import "XMCalendarDataSource.h"

typedef NS_ENUM(NSInteger, DayType) {
    dayType_7Days, // 默认值
    dayType_Today,
    dayType_Yesterday,
    dayType_30Days,
    dayType_OtherDays,
};

@protocol XMCalendarViewDelegate <NSObject>
@optional
- (void)xmCalendarSelectDate:(NSDate *)date;
- (void)xmCalendarSelectCalendarModel:(XMCalendarModel *)calendarModel;
- (void)xmCalendar:(DayType)dayType data:(NSArray *)dataArray;

@end

@interface APCalendarView : UIView

@property (nonatomic, weak)id<XMCalendarViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame dateType:(NSString *)dateType startStr:(NSString *)startStr endStr:(NSString *)endStr;

@end
