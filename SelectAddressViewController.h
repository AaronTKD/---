//
//  SelectAddressViewController.h
//  InsuranceAgent
//
//  Created by Lucky on 16/4/12.
//  Copyright © 2016年 geely. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kDisplayProvince 0
#define kDisplayCity 1
#define kDisplayArea 2
@interface SelectAddressViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *navigationViewTitleLabel;

@property(nonatomic,assign)int displayType;
@property(nonatomic,strong)NSArray *provinces;
@property(nonatomic,strong)NSArray *citys;
@property(nonatomic,strong)NSArray *areas;
@property(nonatomic,strong)NSString *selectedProvince;//选中的省
@property(nonatomic,strong)NSString *selectedCity;//选中的市
@property(nonatomic,strong)NSString *selectedArea;//选中的区
@end
