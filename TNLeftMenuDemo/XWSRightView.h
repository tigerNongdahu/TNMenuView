//
//  XWSRightView.h
//  ElecSafely
//
//  Created by TigerNong on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

@class XWSRightView;

@protocol XWSRightViewDelegate <NSObject>
- (void)clickRightView:(XWSRightView *)rightView getLeftText:(NSString *)leftText getRightText:(NSString *)rightText;
@end

@interface XWSRightView : UIView
@property (nonatomic, weak) id<XWSRightViewDelegate> delegate;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) NSMutableArray *datas;

/*开启蒙版透明度动画*/
/**
 设置alpha值
 动画是时间 duration
 **/
- (void)startCoverViewOpacityWithAlpha:(CGFloat)alpha withDuration:(CGFloat)duration;
/*取消门板透明度动画*/
- (void)cancelCoverViewOpacity;

@end
