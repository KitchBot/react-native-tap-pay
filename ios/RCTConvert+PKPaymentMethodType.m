#import "RCTConvert+PKPaymentMethodType.h"

@implementation RCTConvert (PKPaymentMethodType)
  RCT_ENUM_CONVERTER(PKPaymentMethodType, (@{ @"Unknown" : @(PKPaymentMethodTypeUnknown),
                                               @"Debit" : @(PKPaymentMethodTypeDebit),
                                               @"Credit" : @(PKPaymentMethodTypeCredit),
                                               @"Prepaid" : @(PKPaymentMethodTypeCredit),
                                               @"Store" : @(PKPaymentMethodTypeStore)}),
                      PKPaymentMethodTypeUnknown, integerValue)
@end