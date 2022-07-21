//
//  BQChatRecordImageVideoViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/11.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "BQChatRecordImageVideoViewController.h"
#import "BQRecordImageVideoCell.h"

@interface BQChatRecordImageVideoViewController ()<MISScrollPageControllerContentSubViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>


@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, strong) NSString *moreMsgId;


@end

@implementation BQChatRecordImageVideoViewController

- (instancetype)initWithCoversationModel:(EMConversation *)conversation
{
    if (self = [super init]) {
        _conversation = conversation;
        _msgQueue = dispatch_queue_create("emmessagerecord.com", NULL);
        _moreMsgId = @"";
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
#if kJiHuApp
    self.view.backgroundColor = ViewBgBlackColor;
    self.collectionView.backgroundColor = ViewBgBlackColor;
#else
    self.view.backgroundColor = ViewBgWhiteColor;
    self.collectionView.backgroundColor = ViewBgWhiteColor;
#endif

    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self loadDatas];
}

- (void)loadDatas {
    
    if ([EMDemoOptions sharedOptions].isPriorityGetMsgFromServer) {
        EMConversation *conversation = self.conversation;
        [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:conversation.conversationId conversationType:conversation.type startMessageId:self.moreMsgId pageSize:10 completion:^(EMCursorResult *aResult, EMError *aError) {
            [self.conversation loadMessagesStartFromId:self.moreMsgId count:100 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError) {
                [self loadMessages:aMessages withError:aError];
            }];
         }];
    } else {
        [self.conversation loadMessagesStartFromId:self.moreMsgId count:50 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray<EMChatMessage *> * _Nullable aMessages, EMError * _Nullable aError) {
            [self loadMessages:aMessages withError:aError];
        }];
    }
}


- (void)loadMessages:(NSArray *)aMessages  withError:(EMError *)aError {
    if (!aError && [aMessages count] > 0) {
        dispatch_async(self.msgQueue, ^{
            NSMutableArray *msgArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [aMessages count]; i++) {
                EMChatMessage *msg = aMessages[i];
                if(msg.body.type == EMMessageBodyTypeImage) {
                    [msgArray addObject:msg];
                }
                
                if(msg.body.type == EMMessageBodyTypeVideo) {
                    [msgArray addObject:msg];
                }

            }
            
            BQ_WS
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:msgArray];
                [weakSelf.collectionView reloadData];
            });
        });
    }
    
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    BQRecordImageVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BQRecordImageVideoCell reuseIdentifier] forIndexPath:indexPath];
    
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    [cell updateWithObj:obj];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[BQRecordImageVideoCell class] forCellWithReuseIdentifier:[BQRecordImageVideoCell reuseIdentifier]];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
    
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGFloat itemWidth = (KScreenWidth - 10.0 * 3 - 16.0 * 2)/4.0;
    CGFloat itemHeight = itemWidth;
    
    flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 16.0, 10.0, 16.0);
    
    return flowLayout;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}


#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{

}

- (void)viewDidAppearForIndex:(NSUInteger)index{
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    self.editing = NO;
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    
}

@end
