//
//  XWSRightView.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSRightView.h"
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define UIColorRGB(rgb) ([[UIColor alloc] initWithRed:(((rgb >> 16) & 0xff) / 255.0f) green:(((rgb >> 8) & 0xff) / 255.0f) blue:(((rgb) & 0xff) / 255.0f) alpha:1.0f])
#define DarkBack UIColorRGB(0x0e0f12)
#define NavColor UIColorRGB(0x191b27)
#define BackColor UIColorRGB(0x11121b)
#define rightBackColor NavColor
#define NavibarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)
#define IPHONE_X_WIDTH 375
#define IPHONE_X_HEIGHT 812
#define IS_IPHINE_X (ScreenWidth == IPHONE_X_WIDTH && ScreenHeight == IPHONE_X_HEIGHT)

#define leftMarginWidth 60.0
#define SureBtnTag 100
#define CloseBtnTag 101
#define LeftTableViewRowHeight 54.0
#define RightTableViewRowHeight LeftTableViewRowHeight

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface XWSRightView()<UITableViewDelegate,UITableViewDataSource>
/*左侧的数据表*/
@property (nonatomic, strong) UITableView *leftTableView;
/*右侧的数据表*/
@property (nonatomic, strong) UITableView *rightTableView;
/*自定义的导航栏*/
@property (nonatomic, strong) UIView *navView;
/*导航栏关闭按钮*/
@property (nonatomic, strong) UIButton *closeBtn;
/*导航栏确定按钮*/
@property (nonatomic, strong) UIButton *sureBtn;
/*导航栏标题*/
@property (nonatomic, strong) UILabel *titleLabel;

/*左侧显示数据数组*/
@property (nonatomic, strong) NSMutableArray *leftArr;
/*左侧当前选中的行*/
@property (nonatomic, assign) NSInteger selectLeftRow;
/*右侧当前选中的行*/
@property (nonatomic, assign) NSInteger selectRightRow;
/*左侧当前选中的行的标题，这个以后可以根据传值的需要进行修改，可以改成模型或者基本数据类型*/
@property (nonatomic, copy) NSString *leftTitle;
/*右侧当前选中的行的标题，这个以后可以根据传值的需要进行修改，可以改成模型或者基本数据类型*/
@property (nonatomic, copy) NSString *rightTitle;

/*没有功能View*/
@property (nonatomic, strong) UIView *NoDataView;
@end

@implementation XWSRightView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.leftArr = [NSMutableArray array];
        [self setUpUI];
    }
    return self;
}
#pragma mark - 懒加载


- (UIView *)NoDataView{
    if (!_NoDataView) {
        _NoDataView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_NoDataView];
        _NoDataView.backgroundColor = NavColor;
        [_NoDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navView.mas_bottom);
            make.width.mas_equalTo(ScreenWidth - leftMarginWidth);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        //添加标题
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_NoDataView addSubview:tipLabel];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.textColor = RGBA(170, 170, 170, 1);
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.NoDataView.mas_centerX);
            make.top.mas_equalTo(297);
            
        }];
        tipLabel.text = @"暂无数据";
    }
    return _NoDataView;
}

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_coverView];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0;
        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(leftMarginWidth + ScreenWidth);
        }];
        
        _coverView.userInteractionEnabled = YES;
        
        //蒙版添加手势事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCover:)];
        [_coverView addGestureRecognizer:tap];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCover:)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [_coverView addGestureRecognizer:swipe];
        
    }
    return _coverView;
}

- (UITableView *)rightTableView{
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.backgroundColor = rightBackColor;
        _rightTableView.tableFooterView = [[UIView alloc] init];
        _rightTableView.showsVerticalScrollIndicator = NO;
        _rightTableView.showsHorizontalScrollIndicator = NO;
        
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _rightTableView.rowHeight = RightTableViewRowHeight;
        _rightTableView.estimatedRowHeight = RightTableViewRowHeight;
        [self addSubview:_rightTableView];
        
        [_rightTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navView.mas_bottom);
            make.left.mas_equalTo(self.leftTableView.mas_right);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }
    return _rightTableView;
}

- (UITableView *)leftTableView{
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.backgroundColor = BackColor;
        _leftTableView.tableFooterView = [[UIView alloc] init];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _leftTableView.showsVerticalScrollIndicator = NO;
        _leftTableView.showsHorizontalScrollIndicator = NO;
        _leftTableView.rowHeight = LeftTableViewRowHeight;
        _leftTableView.estimatedRowHeight = LeftTableViewRowHeight;
        [self addSubview:_leftTableView];

        [_leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.navView.mas_bottom);
            make.left.mas_equalTo(self.coverView.mas_right).mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(100);
        }];
    }
    return _leftTableView;
}

#pragma Mark- 标题
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"筛选";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

#pragma mark - 确定按钮
- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _sureBtn.tag = SureBtnTag;
        [_sureBtn addTarget:self action:@selector(clickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

#pragma mark - 关闭按钮
- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeBtn.tag = CloseBtnTag;
        [_closeBtn addTarget:self action:@selector(clickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#pragma mark - 自定义的导航View
- (UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_navView];
        _navView.backgroundColor = rightBackColor;
        
        CGFloat h = NavibarHeight;
        CGFloat t = 0;
        CGFloat t1 = 27;
        //适配iPhoneX
        if (IS_IPHINE_X) {
            t = 44;
            h = 44;
            t1 = 7;
        }
        [_navView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(t);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(h);
            make.width.mas_equalTo(ScreenWidth - leftMarginWidth);
        }];
    
        [_navView addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.top.mas_equalTo(t1);
            make.width.height.mas_equalTo(30);
        }];
        
        [_navView addSubview:self.sureBtn];
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-17);
            make.top.mas_equalTo(self.closeBtn.mas_top);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(self.closeBtn.mas_height);
        }];
        
        [_navView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.sureBtn.mas_left);
            make.top.mas_equalTo(self.closeBtn.mas_top);
            make.height.mas_equalTo(30);
            make.left.mas_equalTo(self.closeBtn.mas_right);
        }];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:line];
        line.backgroundColor = DarkBack;
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(0.3);
            make.top.mas_equalTo(self.navView.mas_bottom).mas_equalTo(-0.3);
            make.width.mas_equalTo(self.navView.mas_width);
        }];
    }
    return _navView;
}

#pragma mark - 设置界面
- (void)setUpUI{
    [self navView];
    [self coverView];
    [self leftTableView];
    [self rightTableView];
    [self NoDataView];
    
}

#pragma mark - 根据传入的数据，获取对应的值（可以在这里进行修改）
//获取左侧标题
- (NSString *)getLeftDataWithIndex:(NSInteger)index{
    NSDictionary *dic = self.leftArr[index];
    //这里使用name是因为假数据里面的关键字是name，可以根据数据的值在改动
    NSString *title = dic[@"name"];
    return title;
}

//这里是获取右边的数组，主要使用来给tableView显示多少行的
- (NSArray *)getRightDataArrWithLeftSelectIndex:(NSInteger)index{
    if (self.leftArr.count == 0) {
        return nil;
    }
    NSDictionary *dic = self.leftArr[index];
    NSArray *areas = dic[@"area"];
    return areas;
}

//获取右侧标题
- (NSString *)getRightTitleNameWithRightIndex:(NSInteger)index withLeftSelectIndex:(NSInteger)leftSelectIndex{
    NSArray *rights = [self getRightDataArrWithLeftSelectIndex:leftSelectIndex];
    if (rights.count == 0) {
        return nil;
    }
    NSString *area = rights[index];
    return area;
}


#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _leftTableView) {
        return self.leftArr.count;
    }

    return (self.leftArr.count ? [self getRightDataArrWithLeftSelectIndex:self.selectLeftRow].count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XWSRightCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XWSRightCell"];
        if (tableView == _rightTableView) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
            line.backgroundColor = DarkBack;
            [cell addSubview:line];
            /*在这里使用masonry控制，会爆出约束冲突，但是不影响使用，所以就不管了*/

            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.left.mas_equalTo(17);
                make.bottom.mas_equalTo(-0.3);
                make.height.mas_equalTo(0.3);
            }];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (tableView == _leftTableView) {
        cell = [self setUpLeftCellWithTableViewCell:cell withIndexPath:indexPath];
        return cell;
        
    }else{
        cell = [self setUpRightCellWithTableViewCell:cell withIndexPath:indexPath];
        return cell;
    }
}

- (UITableViewCell *)setUpRightCellWithTableViewCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.text = [self getRightTitleNameWithRightIndex:indexPath.row withLeftSelectIndex:self.selectLeftRow];
    
    if (indexPath.row == self.selectRightRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
         cell.textLabel.textColor = [UIColor whiteColor];
        cell.tintColor = [UIColor whiteColor];
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = RGBA(153, 153, 153, 1);
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.backgroundColor = rightBackColor;
    return cell;
}

- (UITableViewCell *)setUpLeftCellWithTableViewCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    
    NSString *name = [self getLeftDataWithIndex:indexPath.row];
    
    cell.textLabel.text = name;
    if (indexPath.row == self.selectLeftRow) {
        cell.backgroundColor = rightBackColor;
        cell.textLabel.textColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = BackColor;
        cell.textLabel.textColor = RGBA(153, 153,153, 1);
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (tableView == self.leftTableView) {
        //设置左侧
        self.leftTitle = cell.textLabel.text;
        cell.backgroundColor = rightBackColor;
        self.selectLeftRow = indexPath.row;
        
        //设置右侧(这个时候必须得使用leftArr来再次计算，不能直接使用rightArr，因为这个默认选中第一个row的时候rightArr还没有值)
        self.selectRightRow = 0;
        NSString *rightTitle = [self getRightTitleNameWithRightIndex:self.selectRightRow withLeftSelectIndex:self.selectLeftRow];
        self.rightTitle = rightTitle;
        [self.leftTableView reloadData];
    }else{
        self.selectRightRow = indexPath.row;
        self.rightTitle = cell.textLabel.text;
    }
    
    [self.rightTableView reloadData];
}

#pragma mark - 点击以及手势事件
- (void)clickCloseBtn:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(clickRightView:getLeftText:getRightText:)]) {
        NSString *left = nil;
        NSString *right = nil;
        if (btn.tag == SureBtnTag) {
            left = self.leftTitle;
            right = self.rightTitle;
        }
        
        [self.delegate clickRightView:self getLeftText:left getRightText:right];
    }
}
- (void)swipeCover:(UISwipeGestureRecognizer *)tap{
    
    if ([self.delegate respondsToSelector:@selector(clickRightView:getLeftText:getRightText:)]) {
        [self.delegate clickRightView:self getLeftText:nil getRightText:nil];
    }
}
- (void)clickCover:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(clickRightView:getLeftText:getRightText:)]) {
        [self.delegate clickRightView:self getLeftText:nil getRightText:nil];
    }
}

#pragma mark - 动画
- (void)startCoverViewOpacityWithAlpha:(CGFloat)alpha withDuration:(CGFloat)duration{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:alpha];
    opacityAnimation.duration = duration;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    [_coverView.layer addAnimation:opacityAnimation forKey:@"opacity"];
    _coverView.alpha = alpha;
}

- (void)cancelCoverViewOpacity{
    [_coverView.layer removeAllAnimations];
    _coverView.alpha = 0;
}

#pragma mark - 传进来的数据
- (void)setDatas:(NSMutableArray *)datas{
    _datas = datas;
    
    [self.leftArr removeAllObjects];
    //给左边数据列表赋值
    [self.leftArr addObjectsFromArray:_datas];
    
    if (self.leftArr.count != 0) {
        self.NoDataView.hidden = YES;
        self.leftTableView.hidden = NO;
        self.rightTableView.hidden = NO;
        //默认选中第一行
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.leftTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.leftTableView didSelectRowAtIndexPath:indexPath];
        [self.rightTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.rightTableView didSelectRowAtIndexPath:indexPath];
    }else{
        self.NoDataView.hidden = NO;
        self.leftTableView.hidden = YES;
        self.rightTableView.hidden = YES;
    }
}

@end
