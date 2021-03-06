//
//  EmojiButtonView.m
//  KeyBoard
//
//  Created by ShaoFeng on 16/8/18.
//  Copyright © 2016年 Cocav. All rights reserved.
//
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

#import "EmojiButtonView.h"
#import "CollectionViewFlowLayout.h"
#import "EmojiCollectionViewCell.h"
#import "UIView+Extension.h"
#import "EmotionImages.h"

@interface EmojiButtonView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong)UIView *emojiFooterView;
@property (nonatomic,strong)UIScrollView *emojiFooterScrollView;
@property (nonatomic,strong)UIPageControl *pageControl;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)UIButton *sendButton;
@property (nonatomic,strong)UIButton *emojiButotn;
@property (nonatomic,strong)UIButton *emojiImageButotn;
@property (nonatomic,strong)CollectionViewFlowLayout *layout;
@property (nonatomic,strong)NSMutableArray *defaultEmoticons;
@property (nonatomic,strong)NSArray *emoticonImages;
@end

@implementation EmojiButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _defaultEmoticons = [NSMutableArray array];
        _emoticonImages = [NSMutableArray array];
        [[EmotionImages shareEmotinImages] initEmotionImages];
        _emoticonImages = [EmotionImages shareEmotinImages].images;
        
        for (int i=0x1F600; i<=0x1F64F; i++) {
            if (i < 0x1F641 || i > 0x1F640) {
                int sym = EMOJI_CODE_TO_SYMBOL(i);
                NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
                [_defaultEmoticons addObject:emoT];
            }
        }
        
        [_defaultEmoticons addObjectsFromArray:[EmotionImages shareEmotinImages].images];

        for (NSInteger i = 0;i < _defaultEmoticons.count;i ++) {
            if (i == 20 || i == 41 || i == 62 || i == 83 || i == 104 || i == 125 || i == 146 || i == 167) {
                [_defaultEmoticons insertObject:deleteButtonId atIndex:i];
            }
        }
        if (self.defaultEmoticons.count % 21 != 0) {
            for (NSInteger i = self.defaultEmoticons.count; i < self.defaultEmoticons.count + 21; i ++) {
                [self.defaultEmoticons addObject:@""];
                if (self.defaultEmoticons.count % 21 == 0) {
                    break;
                }
            }
        }
        [self.defaultEmoticons replaceObjectAtIndex:self.defaultEmoticons.count - 1 withObject:deleteButtonId];
        self.backgroundColor = [UIColor colorWithRed:243 / 255.0 green:243 / 255.0 blue:243 / 255.0 alpha:1];
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI
{
    self.emojiFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, SCREEN_WIDTH, 40)];
    self.emojiFooterView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.emojiFooterView];
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 5 * 4, 0, SCREEN_WIDTH / 5, 40)];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.sendButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(clickSenderButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiFooterView addSubview:self.sendButton];
    
    self.emojiFooterScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - (SCREEN_WIDTH / 5) - 1, self.emojiFooterView.height)];
    self.emojiFooterScrollView.showsHorizontalScrollIndicator = NO;
    self.emojiFooterScrollView.showsVerticalScrollIndicator = NO;
    self.emojiFooterScrollView.contentSize = CGSizeMake(SCREEN_WIDTH - (SCREEN_WIDTH / 5), self.emojiFooterView.height);
    [self.emojiFooterView addSubview:self.emojiFooterScrollView];
    
    self.emojiButotn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 6, 40)];
    [self.emojiButotn setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_nor"] forState:UIControlStateNormal];
    [self.emojiButotn setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_press"] forState:UIControlStateSelected];
    [self.emojiButotn addTarget:self action:@selector(clickEmojiButton) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiFooterScrollView addSubview:self.emojiButotn];
    self.emojiButotn.selected = YES;
    
    self.emojiImageButotn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 6, 0, SCREEN_WIDTH / 6, 40)];
    [self.emojiImageButotn setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_nor"] forState:UIControlStateNormal];
    [self.emojiImageButotn setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_press"] forState:UIControlStateSelected];
    [self.emojiImageButotn addTarget:self action:@selector(clickEmojiImageButton) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiFooterScrollView addSubview:self.emojiImageButotn];
    self.emojiImageButotn.selected = NO;
    
    self.layout = [[CollectionViewFlowLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130) collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor colorWithRed:243 / 255.0 green:243 / 255.0 blue:243 / 255.0 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[EmojiCollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 140, 0, 10)];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.userInteractionEnabled = NO;
    
    self.pageControl.numberOfPages = (self.defaultEmoticons.count - self.emoticonImages.count) / 21;
    [self addSubview:self.pageControl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        if (scrollView.contentOffset.x >= SCREEN_WIDTH * ((self.defaultEmoticons.count - self.emoticonImages.count) / 21)) {
            self.pageControl.numberOfPages = self.emoticonImages.count % 21 == 0 ? self.emoticonImages.count % 21 : self.emoticonImages.count % 21 + 1 ;
            self.pageControl.currentPage = ((scrollView.contentOffset.x - SCREEN_WIDTH * ((self.defaultEmoticons.count - self.emoticonImages.count) / 21)) / SCREEN_WIDTH);
            self.emojiButotn.selected = NO;
            self.emojiImageButotn.selected = YES;
            
        } else {
            self.pageControl.numberOfPages = (self.defaultEmoticons.count - self.emoticonImages.count) / 21;
            self.pageControl.currentPage = (scrollView.contentOffset.x / SCREEN_WIDTH);
            self.emojiButotn.selected = YES;
            self.emojiImageButotn.selected = NO;
        }
    }
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.defaultEmoticons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    if ([self.defaultEmoticons[indexPath.row] isKindOfClass:[UIImage class]]) {
        cell.image = self.defaultEmoticons[indexPath.row];
    } else {
        cell.string = self.defaultEmoticons[indexPath.row];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *str = self.defaultEmoticons[indexPath.row];
    if (str) {
        if ([_delegate respondsToSelector:@selector(emojiButtonView:emojiText:)]) {
            [_delegate emojiButtonView:self emojiText:str];
        }
    }
}

- (void)clickEmojiButton
{
    self.emojiButotn.selected = YES;
    self.emojiImageButotn.selected = NO;
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:0];
    self.pageControl.numberOfPages = (self.defaultEmoticons.count - self.emoticonImages.count) / 21;
    self.pageControl.currentPage = (self.collectionView.contentOffset.x / SCREEN_WIDTH);
}

- (void)clickEmojiImageButton
{
    self.emojiButotn.selected = NO;
    self.emojiImageButotn.selected = YES;
    [self.collectionView setContentOffset:CGPointMake(SCREEN_WIDTH * 4, 0) animated:0];
    self.pageControl.numberOfPages = self.emoticonImages.count % 21 == 0 ? self.emoticonImages.count % 21 : self.emoticonImages.count % 21 + 1 ;
    self.pageControl.currentPage = ((self.collectionView.contentOffset.x - SCREEN_WIDTH * ((self.defaultEmoticons.count - self.emoticonImages.count) / 21)) / SCREEN_WIDTH);
}

- (void)clickSenderButton:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(emojiButtonView:sendButtonClick:)]) {
        [_delegate emojiButtonView:self sendButtonClick:sender];
    }
}

@end
