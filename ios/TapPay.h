
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif
#import <TPDirect/TPDSetup.h>
#import <TPDirect/TPDCard.h>

@interface TapPay : NSObject <RCTBridgeModule>

+(void)setWithCardNumber:(NSString *_Nonnull)cardNumber;
+(void)createTokenWithGeoLocation:(NSString * _Nonnull)geoLocation;
@end
  
