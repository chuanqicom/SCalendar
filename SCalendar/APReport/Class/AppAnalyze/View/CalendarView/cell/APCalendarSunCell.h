//
//  APCalendarSunCell.h
//  APReport
//
//  Created by 维信金科 on 2018/1/31.
//  Copyright © 2018年 Shanghai Aopai Data Technology Co., Ltd. All rights reserved.
//
/// ========  带有阴历的cell ==============

#import <UIKit/UIKit.h>
#import "XMCalendarModel.h"

@interface APCalendarSunCell : UICollectionViewCell

@property (nonatomic, strong) XMCalendarModel *model;

+ (instancetype)sunCellWithCalendarModel:(XMCalendarModel *)model collectionView:(UICollectionView *)collectionVeiw indexpath:(NSIndexPath *)indexPath;

@end
