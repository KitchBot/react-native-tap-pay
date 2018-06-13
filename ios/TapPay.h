
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#else
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#endif
#import <TPDirect/TPDirect.h>
#import <RCTConvert.h>



@interface TapPay : RCTEventEmitter
    
@end
  
