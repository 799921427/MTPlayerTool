//
//  ToolViewController.m
//  ToolView
//
//  Created by 张德茂 on 2018/9/4.
//  Copyright © 2018年 张德茂. All rights reserved.
//

#import "ToolViewController.h"
#import <Masonry/Masonry.h>
#import "PlayerThumbnailView.h"
#import "Function.h"
#import "MediaManager.h"

@interface ToolViewController () <UIScrollViewDelegate,PlayerThumbnailViewDelegate>

//系统 IB
@property (nonatomic, strong) UIView * toolView;
@property (nonatomic, strong) UIScrollView * toolScrollView;
@property (nonatomic, strong) UIButton * playBtn;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIButton * cutBtn;
@property (nonatomic, strong) UIButton * deleteBtn;
@property (nonatomic, strong) PlayerThumbnailView * contentView;
@property (nonatomic, strong) UILabel * cutLine;

@property (nonatomic, strong) UIImageView * leftBtn;
@property (nonatomic, strong) UIImageView * rightBtn;

//Model
@property (nonatomic) NSInteger indexNum;
@property (nonatomic) double nowOffset; //当前偏移量
@property (nonatomic) double midSpacing;
@property (nonatomic) int nowIndex; //当前选中的viewItem下标
@property (nonatomic) NSMutableArray * itemLengthArr; //视图长度数组
@property (nonatomic) NSMutableArray<PlayerThumbnailView *>  *viewArr; //视图数组
@property (nonatomic) double totalLength; //视图总长度
@property (nonatomic) double totalDistance; //视图总长度

//记录左侧件移动的起始位置
@property (nonatomic) CGPoint startPoint1;
//记录右侧控件移动的起始位置
@property (nonatomic) CGPoint startPoint2;


//flag 标记

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isAnother; //是否从A->B
@property (nonatomic, assign) BOOL isLeft; //从A->B 若A在B左侧 为YES

@end

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define BtnWidth 20
#define BtnHeight 40
//两个控件的最短距离
#define BtnMinSpacing 20
//两个视图之间的间隔
const double spacing = 10.0;

@implementation ToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataConfiguration];
    [self setUpUI];
    
    [self animationBegin];
   
    // Do any additional setup after loading the view.
}


#pragma mark - Private SetUpUI
- (void)setUpUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.playBtn = [[UIButton alloc] initWithFrame:CGRectMake(7,SCREEN_HEIGHT - 160, 40, 40)];
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    //self.playBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.playBtn];
    
    //bottomView
    float bottomViewHeight = 60;
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - bottomViewHeight, SCREEN_WIDTH, bottomViewHeight)];
    //cutBtn
    self.cutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, bottomViewHeight)];                                                    
    [self.cutBtn setTitle:@"分割" forState:UIControlStateNormal];
    [self.cutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cutBtn addTarget:self action:@selector(cutMovie) forControlEvents:UIControlEventTouchUpInside];
    
    //deleteBtn
    self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, bottomViewHeight)];
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteMovie) forControlEvents:UIControlEventTouchUpInside];
    
    //addToBottomView
    [self.bottomView addSubview:self.cutBtn];
    [self.bottomView addSubview:self.deleteBtn];
    
    [self.view addSubview:self.bottomView];
    
    //toolView
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(50, SCREEN_HEIGHT - 160, SCREEN_WIDTH - 50, 40)];
    self.toolView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.toolView];
    
    //scrollView
    self.toolScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 50, 40)];
    self.toolScrollView.backgroundColor = [UIColor blackColor];
    self.toolScrollView.delegate = self;
    
    CGFloat leftOrigin = self.toolScrollView.frame.size.width / 2;
    //NSURL *mediaURL = [[NSBundle mainBundle] URLForResource:@"mov1" withExtension:@"mp4"];
    NSURL * mediaURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mov2" ofType:@"mp4"]];
    CGFloat totalMediaLength = [MediaManager getVideoTimeWithURL:mediaURL];
    //每五秒一个单位长度
    CGFloat contentViewWidth = floor(totalMediaLength / 6) * 40 ;
    CGFloat rightOrigin = leftOrigin + contentViewWidth;
    self.contentView = [[PlayerThumbnailView alloc] initWithLeft:0 right:contentViewWidth leftOrigin:leftOrigin rightOrigin:rightOrigin totalLength:contentViewWidth andURL:@"mov2" withExtension:@"mp4"];
    self.contentView.delegate = self;
    NSLog(@"totalMediaLength:%lf",totalMediaLength);
    [self.toolScrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.toolScrollView.frame.size.width / 2);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(contentViewWidth, 40));
    }];
    [self.toolScrollView layoutIfNeeded];
    [self.contentView createThumbnailImage];
    //self.contentView.tag = 0;
    self.contentView.backgroundColor = [UIColor redColor];
    self.midSpacing = self.toolScrollView.frame.size.width / 2;
    
    [self.viewArr addObject:self.contentView];
    
    //[self setUpScrollView];
//    [self.toolScrollView addSubview:self.contentView];
    
    self.toolScrollView.showsHorizontalScrollIndicator = NO;
    
    self.toolScrollView.contentSize = CGSizeMake(self.toolScrollView.frame.size.width + contentViewWidth , self.toolScrollView.frame.size.height);
    [self.toolView addSubview:self.toolScrollView];
    [self.view addSubview:self.toolView];
    
    //cutLine
    self.cutLine = [[UILabel alloc] initWithFrame:CGRectMake(self.toolView.frame.origin.x + self.toolView.frame.size.width / 2, self.toolView.frame.origin.y - 15, 1, self.toolView.frame.size.height + 30)];
    self.cutLine.layer.borderWidth = 0.5;
    self.cutLine.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:self.cutLine];
    
}



#pragma mark - Private SetUpScrollView
- (void)setUpScrollView {
    NSLog(@"self.viewArr.count:%lu",(unsigned long)self.viewArr.count);
    if(self.viewArr.count == 1) {
        [self.toolScrollView addSubview:[self.viewArr objectAtIndex:0] ];
        NSLog(@"setUpScrollView");
        return;
    }
    
}

#pragma mark - Private InitDataConfiguration
- (void)initDataConfiguration {
    self.nowIndex = 0;
    self.indexNum = 0;
    self.nowOffset = 0;
    self.isAnother = NO;
    self.viewArr = [[NSMutableArray alloc] init];
    self.totalLength = self.contentView.frame.size.width;
    self.itemLengthArr = [[NSMutableArray alloc] init];
    [self.itemLengthArr insertObject:@(self.totalLength) atIndex:0];
}

#pragma mark - Private CalculateNowIndex;
- (int)calculateNowIndex:(double)nowOffset {
    NSLog(@"nowItemArrCount:%lu",(unsigned long)self.viewArr.count);
    for(int i = 0; i < self.viewArr.count ; i++) {
        nowOffset -= [self.viewArr objectAtIndex:i].frame.size.width + spacing;
        if(nowOffset < 0) {
            self.nowIndex = i;
            break;
        }
    }
    return self.nowIndex;
}

#pragma mark - Private CalculateNowWidth;
- (double)calculateNowWidthOfNowIndex:(int)nowIndex{
    double width = self.nowOffset;
    for(int i = 0; i < nowIndex ; i++) {
        width -= [self.viewArr objectAtIndex:i].frame.size.width;
    }
    width -= nowIndex * spacing;
    return width;
}

#pragma mark - UIEvents
- (void)cutMovie {
    NSLog(@"cut");
    [self removeToolBtn];
//    for(UIView * view in self.toolScrollView.subviews) {
//        if([view isKindOfClass:[UIImageView class]]) {
//            [view removeFromSuperview];
//        }
//    }
//    for(PlayerThumbnailView * view in self.viewArr){
//        view.isShow = NO;
//    }
    PlayerThumbnailView * firstView = [self.viewArr objectAtIndex:self.nowIndex];
    BOOL isRight = self.nowIndex < self.viewArr.count - 1 ? true : false;
    
    float nowIndexWidth = firstView.frame.size.width;
    double nowWidth = [self calculateNowWidthOfNowIndex:self.nowIndex];
//if(isSelected) nowWidth += 2 * BtnWidth;
    CGFloat right = firstView.rightMargin;
    
    firstView.rightMargin -= nowIndexWidth -nowWidth;
    firstView.rightOrigin -= nowIndexWidth -nowWidth;
    
    [firstView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(nowWidth);
    }];
    //[self.toolScrollView layoutIfNeeded];
    NSLog(@"nowWidth:%f,nowIndexWith:%f",nowWidth,nowIndexWidth);
  // frame.size.width = nowWidth;
   
    CGFloat leftOrigin = firstView.frame.origin.x + nowWidth + spacing ;
    firstView.backgroundColor = [UIColor yellowColor];
    //NSLog(@"firstFrameWidth:%f",firstView.frame.size.width);
    PlayerThumbnailView * secondView = [[PlayerThumbnailView alloc] initWithLeft:right - (nowIndexWidth - nowWidth) right:right leftOrigin:leftOrigin rightOrigin:leftOrigin + (nowIndexWidth - nowWidth)   totalLength: nowIndexWidth - nowWidth andURL:@"mov1" withExtension:@"mp4"];
    
    secondView.backgroundColor = [UIColor blueColor];
    secondView.delegate = self;
    [self.toolScrollView addSubview:secondView];
    
    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstView.mas_right).with.offset(spacing);
        make.top.equalTo(firstView);
        make.size.mas_equalTo(CGSizeMake(nowIndexWidth - nowWidth, 40));
    }];
    
    [self.toolScrollView layoutIfNeeded];
    if(isRight) {
        UIView * thirdView = [self.viewArr objectAtIndex:self.nowIndex + 1];
        double thirdWidth = thirdView.frame.size.width;
        [thirdView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(secondView);
            make.size.mas_equalTo(CGSizeMake(thirdWidth, 40));
            make.left.equalTo(secondView.mas_right).with.offset(spacing);
        }];
    }
     //NSLog(@"firstView.origin.x:%f, y:%f, width:%f, height:%f",firstView.frame.origin.x,firstView.frame.origin.y,firstView.frame.size.width,firstView.frame.size.height);
    //NSLog(@"secondView.origin.x:%f, y:%f, width:%f, height:%f",secondView.frame.origin.x,secondView.frame.origin.y,secondView.frame.size.width,secondView.frame.size.height);
    [self.viewArr replaceObjectAtIndex:self.nowIndex withObject:firstView];
    [self.viewArr insertObject:secondView atIndex:self.nowIndex+1];
    
    self.toolScrollView.contentSize = CGSizeMake(self.toolScrollView.contentSize.width + spacing, self.toolScrollView.contentSize.height);
    
    firstView.isShow = YES;
    [firstView setUpUI];
    [self.toolScrollView layoutIfNeeded];
    [self.toolScrollView setContentOffset:CGPointMake(firstView.frame.origin.x + firstView.frame.size.width - _midSpacing, 0) animated:YES];
}

-(void)deleteMovie {
    if(self.viewArr.count == 1) return ;
    [self removeToolBtn];
    PlayerThumbnailView * firstView = [self.viewArr objectAtIndex:self.indexNum];
    float cutWidth = firstView.rightMargin - firstView.leftMargin;
    NSLog(@"_____cutWidth:%lf",cutWidth);
    if(self.viewArr.count >= 2) {
        
        if(self.indexNum == 0) {
            PlayerThumbnailView * secondView = [self.viewArr objectAtIndex:self.indexNum + 1];
            CGSize size = secondView.frame.size;
            [secondView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.toolScrollView.frame.size.width / 2);
                make.top.equalTo(firstView);
                make.size.mas_equalTo(size);
            }];
        }
        else if(self.indexNum == self.viewArr.count - 1){
            PlayerThumbnailView * secondView = [self.viewArr objectAtIndex:self.indexNum - 1];
//            CGSize size = secondView.frame.size;
//            [secondView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(self.toolScrollView.frame.size.width / 2);
//                make.top.mas_equalTo(0);
//                make.size.mas_equalTo(size);
//            }];
            [firstView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(0, 40));
            }];
            [self.toolScrollView layoutIfNeeded];
        }
        else {
            PlayerThumbnailView * secondView = [self.viewArr objectAtIndex:self.indexNum + 1];
            PlayerThumbnailView * foreheadView = [self.viewArr objectAtIndex:self.indexNum - 1];
            [firstView mas_remakeConstraints:^(MASConstraintMaker *make) {
            }];
            [secondView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(foreheadView.mas_right).with.offset(spacing);
                make.top.equalTo(foreheadView);
            }];
        }
        [self.viewArr removeObjectAtIndex:self.indexNum];
        [self.toolScrollView layoutIfNeeded];
        
    }
    [self.toolScrollView setContentSize:CGSizeMake(self.toolScrollView.contentSize.width - cutWidth - 2 * BtnWidth - spacing, self.toolScrollView.contentSize.height)];
}


#pragma mark - Private RemoveToolBtn
- (void)removeToolBtn {
    for(PlayerThumbnailView * view in self.viewArr) {
        for(UIView *subview in view.subviews) {
            if([subview isKindOfClass:[UIImageView class]]) {
                [subview removeFromSuperview];
                [view mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(view.frame.size.width - 2 * BtnWidth, 40));
                }];
            }
            [subview layoutIfNeeded];
        }
    }
}

#pragma mark - AnimationBegin
- (void)animationBegin {
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   // NSLog(@"nowOffset:%f",scrollView.contentOffset.x);
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"endOffset:%f",scrollView.contentOffset.x);
    self.nowOffset = scrollView.contentOffset.x;
    [self calculateNowIndex:self.nowOffset];
    NSLog(@"nowOffset:%f,nowIndex:%d",self.nowOffset,self.nowIndex);
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
   // NSLog(@"dragEndOffset:%f",scrollView.contentOffset.x);
    self.nowOffset = scrollView.contentOffset.x;
    [self calculateNowIndex:self.nowOffset];
    NSLog(@"nowOffset:%f,nowIndex:%d",self.nowOffset,self.nowIndex);
    CGRect rect = [self.view convertRect:self.cutLine.frame toView:self.toolScrollView];
    NSLog(@"originX:%f,originY:%f",rect.origin.x,rect.origin.y);
}

#pragma mark - PlayerThumbnailViewTapDelegate
- (void)moveViewClicked:(UITapGestureRecognizer *)tapGesture {
    PlayerThumbnailView * tapView = (PlayerThumbnailView *)tapGesture.view;
    NSInteger cur = [self.viewArr indexOfObject:tapView];
    
    NSLog(@"** cur:%ld",(long)cur);
    if(cur != self.indexNum && !self.isShow) {
        self.isAnother = YES;
        if(cur>self.indexNum) self.isLeft = YES;
        else self.isLeft = NO;
    }
    else self.isAnother = NO;
    self.indexNum = cur;
    NSLog(@"** self.isAnother:%d **",self.isAnother);
    if(tapView.isShow) {
        NSLog(@"&&&&");

        //[self.toolScrollView setContentOffset:CGPointMake(tapView.frame.origin.x  - _midSpacing, 0) animated:YES];
//        self.toolScrollView.contentSize = CGSizeMake(self.toolScrollView.contentSize.width - BtnWidth, self.toolScrollView.contentSize.height);
        self.isShow = YES;
    }
    else {
        NSLog(@"$$$$");
        self.isShow = NO;
    }
    //if(!tapView.isShow) {
    for(PlayerThumbnailView * view in self.viewArr){
        view.isShow = NO;
    }
    [self removeToolBtn];
    //tapView.isShow = YES;
    for(int i=0; i<self.viewArr.count; i++) {
        if(self.viewArr[i].isShow)  NSLog(@"YES:%d",i);
    }
    if(self.isShow) tapView.isShow = YES;
    else tapView.isShow = NO;
    
}


- (void)scrollWithLeft:(CGFloat)left right:(CGFloat)right isRemove:(BOOL)isRemove{
    CGRect rect = [self.view convertRect:self.cutLine.frame toView:self.toolScrollView];
   // NSLog(@"line.x:%f, left:%f, right%f",rect.origin.x, left, right);
    NSLog(@"***isLeft:%d",self.isLeft);
    if(self.isAnother)  [self.toolScrollView setContentSize:CGSizeMake(self.toolScrollView.contentSize.width - 2 * BtnWidth, self.toolScrollView.contentSize.height)];
    if(rect.origin.x <= left) {
        NSLog(@"**");
        CGFloat offsetX = left - self.midSpacing;
        if(self.isAnother) offsetX -= 2 * BtnWidth;
        if(isRemove)    offsetX -=  BtnWidth;
        else    offsetX += BtnWidth;
        [self.toolScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    else if(rect.origin.x >= right) {
        NSLog(@"***");
        CGFloat offsetX = right - self.midSpacing;
        NSLog(@"Another:%d, left:%d, show:%d",self.isAnother,self.isLeft,self.isShow);
        //offsetX += BtnWidth;
        if(self.isAnother && isRemove) offsetX += 2 * BtnWidth;
//        if(!self.isAnother && self.isLeft && !self.isShow) offsetX +=  BtnWidth;
//        //if(!self.isAnother && self.isLeft && !self.isShow) offsetX += BtnWidth;
        if(!isRemove && !self.isAnother) offsetX += BtnWidth;
        else offsetX -= BtnWidth;
        [self.toolScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        
    }
//    else if(rect.origin.x > left && rect.origin.x < right) {
//        CGFloat offsetX = left - BtnWidth - _midSpacing;
//        NSLog(@"2222");
//        if(isRemove) {
//            NSLog(@"^_^");
//            [self.toolScrollView setContentOffset:CGPointMake(offsetX + BtnWidth, 0) animated:YES];
//        }
//        else {
//            NSLog(@"^+^");
//            //[self.toolScrollView setContentOffset:CGPointMake(offsetX +  2 * BtnWidth, 0) animated:YES];
//        }
//    }
   
}

- (void)panGesture:(UIGestureRecognizer *)panGesture isLeft:(BOOL)isLeft maxX:(CGFloat)maxX minX:(CGFloat)minX {
    PlayerThumbnailView * panView = (PlayerThumbnailView *)panGesture.view.superview;
    CGPoint *startPoint = NULL;
    if(isLeft) startPoint = &_startPoint1;
    else startPoint = &_startPoint2;
    PlayerThumbnailView * firstView = (PlayerThumbnailView *)[self.viewArr objectAtIndex:0];
    //手势状态 -> 开始点击
    if(panGesture.state == UIGestureRecognizerStateBegan) {
        self.totalDistance = 0;
        *startPoint = [panGesture locationInView:self.toolScrollView];
        self.toolScrollView.userInteractionEnabled = NO;
    }//手势状态 -> 点击停止
    else if(panGesture.state == UIGestureRecognizerStateEnded) {
       //NSLog(@"totalLength:%f",panGesture.view.subview.frame.size.width);
        [firstView mas_updateConstraints:^(MASConstraintMaker *make) {
            //CGRect rect = [firstView convertRect:firstView.leftBtn.frame toView:panView.superview];
            make.left.mas_equalTo(self.toolScrollView.frame.size.width / 2);
        }];
       
        [firstView layoutIfNeeded];
        CGRect rect = [panView convertRect:panGesture.view.frame toView:panView.superview];
        if(isLeft) {
            panView.leftMargin += self.totalDistance;
            [self.toolScrollView setContentOffset:CGPointMake(rect.origin.x - _totalDistance - _midSpacing + BtnWidth, 0) animated:YES];
            self.toolScrollView.contentSize = CGSizeMake(self.toolScrollView.contentSize.width - _totalDistance, self.toolScrollView.contentSize.height);
        }
        else {
            [self.toolScrollView setContentOffset:CGPointMake(rect.origin.x - _midSpacing, 0) animated:YES];
            self.toolScrollView.contentSize = CGSizeMake(self.toolScrollView.contentSize.width + _totalDistance, self.toolScrollView.contentSize.height);
        }
        
        NSLog(@"totalDistance:%f",_totalDistance);
        self.toolScrollView.userInteractionEnabled = YES;
    }//手势状态 -> 移动中
    else if(panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint endPoint = [panGesture locationInView:self.toolScrollView];
        double nowWidth = endPoint.x - startPoint->x;
        self.totalDistance += nowWidth;
        NSLog(@"nowWidth:%f",nowWidth);
        CGRect rect = [panView convertRect:panGesture.view.frame toView:panView.superview];
        if(isLeft) {
            if(_totalDistance >= minX && _totalDistance <= maxX) {
                [panGesture.view.superview mas_updateConstraints:^(MASConstraintMaker *make) {
                    
                    make.size.mas_equalTo(CGSizeMake(panGesture.view.superview.frame.size.width - nowWidth , 40));
                }];
                
            }
            [panView.superview layoutIfNeeded];
             CGRect rect1 = [firstView convertRect:firstView.leftBtn.frame toView:panView.superview];
            [firstView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(rect1.origin.x + nowWidth);
            }];
            NSLog(@"--min:%f---%f---total:%f",minX,rect.origin.x,_totalDistance);
           // [self.toolScrollView setContentOffset:CGPointMake(rect.origin.x - _totalDistance, 0) animated:YES];
            //NSLog(@"*****leftSpacing:%f",rect.origin.x);
        }
        else {
            if((rect.origin.x >= minX && rect.origin.x <= maxX) || nowWidth > 0 )
                [panGesture.view.superview mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(panGesture.view.superview.frame.size.width + nowWidth , 40));
                }];
            [panView.superview layoutIfNeeded];
            
        }
//        [panGesture.view mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(panGesture.view.superview.frame.size.width + nowWidth , 40));
//            if(isLeft) {
//                make.left.mas_equalTo(self.toolScrollView.frame.size.width / 2 + nowWidth);
//                NSLog(@"left2:%f",self.toolScrollView.frame.size.width / 2 + nowWidth);
//                if(self.indexNum > 0) {
//                    NSLog(@"*****");
//                    PlayerThumbnailView * forwardView = [self.viewArr objectAtIndex:self.indexNum - 1];
//                    if(isLeft){
//                        make.left.mas_equalTo(forwardView.mas_right).with.offset(spacing + nowWidth);
//                        NSLog(@"left1:%f",spacing + nowWidth);
//                    }
//                }
//            }
//            else {
//
//            }
        
//        }];
        //[panView layoutIfNeeded];
        //_moveDistance = endPoint.x - startPoint->x;
//        _totalDistance += _moveDistance;
        
        //self.leftOrigin = frame.origin.x;
        
//        frame.origin.x = MIN(maxX,MAX(frame.origin.x, minX));
//
//        panGesture.view.frame = frame;
        * startPoint = endPoint;
        [panView layoutIfNeeded];
        
    }
 //   [panView resetView];
    
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
