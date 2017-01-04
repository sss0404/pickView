//
//  VWTPickView.h
//  DaZhongChuXing
//
//  Created by 莎莎 on 16/4/25.
//  Copyright © 2016年 tony. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PROVINCE_COMPONENT  0
#define CITY_COMPONENT      1
#define DISTRICT_COMPONENT  2


@class VWTPickView;
typedef void (^HLPickViewSubmit)(NSString*);
@interface VWTPickView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

- (void)setDateViewWithTitle:(NSString *)title selectedItem:(NSString *)item;
- (void)setDataViewWithItem:(NSArray *)items title:(NSString *)title selectedItem:(NSString *)item;
- (void)setDataCityWithTitle:(NSString *)title address:(NSString *)address;
- (void)showPickView:(UIViewController *)vc;


@property(nonatomic,copy)HLPickViewSubmit block;
@property(nonatomic,strong)UIView *contentView;
-(void)startAnimation;
@end
