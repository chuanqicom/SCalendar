//
//  APCalendarSunCell.m
//  APReport
//
//  Created by 维信金科 on 2018/1/31.
//  Copyright © 2018年 Shanghai Aopai Data Technology Co., Ltd. All rights reserved.
//

#import "APCalendarSunCell.h"

@interface APCalendarSunCell ()
@property (weak, nonatomic) IBOutlet UILabel *sunL;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation APCalendarSunCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)sunCellWithCalendarModel:(XMCalendarModel *)model collectionView:(UICollectionView *)collectionVeiw indexpath:(NSIndexPath *)indexPath{
    static NSString *ID = @"APCalendarSunCell";
    APCalendarSunCell *cell = [collectionVeiw dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.model = model;
    return cell;
}

- (void)setModel:(XMCalendarModel *)model {
    
    self.bgView.hidden = YES;
    
    if (model.isEmpty) {
        self.sunL.hidden = YES;
        self.userInteractionEnabled = NO;
    } else {
        self.sunL.hidden = NO;
        self.userInteractionEnabled = YES;
        self.sunL.text = [NSString stringWithFormat:@"%zd",model.dateNumber];
        
        // 设置 选中日期的颜色
        if (model.isTapPoint) {
            self.bgView.hidden = NO;
            self.bgView.backgroundColor = [UIColor greenColor];
        }
        
        if (model.isInterval) {
            self.bgView.hidden = NO;
            self.bgView.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

@end
