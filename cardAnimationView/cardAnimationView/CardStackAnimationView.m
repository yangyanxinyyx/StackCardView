

#import "CardStackAnimationView.h"
#import "CardStackAnimationCell.h"

typedef NS_ENUM(NSInteger, CardAnimationViewState) {
    CardAnimationViewStateDefault = 0,
    CardAnimationViewStateNext    = 1,
    CardAnimationViewStateLast    = 2,
};

static CGFloat const kCardStackTopMargin = 30;
static CGFloat const kCardStackOriginY = 35;
static CGFloat const kCardAnimationTranslateX = 200;
static CGFloat const kCardAnimationTranslateY = 40;
#define kCardStackViewWidth  300
#define kCardStackViewHeight  450

@interface CardStackAnimationView ()<UIGestureRecognizerDelegate>

///主动画view
@property (nonatomic, strong) CardStackAnimationCell *mainAniView;
@property (nonatomic, strong) CardStackAnimationCell *secAniView;
@property (nonatomic, strong) CardStackAnimationCell *thirdAniView;

//辅助动画view
@property (nonatomic, strong) CardStackAnimationCell *lastAniView;

//滑动方向
@property (nonatomic, assign) BOOL isPaning;
@property (nonatomic, assign) CardAnimationViewState panState;

//不重要数据源
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger newModelCount;
@end

@implementation CardStackAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
        [self setupUI];
    }
    return self;
}

- (void)setupData {
    self.newModelCount = 0;
    self.dataSource = [NSMutableArray array];
    
    for (NSInteger i = 0; i <5; i ++) {
        CardModel *model = [[CardModel alloc] init];
        model.count = i;
        [self.dataSource addObject:model];
    }
    
    //模拟请求数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setData];
    });
}

- (void)setupUI {

    // 添加拖拽手势
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];

    CardStackAnimationCell *mainAniView = [[CardStackAnimationCell alloc] init];
    mainAniView.hidden = YES;
    CardStackAnimationCell *secAniView = [[CardStackAnimationCell alloc] init];
    secAniView.hidden = YES;
    CardStackAnimationCell *thirdAniView = [[CardStackAnimationCell alloc] init];
    thirdAniView.hidden = YES;
    
    [self addSubview:mainAniView];
    [self insertSubview:secAniView atIndex:0];
    [self insertSubview:thirdAniView atIndex:0];
    
    self.mainAniView = mainAniView;
    self.secAniView = secAniView;
    self.thirdAniView = thirdAniView;
    
    self.mainAniView.frame = CGRectMake(0, kCardStackOriginY, kCardStackViewWidth, kCardStackViewHeight);
    self.secAniView.frame = CGRectMake(0, kCardStackOriginY - kCardStackTopMargin, kCardStackViewWidth, kCardStackViewHeight);
    self.secAniView.transform = CGAffineTransformMakeScale(0.95, 0.95);
    
    self.thirdAniView.frame = CGRectMake(0, kCardStackOriginY - kCardStackTopMargin * 2, kCardStackViewWidth, kCardStackViewHeight);
    self.thirdAniView.transform = CGAffineTransformMakeScale(0.90, 0.90);
    
    
}

- (void)setData {
    self.mainAniView.model = [self getNewDataFormArray];
    self.secAniView.model = [self getNewDataFormArray];
    self.thirdAniView.model = [self getNewDataFormArray];
    
    self.mainAniView.hidden = NO;
    self.secAniView.hidden = NO;
    self.thirdAniView.hidden = NO;
}

- (CardModel *)getNewDataFormArray {
    if (self.newModelCount < self.dataSource.count) {
        
        CardModel *model = self.dataSource[self.newModelCount];
        self.newModelCount ++;
        return model;
    } else {
        CardModel *model = self.dataSource[0];
        self.newModelCount  = 1;
        return model;
    }
    
}

- (CardModel *)getLastDataFormArray {
    
    if (self.newModelCount == 0) {
        CardModel *model = [self.dataSource lastObject];
        self.newModelCount = self.dataSource.count - 1;
        return model;
    } else {
        self.newModelCount --;
        CardModel *model = self.dataSource[self.newModelCount];
        return model;
    }
}


/** 平移手势响应事件  */
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self];
    
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self panGestureBeginWithPoint:point];
        NSLog(@"[test] Began Point.y %f",point.x);
       
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self panGestureMoveWithPoint:point];
        NSLog(@"[test] Changed Point.y %f",point.x);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self panGestureEndWithPoint:point];
        NSLog(@"[test] Ended Point.y %f",point.x);

    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        [self panGestureEndWithPoint:point];
        NSLog(@"[test] Ended Point.y %f",point.x);
       
    }
}

- (void)panGestureBeginWithPoint:(CGPoint)point {
    self.isPaning = YES;
    if (point.x > 0) {
        self.panState = CardAnimationViewStateLast;
        
        // 滑出上一个卡片
        self.newModelCount = self.mainAniView.model.count;
        CardStackAnimationCell *newView = [[CardStackAnimationCell alloc] init];
        newView.model = [self getLastDataFormArray];
        newView.alpha = 0;
        [self addSubview:newView];
        self.lastAniView = newView;
        newView.frame = CGRectMake(0, kCardStackOriginY, kCardStackViewWidth, kCardStackViewHeight);
        
       
    } else {
        self.panState = CardAnimationViewStateNext;
    }
}


//滑动中手势 对应的几个view同时做放大位移旋转等动画
- (void)panGestureMoveWithPoint:(CGPoint)point {
    if (self.panState == CardAnimationViewStateNext) {
        if (point.x > 0) {
            return;
        }
        
        CGFloat progress = fabs(point.x)/kCardAnimationTranslateX;
        NSLog(@"[test] Changed progress %f",progress);
        if (progress > 1) {
            progress = 1;
        }
        
        self.mainAniView.alpha = 1 - progress;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-kCardAnimationTranslateX  * progress, kCardAnimationTranslateY*progress);
        self.mainAniView.transform = transform;
        if (progress >= 0.3) {
            CGFloat angel = M_PI / 6.0 * -1;
            CGFloat rotationAngel = angel * (progress-0.3) ;
            CGAffineTransform transform1 = CGAffineTransformRotate(transform,rotationAngel);
            
            self.mainAniView.transform = transform1;
        }
        
        
        self.secAniView.transform = CGAffineTransformMakeScale(0.95 + (0.05*progress), 0.95 + (0.05*progress));
        self.secAniView.transform = CGAffineTransformTranslate(self.secAniView.transform, 0, kCardStackTopMargin*progress);
        
        self.thirdAniView.transform = CGAffineTransformMakeScale(0.90 + (0.05*progress), 0.90 + (0.05*progress));
        self.thirdAniView.transform = CGAffineTransformTranslate(self.thirdAniView.transform, 0, kCardStackTopMargin*progress);
    } else if (self.panState == CardAnimationViewStateLast) {
        
        if (point.x < 0) {
            return;
        }
       
        CGFloat progress = 1 - fabs(point.x)/kCardAnimationTranslateX;
        NSLog(@"[test] Changed progress %f",progress);
        if (progress < 0) {
            progress = 0;
        }
        
        self.lastAniView.alpha = 1 - progress;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-kCardAnimationTranslateX  * progress, kCardAnimationTranslateY*progress);
        self.lastAniView.transform = transform;
        if (progress >= 0.3) {
            CGFloat angel = M_PI / 6.0 * -1;
            CGFloat rotationAngel = angel * (progress-0.3) ;
            CGAffineTransform transform1 = CGAffineTransformRotate(transform,rotationAngel);
            
            self.lastAniView.transform = transform1;
        }
        
        self.mainAniView.transform = CGAffineTransformMakeScale(0.95 + 0.05 *progress, 0.95 + 0.05 *progress);
        self.mainAniView.transform = CGAffineTransformTranslate(self.mainAniView.transform, 0, -kCardStackTopMargin * (1-progress));
        
        self.secAniView.transform = CGAffineTransformMakeScale(0.90 + 0.05 *progress, 0.90 + 0.05 *progress);;
        self.secAniView.transform = CGAffineTransformTranslate(self.secAniView.transform, 0, -kCardStackTopMargin* (1-progress));
        
    }
 
}

// 滑动结束 判断是切换还是取消
- (void)panGestureEndWithPoint:(CGPoint)point {
    if (self.panState == CardAnimationViewStateNext) {
        if (point.x <= -kCardAnimationTranslateX*0.6) {
            [self switchAnimation];
        } else {
            [self cancelPan];
        }
    } else if (self.panState == CardAnimationViewStateLast) {
        if (point.x >= kCardAnimationTranslateX*0.6) {
            [self switchAnimation];
        } else {
            [self cancelPan];
        }
    }
    
    self.isPaning = NO;
    self.panState = CardAnimationViewStateDefault;

}

- (void)switchAnimation {
    if (self.panState == CardAnimationViewStateNext) {
        [UIView animateWithDuration:0.3 animations:^{
            self.mainAniView.alpha = 0;
            CGAffineTransform transform = CGAffineTransformTranslate(self.mainAniView.transform, -kCardAnimationTranslateX, 0);
            self.mainAniView.transform = transform;
            
            
            self.secAniView.transform = CGAffineTransformMakeScale(1, 1 );
            self.secAniView.transform = CGAffineTransformTranslate(self.secAniView.transform, 0, kCardStackTopMargin);
            
            self.thirdAniView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            self.thirdAniView.transform = CGAffineTransformTranslate(self.thirdAniView.transform, 0, kCardStackTopMargin);
        

        } completion:^(BOOL finished) {
            [self.mainAniView removeFromSuperview];
            self.mainAniView = nil;
            
            
            CardStackAnimationCell *newView = [[CardStackAnimationCell alloc] init];
            newView.model = [self getNewDataFormArray];
            [self insertSubview:newView atIndex:0];
            
            self.mainAniView = self.secAniView;
            self.secAniView = self.thirdAniView;
            self.thirdAniView = newView;
            
            self.mainAniView.transform = CGAffineTransformIdentity;
            self.secAniView.transform = CGAffineTransformIdentity;
            self.thirdAniView.transform = CGAffineTransformIdentity;
            
            self.mainAniView.frame = CGRectMake(0, kCardStackOriginY, kCardStackViewWidth, kCardStackViewHeight);
            self.secAniView.frame = CGRectMake(0, kCardStackOriginY - kCardStackTopMargin, kCardStackViewWidth, kCardStackViewHeight);
            self.secAniView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            
            self.thirdAniView.frame = CGRectMake(0, kCardStackOriginY - kCardStackTopMargin * 2, kCardStackViewWidth, kCardStackViewHeight);
            self.thirdAniView.transform = CGAffineTransformMakeScale(0.90, 0.90);
            
            self.panState = CardAnimationViewStateDefault;
        }];
    } else if (self.panState == CardAnimationViewStateLast) {
        [UIView animateWithDuration:0.3 animations:^{
            self.lastAniView.transform = CGAffineTransformIdentity;
            self.lastAniView.alpha = 1;
            
            self.mainAniView.transform = CGAffineTransformMakeScale(0.95, 0.95 );
            self.mainAniView.transform = CGAffineTransformTranslate(self.mainAniView.transform, 0, -kCardStackTopMargin);
            
            self.secAniView.transform = CGAffineTransformMakeScale(0.90, 0.90);
            self.secAniView.transform = CGAffineTransformTranslate(self.secAniView.transform, 0, -kCardStackTopMargin);
            
        } completion:^(BOOL finished) {
            [self.thirdAniView removeFromSuperview];
            self.thirdAniView = nil;
            
            self.thirdAniView = self.secAniView;
            self.secAniView = self.mainAniView;
            self.mainAniView = self.lastAniView;
            
            self.mainAniView.transform = CGAffineTransformIdentity;
            self.secAniView.transform = CGAffineTransformIdentity;
            self.thirdAniView.transform = CGAffineTransformIdentity;
            
            self.mainAniView.frame = CGRectMake(0, kCardStackOriginY, kCardStackViewWidth, kCardStackViewHeight);
            self.secAniView.frame = CGRectMake(0, kCardStackOriginY - kCardStackTopMargin, kCardStackViewWidth, kCardStackViewHeight);
            self.secAniView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            
            self.thirdAniView.frame = CGRectMake(0, kCardStackOriginY - kCardStackTopMargin * 2, kCardStackViewWidth, kCardStackViewHeight);
            self.thirdAniView.transform = CGAffineTransformMakeScale(0.90, 0.90);
            
            self.panState = CardAnimationViewStateDefault;
        }];
        
    }
    
    
}

- (void)cancelPan {
    if (self.panState == CardAnimationViewStateNext) {
        [UIView animateWithDuration:0.3 animations:^{
            self.mainAniView.transform = CGAffineTransformIdentity;
            self.mainAniView.alpha = 1;
            self.secAniView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            self.thirdAniView.transform = CGAffineTransformMakeScale(0.90, 0.90);
            
        }];
    } else if (self.panState == CardAnimationViewStateLast)  {
        [UIView animateWithDuration:0.3 animations:^{
            self.lastAniView.alpha = 0;
            CGAffineTransform transform = CGAffineTransformTranslate(self.mainAniView.transform, -kCardAnimationTranslateX, 0);
            
            CGFloat angel = M_PI / 6.0 * -1;
            CGFloat rotationAngel = angel * (1) ;
            CGAffineTransform transform1 = CGAffineTransformRotate(transform,rotationAngel);
            self.lastAniView.transform = transform1;
            
            self.mainAniView.transform = CGAffineTransformMakeScale(1, 1 );
            
            self.secAniView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            
        } completion:^(BOOL finished) {
            [self.lastAniView removeFromSuperview];
            self.lastAniView = nil;
            
            self.panState = CardAnimationViewStateDefault;
        }];
    }
    
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    UIView *view = gestureRecognizer.view;
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:view];
        CGFloat absX = fabs(translation.x);
        CGFloat absY = fabs(translation.y);
        if (absX > absY ) {
            if (translation.x<0) {//向左滑动
            }else{//向右滑动
            }
            return YES;
        } else if (absY > absX) {
            if (translation.y<0) {//向上滑动
                return NO;
            }else{ //向下滑动
                return NO;
            }
        }
    }
    
    return YES;
}

- (CardStackAnimationCell *)mainAniView {
    if (!_mainAniView) {
        _mainAniView = [[CardStackAnimationCell alloc] init];
    }
    return _mainAniView;
}

- (CardStackAnimationCell *)secAniView {
    if (!_secAniView) {
        _secAniView = [[CardStackAnimationCell alloc] init];
    }
    return _secAniView;
}

- (CardStackAnimationCell *)thirdAniView {
    if (!_thirdAniView) {
        _thirdAniView = [[CardStackAnimationCell alloc] init];
    }
    return _thirdAniView;
}
@end
