
#import "TapPay.h"




@implementation TapPay

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();



+ (void) setWithCardNumber:(NSString *_Nonnull)cardNumber{
    [TPDCard setWithCardNumber:@"消費者卡片號碼"
                  withDueMonth:@"消費者卡片過期月份"
                   withDueYear:@"消費者卡片過期年份"
                       withCCV:@"消費者卡片驗證代碼"];

}
- (void)createTokenWithGeoLocation:(NSString * _Nonnull)geoLocation{

    [[[[TPDCard setWithCardNumber:@"消費者卡片號碼"
                     withDueMonth:@"消費者卡片過期月份"
                      withDueYear:@"消費者卡片過期年份"
                          withCCV:@"消費者卡片驗證代碼"]
       onSuccessCallback:^(NSString * _Nullable prime, NSString * _Nullable lastFour) {
           
       }]
      onFailureCallback:^(NSInteger status, NSString * _Nonnull message) {
          
      }]
     createTokenWithGeoLocation:@"消費者所在地點的經緯度"];
}


@end
  
