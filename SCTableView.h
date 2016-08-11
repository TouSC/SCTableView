//
//  SCTableView.h
//  CentralChinaMerchant
//
//  Created by user on 15/4/23.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import <MJRefresh/MJRefresh.h>
#import "SCNetMethod.h"
#import <Masonry.h>

typedef id(^NetMethodBlock)(int curPage,NSString *serTime);

@protocol SCTableViewDelegate <NSObject>
@required
- (UITableViewCell *)tableView:(id)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle)setTableEditingStyle:(NSIndexPath*)indexPath;
- (void)editCell:(NSIndexPath*)indexPath;
- (void)tableView:(id)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didEndNetRequest:(NSArray* )contentArr returnArr:(NSArray* )basicArr;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface SCTableView : UITableView <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,assign)BOOL isRefreshNeeded;
@property(nonatomic,assign)BOOL isLoadNeeded;
@property(nonatomic,assign)BOOL isAutoLoadNeeded;
@property(nonatomic,copy)NetMethodBlock myNetBlock;
@property(nonatomic,weak)id<SCTableViewDelegate>myDelegate;
@property(nonatomic,assign)CGFloat cellHeight;//不设置则跟从cell高度
@property(nonatomic,assign)NSInteger otherCellCount;//不设置则和获取到数组数目相同
@property(nonatomic,copy)NSString *followFirstStrKey;//跟从第一次获取参数键(currentservertime,shopid...)
@property(nonatomic,copy)NSString *followFirstStrValue;//跟从第一次获取参数值
//如果获取回来是字典设置:
@property(nonatomic,strong)NSDictionary *contentDic;
@property(nonatomic,strong)NSString *keyForArr;
//如果获取回来是数组用它来获取数组:
@property(nonatomic,strong)NSMutableArray *contentArr;

@property(nonatomic,copy)NSString* lastPageStr;//最后一页的提示语

- (id)initWithFrame:(CGRect)frame NetBlock:(NetMethodBlock)netBlock;
- (void)refresh;//下拉刷新
- (void)silentRefresh;//静默刷新

@end

