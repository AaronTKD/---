//
//  SelectAddressViewController.m
//  InsuranceAgent
//
//  Created by Lucky on 16/4/12.
//  Copyright © 2016年 geely. All rights reserved.
//

#import "SelectAddressViewController.h"

@interface SelectAddressViewController ()
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;//当前选中的NSIndexPath
@property (nonatomic,strong) NSMutableDictionary *provinceGroups;//存储分组好的城市
@property (nonatomic,strong) NSArray *groupTitles;
@end

@implementation SelectAddressViewController
-(void)viewDidLoad{
    [self configureData];
    [self makeCityToGroup];
    [self configureViews];
    
}
- (void)makeCityToGroup{
    _provinceGroups = [NSMutableDictionary new];
    _groupTitles = @[@"A",@"B",@"C",@"F",@"G",@"H",@"J",@"L",@"N",@"Q",@"S",@"T",@"X",@"Y",@"Z"];
    
    for (int i = 0; i < self.provinces.count; i ++) {
        NSDictionary *provinceDic = [self.provinces objectAtIndex:i];
        NSString *province = [provinceDic objectForKey:@"name"];
        //将中文转化为拼音
        NSMutableString *provinceMutableString = [[NSMutableString alloc] initWithString:province];
        CFStringTransform((__bridge CFMutableStringRef)provinceMutableString, 0, kCFStringTransformToLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)provinceMutableString, 0, kCFStringTransformStripDiacritics, NO);
        
        //拿到首字母作为key
        NSString *firstLetter = [provinceMutableString substringToIndex:1].uppercaseString;
        //检测是否有firstLetter对应的分组存在，有的话直接把province添加到对应的分组中
        //没有的话，新建一个以firstLetter为key的分组
        if ([[_provinceGroups allKeys] containsObject:firstLetter]) {
            NSMutableArray *tempArray = [_provinceGroups objectForKey:firstLetter];
            [tempArray addObject:provinceDic];
            [_provinceGroups setObject:tempArray forKey:firstLetter];
        }else{
            NSMutableArray *provinceArray = [NSMutableArray new];
            [provinceArray addObject:provinceDic];
            [_provinceGroups setObject:provinceArray forKey:firstLetter];
        }
        
    }
}
-(void)configureData{
    if (self.displayType == kDisplayProvince) {
        //从文件读取地址字典
        NSString *addressPath = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"plist"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithContentsOfFile:addressPath];
        self.provinces = [dict objectForKey:@"address"];
    }
}

-(void)configureViews{
    if (self.displayType == kDisplayProvince) { //只在选择省份页面显示取消按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    }
    if (self.displayType == kDisplayArea) {//只在选择区域页面显示确定按钮
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
    }
    CGRect frame = CGRectMake(0, 64, kControlWidth, kControlHeight-64);
    self.tableView = [[UITableView alloc]initWithFrame:frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.displayType == kDisplayProvince) {
        return _groupTitles.count;
    }else if (self.displayType == kDisplayCity){
        return 1;
    }else{
        return 1;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.displayType == kDisplayProvince) {
        NSString *firstLetter = [_groupTitles objectAtIndex:section];
        NSMutableArray *aimArray = [_provinceGroups objectForKey:firstLetter];
        return aimArray.count;
    }else if (self.displayType == kDisplayCity){
        return self.citys.count;
    }else{
        return self.areas.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* ID = @"cityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        if (self.displayType == kDisplayArea) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    if (self.displayType == kDisplayProvince) {
        NSString *firstLetter = _groupTitles[indexPath.section];
        NSArray *tempArray = _provinceGroups[firstLetter];
        NSDictionary *provinceDic = tempArray[indexPath.row];
        NSString *provinceName = provinceDic[@"name"];
        cell.textLabel.text= provinceName;
    }else if (self.displayType == kDisplayCity){
        NSDictionary *city = self.citys[indexPath.row];
        NSString *cityName = [city objectForKey:@"name"];
        cell.textLabel.text= cityName;
    }else{
        cell.textLabel.text= self.areas[indexPath.row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.displayType == kDisplayProvince) {
        NSString *firstLetter = _groupTitles[indexPath.section];
        NSArray *tempArray = _provinceGroups[firstLetter];
        NSDictionary *provinceDic = tempArray[indexPath.row];
        
        
        
        NSArray *citys = [provinceDic objectForKey:@"sub"];
        self.selectedProvince = [provinceDic objectForKey:@"name"];
        //构建下一级视图控制器
        SelectAddressViewController *cityVC = [[SelectAddressViewController alloc]init];
        cityVC.displayType = kDisplayCity;//显示模式为城市
        cityVC.citys = citys;
        cityVC.selectedProvince = self.selectedProvince;
        [self.navigationController pushViewController:cityVC animated:YES];
    }else if (self.displayType == kDisplayCity){
        NSDictionary *city = self.citys[indexPath.row];
        self.selectedCity = [city objectForKey:@"name"];
        NSArray *areas = [city objectForKey:@"sub"];
        //构建下一级视图控制器
        SelectAddressViewController *areaVC = [[SelectAddressViewController alloc]init];
        areaVC.displayType = kDisplayArea;//显示模式为区域
        areaVC.areas = areas;
        areaVC.selectedCity = self.selectedCity;
        areaVC.selectedProvince = self.selectedProvince;
        [self.navigationController pushViewController:areaVC animated:YES];
    }
    else{
        self.selectedArea = self.areas[indexPath.row];
        self.selectedIndexPath = indexPath;
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.displayType == kDisplayProvince) {
        return [_groupTitles objectAtIndex:section];
    }else{
        return nil;
    };
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.displayType == kDisplayProvince) {
        return _groupTitles;
    }else{
        return nil;
    };
    
}
-(void)submit{
    NSString *msg = [NSString stringWithFormat:@"%@-%@-%@",self.selectedProvince,self.selectedCity,self.selectedArea];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"选择地址" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
