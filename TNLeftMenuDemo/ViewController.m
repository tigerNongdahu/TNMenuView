//
//  ViewController.m
//  TNLeftMenuDemo
//
//  Created by TigerNong on 2018/4/13.
//  Copyright © 2018年 TigerNong. All rights reserved.
//

#import "ViewController.h"
#import "XWSLeftView.h"
#import "XWSRightView.h"
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<XWSLeftViewDelegate,XWSRightViewDelegate>
@property (nonatomic, strong) XWSLeftView *leftView;
@property (nonatomic, strong) XWSRightView *rightView;
@property (nonatomic, strong) NSMutableArray *screens;
@end

@implementation ViewController

- (NSMutableArray *)screens{
    if (!_screens) {
        _screens = [NSMutableArray  array];
    }
    return _screens;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self setUpLeftMenuView];
    [self setUpRightMenuView];
}

- (void)setUpLeftMenuView{
    //获取到的个人信息
    NSString *account = @"test";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"account"] = account;
    dic[@"icon"] = @"left_setting";
    
    if (!_leftView) {
        _leftView = [[XWSLeftView alloc] initWithFrame:CGRectZero withUserInfo:dic];
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor clearColor];
        
        [[UIApplication sharedApplication].keyWindow addSubview:_leftView];
        _leftView.delegate = self;
        _leftView.hidden = YES;
        [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.mas_equalTo(0);
            make.left.mas_equalTo(-ScreenWidth);
            make.width.mas_equalTo(ScreenWidth);
        }];
    }
}


- (IBAction)showLeftMenuView:(id)sender {
    self.leftView.hidden = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
        }];
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    //设置颜色渐变动画
    [self.leftView startCoverViewOpacityWithAlpha:0.5 withDuration:0.35];
    
}

//收回左侧侧边栏
- (void)hideLeftMenuView{
    [self.leftView cancelCoverViewOpacity];
    [UIView animateWithDuration:0.35 animations:^{
        [self.leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(-ScreenWidth);
        }];
        
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
        
    }completion:^(BOOL finished) {
        self.leftView.hidden = YES;
    }];
}

#pragma mark - XWSLeftViewDelegate
- (void)touchLeftView:(XWSLeftView *)leftView byType:(XWSTouchItem)type{
    
    [self hideLeftMenuView];
    
    UIViewController *vc = nil;
    
    switch (type) {
        case XWSTouchItemUserInfo:
        {
            
        }
            break;
        case XWSTouchItemDevicesList:
        {
            
        }
            break;
        case XWSTouchItemAlarm:
        {
            
        }
            break;
        case XWSTouchItemStatistics:
        {
            
        }
            break;
        case XWSTouchItemFeedback:
        {
            
        }
            break;
        case XWSTouchItemHelp:
        {
            
        }
            break;
        case XWSTouchItemScan:
        {
            
        }
            break;
        case XWSTouchItemSetting:
        {
           
            
        }
            break;
            
        default:
            break;
    }
    
    if (vc == nil) {
        return;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 设置右边侧边栏
- (void)setUpRightMenuView{
    
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"json"]];
    
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    [self.screens removeAllObjects];
    [self.screens addObjectsFromArray:dataArray];
    
    if (!_rightView) {
        _rightView = [[XWSRightView alloc] initWithFrame:CGRectZero];
        _rightView.delegate = self;
        _rightView.hidden = YES;
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_rightView];
        [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(ScreenWidth);
        }];
    }
}

- (IBAction)showRightMenuView:(id)sender {
    _rightView.datas = self.screens;
    _rightView.hidden = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(-ScreenWidth);
        }];
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    //设置颜色渐变动画
    [_rightView startCoverViewOpacityWithAlpha:0.5 withDuration:0.35];
}

- (void)hideRightMenuView{
    
    //把盖板颜色的alpha值至为0
    [_rightView cancelCoverViewOpacity];
    
    //移动侧边栏回到原来的位置
    [UIView animateWithDuration:0.35 animations:^{
        [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(ScreenWidth);
        }];
        
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
        
    }completion:^(BOOL finished) {
        self.rightView.hidden = YES;
    }];
}

#pragma mark - XWSRightViewDelegate
- (void)clickRightView:(XWSRightView *)rightView getLeftText:(NSString *)leftText getRightText:(NSString *)rightText{
    NSLog(@"leftText:%@ rightText:%@",leftText,rightText);
    [self hideRightMenuView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
