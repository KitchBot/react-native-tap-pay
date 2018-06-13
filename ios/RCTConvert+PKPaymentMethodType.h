#if __has_include(<React/RCTConvert.h>)
  #import <React/RCTConvert.h>
#elif __has_include("React/RCTConvert.h")
  #import "React/RCTConvert.h"
#else
  #import "RCTConvert.h"
#endif



typedef NS_ENUM(NSInteger, PKPaymentMethodType) {
    PKPaymentMethodTypeUnknown,
    PKPaymentMethodTypeDebit,
    PKPaymentMethodTypeCredit,
    PKPaymentMethodTypePrepaid,
    PKPaymentMethodTypeStore
    
};

@interface RCTConvert (PKPaymentMethodType)

@end
