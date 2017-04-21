
#import "TapPay.h"

@implementation TapPay

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(setup:(int)appID WithAPPKey:(NSString * _Nonnull)appKey WithDev:(bool)dev)
{
    if(dev){
        [TPDSetup setWithAppId:appID withAppKey:appKey withServerType:TPDServer_SandBox];
    }else{
        [TPDSetup setWithAppId:appID withAppKey:appKey withServerType:TPDServer_Production];
    }
}

RCT_EXPORT_METHOD(createToken:(NSString *_Nonnull)cardNumber
                  withDueMonth:(NSString * _Nonnull)dueMonth
                  withDueYear:(NSString * _Nonnull)dueYear
                  withCCV:(NSString * _Nonnull)CCV)
                  withLocation:(NSString * _Nonnull)geoLocation
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
{
    [TPDCard setWithCardNumber:cardNumber
                  withDueMonth:dueMonth
                   withDueYear:dueYear
                       withCCV:CCV];
    
    [[[[TPDCard setWithCardNumber:cardNumber
                     withDueMonth:dueMonth
                      withDueYear:dueYear
                          withCCV:CCV]
       onSuccessCallback:^(NSString * _Nullable token, NSString * _Nullable cardLastFour) {
           NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 token, @"token", cardLastFour, @"cardLastFour", nil];
           resolve(dict);

       }]
      onFailureCallback:^(NSInteger status, NSString * _Nonnull message) {
          NSError *error = [NSError errorWithDomain:@"tappay" code:status userInfo:nil];
          NSString* code = [@(status) stringValue];
          reject(code,message,error);
      }]
     
     createTokenWithGeoLocation:geoLocation];
    
}

@end
  
