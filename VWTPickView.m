//
//  VWTPickView.m
//  DaZhongChuXing
//
//  Created by 莎莎 on 16/4/25.
//  Copyright © 2016年 tony. All rights reserved.
//

#import "VWTPickView.h"
#import "Macro.h"
#import "AddressFMDBManager.h"
#import "ProvinceAddressModel.h"
#import "CityAddressModel.h"
#import "DistrictModel.h"

#define SCREENSIZE UIScreen.mainScreen.bounds.size
#define HeadHeight 40
@implementation VWTPickView
{
   UIView *bgView;
   NSArray *proTitleList;
   NSString *selectedStr;
   
   NSMutableArray *province;
   NSMutableArray *city;
   NSMutableArray *district;

   BOOL isDate;
}
@synthesize block;

- (instancetype)initWithFrame:(CGRect)frame{
   self = [super initWithFrame:frame];
   isDate = NO;
   return self;
}
- (void)showPickView:(UIViewController *)vc
{
   bgView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
   bgView.backgroundColor = [UIColor blackColor];
   bgView.alpha = 0.3f;
   [vc.view addSubview:bgView];
   
   CGRect frame = self.frame;
   self.frame = CGRectMake(0,SCREENSIZE.height + frame.size.height, SCREENSIZE.width, frame.size.height);
   [vc.view addSubview:self];
   [UIView animateWithDuration:0.5f
                    animations:^{
                       self.frame = frame;
                       [self layoutIfNeeded];
                    }
                    completion:nil];
}
- (void)hide
{
   [bgView removeFromSuperview];
   [self removeFromSuperview];
}

//基础控件的初始化
-(void)initSubViews:(NSString *)title
{
    UIDatePicker *datePickr = [[UIDatePicker alloc] init];
   
   self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, datePickr.frame.size.height+40)];
   [self addSubview:self.contentView];
   
   UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, HeadHeight)];
   header.backgroundColor = [UIColor whiteColor];
   UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, SCREENSIZE.width - 80, HeadHeight)];
   titleLbl.text = title;
   titleLbl.textAlignment = NSTextAlignmentCenter;
   titleLbl.backgroundColor = [UIColor whiteColor];
   titleLbl.textColor = UIColorFromHex(@"#575859");
   titleLbl.font = [UIFont systemFontOfSize:16.0f];
   [header addSubview:titleLbl];
   
   UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(SCREENSIZE.width - 50, 10, 50 ,29.5)];
   [submit setTitle:@"确定" forState:UIControlStateNormal];
   [submit setTitleColor:UIColorFromHex(@"#ff7d44") forState:UIControlStateNormal];
   submit.backgroundColor = [UIColor whiteColor];
   submit.titleLabel.font = [UIFont systemFontOfSize:15.0f];
   [submit addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
   [header addSubview:submit];
   
   UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 50 ,29.5)];
   [cancel setTitle:@"取消" forState:UIControlStateNormal];
   [cancel setTitleColor: UIColorFromHex(@"#b2b2bc") forState:UIControlStateNormal];
   cancel.backgroundColor =[UIColor whiteColor];
   cancel.titleLabel.font = [UIFont systemFontOfSize:15.0f];
   [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
   [header addSubview:cancel];
   
   [self.contentView addSubview:header];
}
- (void)startAnimation
{
//   self.contentView.transform = CGAffineTransformMakeTranslation(0,kScreenHeight);
//   [UIView animateWithDuration:0.5 animations:^{
//      self.contentView.transform = CGAffineTransformIdentity;
//   }];
}
//类型显示为时间的
- (void)setDateViewWithTitle:(NSString *)title selectedItem:(NSString *)item
{
   isDate = YES;
   proTitleList = @[];
  
   [self initSubViews:title];
   
   UIDatePicker *datePickr = [[UIDatePicker alloc] init];
   
   datePickr.frame = CGRectMake(0, 40, SCREENSIZE.width, datePickr.frame.size.height);
   datePickr.backgroundColor = [UIColor whiteColor];
   
   // 1.3设置datePickr的地区语言, zh_Han后面是s的就为简体中文,zh_Han后面是t的就为繁体中文
   [datePickr setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"]];
   
   datePickr.datePickerMode = UIDatePickerModeDate;
   [datePickr  setTimeZone:[NSTimeZone defaultTimeZone]];
   //[self.datePickView setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
   NSDate *nowTime  = [NSDate date];
   NSDate *startTime=[NSDate date];
   NSDate *endTime=[NSDate date];
   NSCalendar *cal = [NSCalendar currentCalendar];
   unsigned int unitFlags = NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
   NSDateComponents *dd = [cal components:unitFlags fromDate:nowTime];
   if([dd minute] !=0){
      startTime=[nowTime dateByAddingTimeInterval:(4*10*60)];
   }else{
      startTime=[nowTime dateByAddingTimeInterval:(3*10*60)];
   }
   endTime=[startTime dateByAddingTimeInterval:(24*60*60)];
   // 设置当前显示
   if (item.length != 0)
   {
      selectedStr = item;
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      NSDate *itemDate = [formatter dateFromString:item];
       [datePickr setDate:itemDate animated:YES];
      
   }else
   {
     [datePickr setDate:startTime animated:YES];
   }
   
   // 设置显示最小时间（
   [datePickr setMinimumDate:startTime];
   // 设置显示最大时间（
   [datePickr setMaximumDate:endTime];
   // 显示模式
   [datePickr setDatePickerMode:UIDatePickerModeDateAndTime];
   datePickr.minuteInterval=10;
   
   
   [datePickr addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
   
//   NSDate *date = [NSDate date];
//   
//   // 2.3 将转换后的日期设置给日期选择控件
//   [datePickr setDate:date];
//   
   [self.contentView addSubview:datePickr];
   
   float height = datePickr.frame.size.height;
   self.frame = CGRectMake(0, SCREENSIZE.height - height, SCREENSIZE.width, height);
}
//显示单独的一行
- (void)setDataViewWithItem:(NSArray *)items title:(NSString *)title selectedItem:(NSString *)item
{
   isDate = NO;
   proTitleList = items;

   [self initSubViews:title];
   
   UIPickerView *pick = [[UIPickerView alloc] init];
   pick.tag = 10086;
   pick.frame =CGRectMake(0, 40, SCREENSIZE.width, pick.frame.size.height);
   pick.delegate = self;
   pick.backgroundColor = [UIColor whiteColor];
   [self addSubview:pick];
   
   int currentIndex = 0;
   for (int i=0; i<proTitleList.count; i++) {
      if([item isEqualToString:[items objectAtIndex:i]]){
         currentIndex=i;
         break;
      }
   }
   selectedStr = item;
   [pick selectRow:currentIndex inComponent: 0 animated: YES];
   
   
   float height = pick.frame.size.height;
   self.frame = CGRectMake(0, SCREENSIZE.height - height, SCREENSIZE.width, height);
}
//显示城市列表
- (void)setDataCityWithTitle:(NSString *)title address:(NSString *)address
{
   province=[[NSMutableArray alloc] initWithCapacity:5];
   city=[[NSMutableArray alloc] initWithCapacity:5];
   district=[[NSMutableArray alloc] initWithCapacity:5];
   
   AddressFMDBManager *addFMDBManager=[AddressFMDBManager sharedAddressFMDBManager];
   
   //得到省份的model数组
   NSArray *arr=[NSArray arrayWithArray:[addFMDBManager selectAllProvince]];
   for (ProvinceAddressModel *provinceModel in arr) {
      [province addObject:provinceModel.name];
   }
   
   //得到市的model的数组
   NSArray *arr2=[NSArray arrayWithArray:[addFMDBManager selectAllCityFrom:1]];
   
   for (CityAddressModel *cityModel in arr2) {
      [city addObject:cityModel.name];
   }
   
   //得到区的model的数组
   NSArray *arr3=[NSArray arrayWithArray:[addFMDBManager selectAllDistrictFrom:1]];
   for (DistrictModel *districtModel in arr3) {
      [district addObject:districtModel.name];
   }
   isDate = NO;
   [self initSubViews:title];
   
   UIPickerView *pick = [[UIPickerView alloc] init];
   pick.tag = 10010;
   pick.frame =CGRectMake(0, 40, SCREENSIZE.width, pick.frame.size.height);

   pick.dataSource = self;
   pick.delegate = self;
   pick.showsSelectionIndicator = YES;
   [pick selectRow: 0 inComponent: 0 animated: YES];
   pick.backgroundColor=[UIColor whiteColor];
   [self addSubview:pick];
   
   float height = pick.frame.size.height;
   self.frame = CGRectMake(0, SCREENSIZE.height - height, SCREENSIZE.width, height);
   
   if(address==0){
      [self p_selectCityData:@"上海 上海 黄浦区" pick:pick];
      selectedStr = @"上海 上海 黄浦区";
   }else{
      [self p_selectCityData:address pick:pick];
      selectedStr = address;
   }
}

-(void)p_selectCityData :(NSString *)strCity pick:(UIPickerView *)picker{//选择默认城市
   AddressFMDBManager *addFMDBManager=[AddressFMDBManager sharedAddressFMDBManager];
   
   NSArray *arr=[strCity componentsSeparatedByString:@" "];
   NSString *provinceStr=[arr objectAtIndex:0];
   NSInteger provinceInt=[addFMDBManager selectProvinceIdFrom:provinceStr];
   
   NSString *cityStr=[arr objectAtIndex:1];
   NSInteger cityInt=[addFMDBManager selectIdFromCityWith:cityStr];
   
   NSString *districtStr=[arr objectAtIndex:2];
   NSInteger districtInt=[addFMDBManager selectIdDistrictFrom:districtStr];
   
   //得到市的model的数组
   [city removeAllObjects];
   NSArray *arr2=[NSArray arrayWithArray:[addFMDBManager selectAllCityFrom:provinceInt]];
   for (CityAddressModel *cityModel in arr2) {
      [city addObject:cityModel.name];
   }
   //得到区的model的数组
   [district removeAllObjects];
   NSArray *arr3=[NSArray arrayWithArray:[addFMDBManager selectAllDistrictFrom:cityInt]];
   for (DistrictModel *districtModel in arr3) {
      [district addObject:districtModel.name];
   }
   
   for (int i=0; i<city.count; i++) {
      if([cityStr isEqualToString:[city objectAtIndex:i]]){
         cityInt=i;
         break;
      }
   }
   for (int i=0; i<district.count; i++) {
      if([districtStr isEqualToString:[district objectAtIndex:i]]){
         districtInt=i;
         break;
      }
   }
   
   [picker reloadAllComponents];
   
   [picker selectRow: provinceInt-1 inComponent: 0 animated: YES];
   [picker selectRow: cityInt inComponent: 1 animated: YES];
   [picker selectRow: districtInt inComponent: 2 animated: YES];
   //[picker reloadComponent: CITY_COMPONENT];
   //[picker reloadComponent: DISTRICT_COMPONENT];
   //[picker reloadAllComponents];
}


#pragma mark DatePicker监听方法
- (void)dateChanged:(UIDatePicker *)datePicker
{
   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   
   [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   
   selectedStr = [formatter stringFromDate:datePicker.date];
}
- (void)cancel:(UIButton *)btn
{
   [self hide];
   
}
- (void)submit:(UIButton *)btn
{
   NSString *pickStr = selectedStr;
   if (!pickStr || pickStr.length == 0) {
      if(isDate) {
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         selectedStr = [formatter stringFromDate:[NSDate date]];
      } else {
         if([proTitleList count] > 0) {
            selectedStr = proTitleList[0];
         }
         
      }
   }
   block(selectedStr);
   [self hide];
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
   if (pickerView.tag == 10010)
   {
      return 3;
   }
   return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
   if (pickerView.tag == 10010)
   {
      if (component == PROVINCE_COMPONENT) {
         return [province count];
      }
      else if (component == CITY_COMPONENT) {
         return [city count];
      }
      else {
         return [district count];
      }
   }
   return [proTitleList count];
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   if (pickerView.tag == 10010)
   {
      if (component == PROVINCE_COMPONENT) {
       //  selectedProvince = [province objectAtIndex: row];
         
         AddressFMDBManager *addFMDBManager=[AddressFMDBManager sharedAddressFMDBManager];
         
         [city removeAllObjects];
         //得到市的model的数组
         NSArray *arr2=[NSArray arrayWithArray:[addFMDBManager selectAllCityFrom:row+1]];
         for (CityAddressModel *cityModel in arr2) {
            [city addObject:cityModel.name];
         }
         
         //获取城市id
         NSInteger cityId=[addFMDBManager selectIdFromCityWith:[city objectAtIndex:0]];
         
         NSLog(@"城市id为:::%ld",(long)cityId);
         [district removeAllObjects];
         //得到区的model的数组
         NSArray *arr3=[NSArray arrayWithArray:[addFMDBManager selectAllDistrictFrom:cityId]];
         for (DistrictModel *districtModel in arr3) {
            [district addObject:districtModel.name];
         }
         
         [pickerView selectRow: 0 inComponent: CITY_COMPONENT animated: YES];
         [pickerView selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
         [pickerView reloadComponent: CITY_COMPONENT];
         [pickerView reloadComponent: DISTRICT_COMPONENT];
         //        [picker reloadAllComponents];
         
      }
      else if (component == CITY_COMPONENT) {
         //        NSInteger *provinceIndex = [province indexOfObject: selectedProvince];
         AddressFMDBManager *addFMDBManager=[AddressFMDBManager sharedAddressFMDBManager];
         NSString *cityName=[city objectAtIndex:row];
         NSInteger cityId=[addFMDBManager selectIdFromCityWith:cityName];
         NSLog(@"====%@",cityName);
         [district removeAllObjects];
         //得到区的model的数组
         NSArray *arr3=[NSArray arrayWithArray:[addFMDBManager selectAllDistrictFrom:cityId]];
         for (DistrictModel *districtModel in arr3) {
            [district addObject:districtModel.name];
         }
         [pickerView selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
         [pickerView reloadComponent: DISTRICT_COMPONENT];
      }
      
      NSInteger provinceIndex = [pickerView selectedRowInComponent: PROVINCE_COMPONENT];
      NSInteger cityIndex = [pickerView selectedRowInComponent: CITY_COMPONENT];
      NSInteger districtIndex = [pickerView selectedRowInComponent: DISTRICT_COMPONENT];
      
      NSString *provinceStr = [province objectAtIndex: provinceIndex];
      NSString *cityStr = [city objectAtIndex: cityIndex];
      NSString *districtStr = [district objectAtIndex:districtIndex];
       selectedStr =[NSString stringWithFormat:@"%@ %@ %@",provinceStr,cityStr,districtStr];
   }
   else
   {
      selectedStr = [proTitleList objectAtIndex:row];
   }
   
   
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
//-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//   if (pickerView.tag == 10010)
//   {
//      if (component == PROVINCE_COMPONENT) {
//         return [province objectAtIndex: row];
//      }
//      else if (component == CITY_COMPONENT) {
//         return [city objectAtIndex: row];
//      }
//      else {
//         return [district objectAtIndex: row];
//      }
//   }
//   return [proTitleList objectAtIndex:row];
//   
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
   UILabel *myView = nil;
   if (pickerView.tag == 10010)
   {
      
      if (component == PROVINCE_COMPONENT) {
         myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 44)];
         myView.textAlignment = NSTextAlignmentCenter;
         myView.text = [province objectAtIndex:row];
         myView.font = [UIFont systemFontOfSize:18];
         myView.backgroundColor = [UIColor clearColor];
      }
      else if (component == CITY_COMPONENT) {
         myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120, 44)];
         myView.textAlignment = NSTextAlignmentCenter;
         myView.text = [city objectAtIndex:row];
         myView.font = [UIFont systemFontOfSize:18];
         myView.backgroundColor = [UIColor clearColor];
      }
      else {
         myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120, 44)];
         myView.textAlignment = NSTextAlignmentCenter;
         myView.text = [district objectAtIndex:row];
         myView.font = [UIFont systemFontOfSize:18];
         myView.backgroundColor = [UIColor clearColor];
      }
   }
   else
   {
      myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 44)];
      myView.textAlignment = NSTextAlignmentCenter;
      myView.text = [proTitleList objectAtIndex:row];
      myView.font = [UIFont systemFontOfSize:18];
      myView.backgroundColor = [UIColor clearColor];
   }
   
   return myView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
