//
//  SCTableView.m
//  CentralChinaMerchant
//
//  Created by user on 15/4/23.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import "SCTableView.h"

@implementation SCTableView
{
    BOOL hasScrolled;
    NSInteger curPage;
    NSString *curServerTime;
    dispatch_semaphore_t semaphore;
}

- (id)initWithFrame:(CGRect)frame NetBlock:(NetMethodBlock)netBlock;
{
    return [self initWithFrame:frame NetBlock:netBlock Style:UITableViewStylePlain];
}

- (id)initWithFrame:(CGRect)frame NetBlock:(NetMethodBlock)netBlock Style:(UITableViewStyle)style;
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        _isAutoLoadNeeded = YES;
        semaphore = dispatch_semaphore_create(1);
        _contentArr = [[NSMutableArray alloc]init];
        _myNetBlock = netBlock;
        curPage = 1;
        curServerTime = _followFirstStrValue? _followFirstStrValue:@"2000-01-01";
        self.delegate = self;
        self.dataSource = self;
        self.tableFooterView = [UIView new];
    }
    return self;
}

- (void)refresh;
{
    [self.mj_header beginRefreshing];
}

- (void)silentRefresh;
{
    [self headRefresh];
}
- (void)setIsRefreshNeeded:(BOOL)isRefreshNeeded;
{
    _isRefreshNeeded = isRefreshNeeded;
    if (isRefreshNeeded)
    {
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headRefresh)];
        header.lastUpdatedTimeLabel.hidden = YES;
        self.mj_header = header;
    }
    
}
- (void)setIsLoadNeeded:(BOOL)isLoadNeeded;
{
    _isLoadNeeded = isLoadNeeded;
    if (isLoadNeeded)
    {
        self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footLoad)];
    }
}
- (void)headRefresh;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        curPage = 1;
        curServerTime = _followFirstStrValue? _followFirstStrValue:@"2000-01-01";
        NSArray *basicArr;
        NSDictionary *basicDic;
        if (_keyForArr.length)
        {
            basicDic = (NSDictionary*)_myNetBlock((int)curPage,curServerTime);
            basicArr = [basicDic objectForKey:_keyForArr];
        }
        else
        {
            basicArr = _myNetBlock(1,curServerTime);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _contentDic = basicDic;
            [_contentArr removeAllObjects];
            if ([basicArr isKindOfClass:[NSArray class]]) {
                [_contentArr addObjectsFromArray:basicArr];
            }
            [self reloadData];
            [self.mj_header endRefreshing];
            curPage = 1;
            curServerTime = _followFirstStrValue? _followFirstStrValue:@"2000-01-01";
            if ([_myDelegate respondsToSelector:@selector(tableView:didEndNetRequest:returnArr:)])
            {
                [_myDelegate tableView:self didEndNetRequest:_contentArr returnArr:basicArr];
            }
            dispatch_semaphore_signal(semaphore);
        });
    });
}
- (void)footLoad;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        curPage++;
        if (_contentArr.count)
        {
            if ([_contentArr[0] isKindOfClass:[NSDictionary class]])
            {
                curServerTime = [_contentArr[0] objectForKey:_followFirstStrKey?:@"CurrentServerTime"];
            }
            else if([_contentArr[0] isKindOfClass:[NSArray class]])
            {
                NSArray* arr = _contentArr[0];
                if (arr.count)
                {
                    curServerTime = [_contentArr[0][0] objectForKey:_followFirstStrKey?:@"CurrentServerTime"];
                }
                else
                {
                    curServerTime = @"";
                }
            }
            if ([curServerTime isEqualToString:@""])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mj_footer endRefreshing];
                    curPage--;
                    dispatch_semaphore_signal(semaphore);
                    return ;
                });
            }
            else
            {
                NSArray *appendArr = _myNetBlock((int)curPage,curServerTime);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mj_footer endRefreshing];
                    
                    if ([appendArr isKindOfClass:[NSArray class]]&&(appendArr.count))
                    {
                        if ([appendArr[0] isKindOfClass:[NSDictionary class]])
                        {
                            [_contentArr addObjectsFromArray:appendArr];
                        }
                        else if([appendArr[0] isKindOfClass:[NSArray class]])
                        {
                            NSArray* arr = [appendArr firstObject];
                            if (arr.count)
                            {
                                NSMutableArray *newContentArr = [[NSMutableArray alloc]init];
                                for (NSDictionary *infoDic in _contentArr[0])
                                {
                                    [newContentArr addObject:infoDic];
                                }
                                for (NSDictionary *infoDic in appendArr[0])
                                {
                                    [newContentArr addObject:infoDic];
                                }
                                [_contentArr removeAllObjects];
                                [_contentArr addObject:newContentArr];
                            }
                            else
                            {
                                curPage--;
                                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
                                hud.labelText = @"已无更多";
                                hud.userInteractionEnabled = NO;
                                hud.mode = MBProgressHUDModeText;
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [hud hide:YES];
                                });
                            }
                        }
                        [self reloadData];
                    }
                    else if([appendArr isKindOfClass:[NSArray class]] && appendArr.count==0)
                    {
                        curPage--;
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
                        hud.labelText = @"已无更多";
                        hud.userInteractionEnabled = NO;
                        hud.mode = MBProgressHUDModeText;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [hud hide:YES];
                        });
                    }
                    if ([_myDelegate respondsToSelector:@selector(tableView:didEndNetRequest:returnArr:)])
                    {
                        [_myDelegate tableView:self didEndNetRequest:_contentArr returnArr:@[]];
                    }
                    dispatch_semaphore_signal(semaphore);
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mj_footer endRefreshing];
                curPage--;
                dispatch_semaphore_signal(semaphore);
            });
        }
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        return [_myDelegate tableView:self heightForRowAtIndexPath:indexPath];
    }
    else
    {
        return self.rowHeight;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        return [_myDelegate numberOfSectionsInTableView:self];
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section==tableView.numberOfSections-1)
    {
        return _contentArr.count+_otherCellCount;
    }
    else
    {
        if (_myDelegate&&[_myDelegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
        {
            return [_myDelegate tableView:self numberOfRowsInSection:section];
        }
        else
        {
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (hasScrolled==YES&&(indexPath.row>=_contentArr.count+_otherCellCount-1)&&(indexPath.section>=tableView.numberOfSections-1)&&_isLoadNeeded&&_isAutoLoadNeeded)
    {
        [self footLoad];
        hasScrolled = NO;
    }
    return [_myDelegate tableView:self cellForRowAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(setTableEditingStyle:)])
    {
        return [_myDelegate setTableEditingStyle:indexPath];
    }
    else return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
    {
        [_myDelegate tableView:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
    {
        [_myDelegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_myDelegate&&[_myDelegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
    {
        return  [_myDelegate tableView:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [_myDelegate tableView:self viewForHeaderInSection:section];
    }
    else
    {
        return nil;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [_myDelegate tableView:self viewForFooterInSection:section];
    }
    else
    {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [_myDelegate tableView:self heightForHeaderInSection:section];
    }
    else
    {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [_myDelegate tableView:self heightForFooterInSection:section];
    }
    else
    {
        return 0;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [_myDelegate tableView:self titleForHeaderInSection:section];
    }
    else
    {
        return nil;
    }
}

-(NSString* )tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_myDelegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)])
    {
        return [_myDelegate tableView:self titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    hasScrolled = YES;
    if ([_myDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [_myDelegate scrollViewWillBeginDragging:scrollView];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    hasScrolled = YES;
    if ([_myDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [_myDelegate scrollViewDidScroll:scrollView];
    }
}
@end
