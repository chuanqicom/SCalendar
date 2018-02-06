//
//  APCalendarView.m
//  APReport
//
//  Created by 维信金科 on 2018/1/30.
//  Copyright © 2018年 Shanghai Aopai Data Technology Co., Ltd. All rights reserved.
//

#import "APCalendarView.h"
//#import "XMCalendarCell.h"
#import "APCalendarSunCell.h"
#import "XMCalendarDataSource.h"
#import "XMCalendarManager.h"
#import "XMCalendarTool.h"

@interface APCalendarView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *popView;
@property (weak, nonatomic) IBOutlet UIView *topV;

@property (weak, nonatomic) IBOutlet UILabel *year_MonthL;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) XMCalendarDataSource *dataSourceModel;
@property (nonatomic, strong) XMCalendarManager *calendarManager;

/**
 *  今天 / 昨天 / 近7天 / 近30天 / 其他
 */
@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
@property (weak, nonatomic) IBOutlet UIButton *yesterdayBtn;
@property (weak, nonatomic) IBOutlet UIButton *weekBtn;
@property (weak, nonatomic) IBOutlet UIButton *monthBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherBtn;
@property (weak, nonatomic) IBOutlet UIView *line;

// 关闭 / 确认
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

// 缓存 日期起点 / 终点
@property (nonatomic, strong)NSDate *startD;
@property (nonatomic, strong) NSDate *endD;
@property (nonatomic, assign) DayType type;
@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, strong) XMCalendarTool *tool;

@end

@implementation APCalendarView

- (instancetype)initWithFrame:(CGRect)frame dateType:(NSString *)dateType startStr:(NSString *)startStr endStr:(NSString *)endStr {
    if (self = [super initWithFrame:frame]) {
        
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        self.frame = frame;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.63];
        self.popView.backgroundColor = [UIColor clearColor];

        self.dataSourceModel = [self.calendarManager currentMonth];
        self.year_MonthL.text = self.dataSourceModel.topTitle;
        self.type = [self toChangeDateType:dateType];
        self.startD = [XMCalendarTool toDateWithString:startStr];
        self.endD = [XMCalendarTool toDateWithString:endStr];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"APCalendarSunCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"APCalendarSunCell"];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.collectionViewLayout = self.layout;
        
        // 设置默认 起点 (查询近7天)
        switch (_type) {
            case dayType_Today:
                {
                    [self calendarAction:self.todayBtn];
                }
                break;
            case dayType_Yesterday:
                {
                    [self calendarAction:self.yesterdayBtn];
                }
                break;
            case dayType_7Days:
                {
                    [self calendarAction:self.weekBtn];
                }
                break;
            case dayType_30Days:
                {
                    [self calendarAction:self.monthBtn];
                }
                break;
            case dayType_OtherDays:
                {
                    [self calendarAction:self.otherBtn];
                }
                break;
        }
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.tool = [[XMCalendarTool alloc] init];

}

- (DayType)toChangeDateType:(NSString *)str
{
    if (str) {
        switch (str.intValue) {
            case 0:
            {
                return dayType_Today;
            }
            case -1:
            {
                return dayType_Yesterday;
            }
            case -7:
            {
                return dayType_7Days;
            }
            case -30:
            {
                return dayType_30Days;
            }
                
            default:
            {
                return dayType_OtherDays;
            }
        }
        
    }else{
        return dayType_7Days;
    }
}

#pragma mark - CollectionView的代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XMCalendarModel *model = self.dataSourceModel.dataSource[indexPath.row];

    APCalendarSunCell *cell = [APCalendarSunCell sunCellWithCalendarModel:model collectionView:collectionView indexpath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (dayType_OtherDays != _type) {
        _type = dayType_OtherDays;
        [self calendarAction:self.otherBtn];
    }
    
    XMCalendarModel *model = self.dataSourceModel.dataSource[indexPath.row];
    // 起点和终点都有值
    if (self.startD && self.endD) {
        [self resetCaleder];
        if ([self.endD isEqualToDate:self.startD]) {
            self.startD = model.date.copy;
            model.isTapPoint = YES;
        }else{
            self.startD = nil;
            self.endD = nil;
        }
        
        [self.collectionView reloadData];
        return;
        
    }else{
        
        if (self.startD) {
            self.endD = model.date.copy;
        }else if (self.endD) {
            self.startD = model.date.copy;
        }else {
            // 无起点,无终点
            self.startD = model.date.copy;
            model.isTapPoint = YES;
            [self.collectionView reloadData];
            return;
        }
        
        [self dateSort];
    }
   
    // 判断 起点和终点 间隔
    NSInteger days = [XMCalendarTool daysWithStart:self.startD end:self.endD];
    NSLog(@"两个日期相隔days = %zd",days);
    switch (days) {
        case 0:
        {
            BOOL isY = [XMCalendarTool isYesterdayWithDate:self.startD];
            if (isY) {
                // 昨天
            }else{
                // 今天
            }
        }
            break;
        case 7:
        {
            // 一周
        }
            break;
        case 30:
        {
            // 30天
        }
            break;
     
        default:
            break;
    }
    
    [self resetUI];
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(xmCalendarSelectDate:)]) {
        [self.delegate xmCalendarSelectDate:model.date];
    }
    if ([self.delegate respondsToSelector:@selector(xmCalendarSelectCalendarModel:)]) {
        [self.delegate xmCalendarSelectCalendarModel:model];
    }

    _arr = @[[XMCalendarTool toStringWithDate:self.startD],[XMCalendarTool toStringWithDate:self.endD]];
}

/// MARK: 复位
- (void)resetCaleder
{
    for (XMCalendarModel *model in self.dataSourceModel.dataSource) {
        model.isTapPoint = NO;
        model.isInterval = NO;
    }
}

/// MARK: 跨月 中间月份的设置
- (void)kuayueCaleder
{
    for (XMCalendarModel *model in self.dataSourceModel.dataSource) {
        model.isTapPoint = NO;
        model.isInterval = YES;
    }
}


/**
 *  startDate 和 endDate 都有值得情况下 刷新UI
 */
- (void)resetUI
{
    XMCalendarModel *startM = nil;
    XMCalendarModel *endM = nil;
    NSInteger startIndex = -1;
    NSInteger endIndex = self.dataSourceModel.dataSource.count;
    NSDate *lastDate = nil;
    NSDate *firstDate = nil;
    
    for (int i = 0; i < self.dataSourceModel.dataSource.count; i++) {
        XMCalendarModel *model = self.dataSourceModel.dataSource[i];
        if (model.date) {
            firstDate = model.date;
        }
        
        if (firstDate && !model.date) {
            lastDate = self.dataSourceModel.dataSource[i-1].date;
            break;
        }
    }
    
    for (XMCalendarModel *model in self.dataSourceModel.dataSource) {
        if ([self.startD isEqualToDate:model.date]) {
            startM = model;
        }
        if ([self.endD isEqualToDate:model.date]) {
            endM = model;
        }
    }

    if (startM && endM) {
        // 当前月
        startIndex = [self.dataSourceModel.dataSource indexOfObject:startM];
        endIndex = [self.dataSourceModel.dataSource indexOfObject:endM];
        
    }else{
        // 跨月
        if (startM) {
            startIndex = [self.dataSourceModel.dataSource indexOfObject:startM];
        }
        
        if (endM) {
            endIndex = [self.dataSourceModel.dataSource indexOfObject:endM];
        }
    }
    
    if (!startM && !endM) {
        NSTimeInterval firetTime = [firstDate timeIntervalSinceDate:self.startD];
        NSTimeInterval lastTime = [self.endD timeIntervalSinceDate:lastDate];

        if (firetTime > 0 && lastTime > 0) {
            [self kuayueCaleder];
        }else{
            [self resetCaleder];
        }
        
        [self.collectionView reloadData];
        return;
    }
    
    [self resetStartIndex:startIndex andEndIndex:endIndex];
    [self.collectionView reloadData];
}

/**
 *  重置起点和终点的位置
 */
- (void)dateSort
{
    NSComparisonResult result = [self.startD compare:self.endD];
    if (NSOrderedDescending == result) {
        NSDate *tempD = self.endD.copy;
        self.endD = self.startD;
        self.startD = tempD;
    }
}

- (void)resetStartIndex:(NSInteger)startIndex andEndIndex:(NSInteger)endIndex
{
    for (int i = 0; i< self.dataSourceModel.dataSource.count; i++) {
        XMCalendarModel *model = self.dataSourceModel.dataSource[i];
        
        model.isInterval = NO;
        model.isTapPoint = NO;
        
        if (startIndex < i && i < endIndex) {
            model.isInterval = YES;
        }else{
            if (i == endIndex && model.date) {
                model.isTapPoint = YES;
            }else if (i == startIndex && model.date){
                model.isTapPoint = YES;
            }
        }
    }
}

- (void)startOrEnd:(NSDate *)date
{
    for (XMCalendarModel *model in self.dataSourceModel.dataSource) {
        if ([model.date isEqualToDate:date]) {
            model.isTapPoint = YES;
        }else{
            model.isTapPoint = NO;
        }
    }
}

- (void)monthChange
{
    if (self.startD && self.endD) {
        [self resetUI];
    }else{
        if (self.startD) {
            [self startOrEnd:self.startD];
        }else if (self.endD){
            [self startOrEnd:self.endD];
        }
    }
}

- (IBAction)preMonth:(UIButton *)sender {
    self.dataSourceModel = [self.calendarManager preMonth];
    [self monthChange];
    [self.collectionView reloadData];
    self.year_MonthL.text = self.dataSourceModel.topTitle;
}

- (IBAction)nextMonth:(id)sender {
    self.dataSourceModel = [self.calendarManager nextMonth];
    [self monthChange];
    [self.collectionView reloadData];
    self.year_MonthL.text = self.dataSourceModel.topTitle;
}

/**
 *  关闭 / 确认
 */
- (IBAction)calendarAction:(UIButton *)sender {
    
    NSInteger tags = sender.tag; // 1006:close , 1007:ok

    switch (tags) {
        case 1001:
        {
            // 今天(默认)
            _type = dayType_Today;
            _arr = @[@"0"];
            self.startD = [self.calendarManager currentDayDate];
            self.endD = self.startD;
        }
            break;
        case 1002:
        {
            // 昨天
            _type = dayType_Yesterday;
            _arr = @[@"-1"];
            self.startD = [self.tool getForeDays:-1];
            self.endD = self.startD;
        }
            break;
        case 1003:
        {
            // 近7天
            _type = dayType_7Days;
            _arr = @[@"-7"];
            self.startD = [self.tool getForeDays:-7];
            self.endD = [self.calendarManager currentDayDate];
        }
            break;
        case 1004:
        {
            // 近30天
            _type = dayType_30Days;
            _arr = @[@"-30"];
            self.startD = [self.tool getForeDays:-30];
            self.endD = [self.calendarManager currentDayDate];
        }
            break;
        case 1005:
        {
            // 其他 开始时间和结束时间必须有值
            _type = dayType_OtherDays;
        }
            break;
        case 1006:
        {
            // 关闭
            [self removeFromSuperview];
        }
            break;
        case 1007:
        {
            if (!(self.startD && self.endD) && dayType_OtherDays == _type) {
                return NSLog(@"请选择日期");
            }
            
            // 确认
            if ([self.delegate respondsToSelector:@selector(xmCalendar:data:)]) {
                [self.delegate xmCalendar:_type data:_arr];
                [self removeFromSuperview];
            }
        }
            break;
        default:
            break;
    }
    
    if (sender.tag != 1006 && sender.tag != 1007) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                CGPoint lineCenter = CGPointMake(sender.center.x, self.line.center.y);
                self.line.center = lineCenter;
                [self resetUI];
            }];
        });
    }
}

#pragma mark - getter & setter
- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        _layout.itemSize = CGSizeMake(self.bounds.size.width/7.0, 53);
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _layout;
}

- (XMCalendarManager *)calendarManager {
    if (!_calendarManager) {
        _calendarManager = [[XMCalendarManager alloc] init];
    }
    return _calendarManager;
}

@end
