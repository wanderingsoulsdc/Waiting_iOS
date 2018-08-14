//
//  LiteShowBorderCardsView.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/2.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteShowBorderCardsView.h"

NSString *const CellIdentifier = @"CellIdentifier";

CGFloat const HorizontalMargin = 15.0;

CGFloat const ItemMargin = 7.0;

@interface LiteShowBorderCardsView ()<UICollectionViewDataSource, UICollectionViewDelegate,LiteShowBorderCardsCellDelegate>
{
    NSInteger currentIndex;
}
@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) UIScrollView *panScrollView;

@property(nonatomic, assign, getter=isMultiplePages) BOOL multiplePage;

@property(nonatomic, strong) NSTimer *timer;


@end

@implementation LiteShowBorderCardsView

- (instancetype)initWithFrame:(CGRect)frame

{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setupView];
        
    }
    
    return self;
    
}

- (void)setupView {
    
    currentIndex = 0;
    
    CGFloat collectionViewWidth = self.frame.size.width;
    
    CGFloat collectionViewHeight = self.frame.size.height;
    
    CGFloat itemWidth = collectionViewWidth - HorizontalMargin * 2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(itemWidth, collectionViewHeight);
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    layout.minimumLineSpacing = ItemMargin;
    
    layout.sectionInset = UIEdgeInsetsMake(0, HorizontalMargin, 0, HorizontalMargin);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, collectionViewWidth, collectionViewHeight) collectionViewLayout:layout];
    
    [self addSubview:collectionView];
    
    _collectionView = collectionView;
    
    collectionView.backgroundColor = [UIColor clearColor];
    
    collectionView.showsHorizontalScrollIndicator = NO;
    
    collectionView.alwaysBounceHorizontal = YES;
    
    collectionView.clipsToBounds = NO;
    collectionView.dataSource = self;
    
    collectionView.delegate = self;
    [collectionView registerClass:[LiteShowBorderCardsCell class] forCellWithReuseIdentifier:CellIdentifier];
    CGFloat pageScrollWidth = itemWidth + ItemMargin;
    
    _panScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((collectionView.frame.size.width - pageScrollWidth)/2, 0, pageScrollWidth, collectionViewHeight)];
    [self addSubview:_panScrollView];
    
    _panScrollView.hidden = YES;
    
    _panScrollView.showsHorizontalScrollIndicator = NO;
    
    _panScrollView.alwaysBounceHorizontal = YES;
    
    _panScrollView.pagingEnabled = YES;
    
    _panScrollView.delegate = self;
    [_collectionView addGestureRecognizer:_panScrollView.panGestureRecognizer];
    
    _collectionView.panGestureRecognizer.enabled = NO;
    
}

- (void)setDataArr:(NSArray *)dataArr {
    
    NSMutableArray *mutArr = [NSMutableArray arrayWithArray:dataArr];
    LiteDeviceModel *model = [[LiteDeviceModel alloc] init];
    model.deviceName = @"";
    [mutArr addObject:model];
    
    _dataArr = [mutArr copy];
    
    [self updateView];
    
}

- (void)updateView {
    
    [_collectionView reloadData];
    
//    [self addTimer];
    
}

- (void)addTimer {
    
    if (self.timer.isValid) {
        
        [self.timer invalidate];
        
    }
    self.timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)autoScroll {
    
    if (_dataArr.count <= 1) {
        
        return;
        
    }
    // 滚到最后一页的时候,回到第一页
    
    if (_panScrollView.contentOffset.x >= _panScrollView.frame.size.width * (_dataArr.count - 1)) {
        
        [_panScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    } else {
        
        [_panScrollView setContentOffset:CGPointMake(_panScrollView.contentOffset.x + _panScrollView.frame.size.width, 0) animated:YES];
        
    }
    
}
#pragma mark - common delegate

- (void)buttonAction:(CardsCellActionType)type deviceModel:(LiteDeviceModel *)deviceModel{
    if ([self.delegate respondsToSelector:@selector(CardsViewAction:deviceModel:)]) {
        switch (type) {
            case ActionTypeAddDevice:
                NSLog(@"cardView:点击cell里的添加按钮");
                [self.delegate CardsViewAction:ActionTypeAddDevice deviceModel:deviceModel];
                break;
            case ActionTypeDeviceName:
                NSLog(@"cardView:点击cell里的设备名称");
                [self.delegate CardsViewAction:ActionTypeDeviceName deviceModel:deviceModel];
                break;
            case ActionTypeLabelNum:
                NSLog(@"cardView:点击cell里的已创建标签按钮");
                [self.delegate CardsViewAction:ActionTypeLabelNum deviceModel:deviceModel];
                break;
            case ActionTypeBottom:
                NSLog(@"cardView:点击cell里的创建标签按钮");
                [self.delegate CardsViewAction:ActionTypeBottom deviceModel:deviceModel];
                break;
            default:
                break;
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    _panScrollView.contentSize = CGSizeMake(_panScrollView.frame.size.width * _dataArr.count, 0);
    
    return _dataArr.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LiteShowBorderCardsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    if (indexPath.item < _dataArr.count - 1) {
        
        LiteDeviceModel *model = _dataArr[indexPath.item];
        cell.type = typeDeviceExist;
        [cell configWithData:model];
    }else if(indexPath.item == _dataArr.count - 1){
        LiteDeviceModel *model = _dataArr[indexPath.item];
        cell.type = typeAddNewDevice;
        [cell configWithData:model];
    }
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _panScrollView) {
        
        _collectionView.contentOffset = _panScrollView.contentOffset;
        
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == _panScrollView) {
        
        CGFloat itemWidth = self.frame.size.width - HorizontalMargin * 2;
        
        NSInteger index = floor(_panScrollView.contentOffset.x /itemWidth);
        
        if (index != currentIndex) {
            if ([self.delegate respondsToSelector:@selector(CardsViewCurrentItem:)]) {
                [self.delegate CardsViewCurrentItem:index];
                currentIndex = index;
            }
        }
    }
}


@end
