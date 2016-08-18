//
//  SCTableView.h
//  CentralChinaMerchant
//
//  Created by user on 15/4/23.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefresh.h>
#import "SCNetMethod.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
@class SCTableView;

typedef id(^NetMethodBlock)(int curPage,NSString *serTime);

@protocol SCTableViewDelegate <NSObject>
@required
- (UITableViewCell *)tableView:(SCTableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSString *)tableView:(SCTableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle)setTableEditingStyle:(NSIndexPath*)indexPath;
- (void)editCell:(NSIndexPath*)indexPath;
- (void)tableView:(SCTableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(SCTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(SCTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableView:(SCTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(SCTableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(SCTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(SCTableView *)tableView heightForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(SCTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(SCTableView *)tableView;
- (NSInteger)tableView:(SCTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)tableView:(SCTableView *)tableView didEndNetRequest:(NSArray* )contentArr returnArr:(NSArray* )basicArr;
- (NSString *)tableView:(SCTableView *)tableView titleForHeaderInSection:(NSInteger)section;
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

- (id)initWithFrame:(CGRect)frame NetBlock:(NetMethodBlock)netBlock;
- (id)initWithFrame:(CGRect)frame NetBlock:(NetMethodBlock)netBlock Style:(UITableViewStyle)style;
- (void)refresh;//下拉刷新
- (void)silentRefresh;//静默刷新

@end

