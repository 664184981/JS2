//
//  HomeVC.m
//  JewelryStore
//
//  Created by McKee on 2017/9/3.
//  Copyright © 2017年 McKee. All rights reserved.
//

#import "HomeVC.h"
#import "BannerView.h"

@interface HomeVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BannerView *_bannerView;
    UITableView *_tv;
}

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if( [self respondsToSelector:@selector(setEdgesForExtendedLayout:)] )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _bannerView = [[BannerView alloc] initWithFrame:CGRectZero];
    _tv = [[UITableView alloc] initWithFrame:CGRectZero];
    _tv.backgroundColor = [UIColor clearColor];
    _tv.dataSource = self;
    _tv.delegate = self;
    _tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tv.tableHeaderView = _bannerView;
    [self.view addSubview:_tv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _tv.frame = self.view.bounds;
    
    CGRect frm = _tv.bounds;
    frm.size.height = [BannerView height];
    _bannerView.frame = frm;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
@end
