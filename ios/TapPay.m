
#import "TapPay.h"
#import <AdSupport/ASIdentifierManager.h>
#import <PassKit/PassKit.h>


@interface TapPay () <TPDApplePayDelegate>
    @property (nonatomic, strong) TPDMerchant *merchant;
    @property (nonatomic, strong) TPDConsumer *consumer;
    @property (nonatomic, strong) TPDCart *cart;
    @property (nonatomic, strong) TPDApplePay *applePay;
    @property (nonatomic, strong) TPDLinePay *linePay;
    @property (nonatomic, strong) RCTPromiseResolveBlock resolve;
    @property (nonatomic, strong) RCTPromiseRejectBlock reject;
@end


@implementation TapPay 
{
    bool hasListeners;
}   

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


- (NSArray<NSString *> *)supportedEvents
{
  return @[@"ApplePayStart",@"ApplePayFailed",@"ApplePaySuccessed",@"ApplePaySuccess",@"ApplePayCancel",@"ApplePayFinish",@"ApplePayDidSelectShipping"];
}


-(void)startObserving {
    hasListeners = YES;

}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
}



RCT_EXPORT_METHOD(setup:(int)appID WithAPPKey:(NSString * _Nonnull)appKey WithDev:(BOOL)dev)
{
    if(dev){
        [TPDSetup setWithAppId:appID withAppKey:appKey withServerType:TPDServer_SandBox];
    }else{
        [TPDSetup setWithAppId:appID withAppKey:appKey withServerType:TPDServer_Production];
    }
    [[TPDSetup shareInstance] setupIDFA:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    
    [[TPDSetup shareInstance] serverSync];
    self.merchant = [TPDMerchant new];
    self.consumer = [TPDConsumer new];
    self.cart = [TPDCart new];
}

RCT_EXPORT_METHOD(createToken:(NSString *_Nonnull)cardNumber
                  withDueMonth:(NSString * _Nonnull)dueMonth
                  withDueYear:(NSString * _Nonnull)dueYear
                  withCCV:(NSString * _Nonnull)CCV
                  withLocation:(NSString * _Nonnull)geoLocation
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    TPDCard *tpdCard = [TPDCard setWithCardNumber:cardNumber
                                     withDueMonth:dueMonth
                                      withDueYear:dueYear
                                          withCCV:CCV];
    [[[tpdCard onSuccessCallback:^(NSString * _Nullable prime, TPDCardInfo * _Nullable cardInfo) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:prime, @"token", cardInfo.lastFour, @"cardLastFour", cardInfo.bincode, @"bincode", cardInfo.issuer, @"issuer",  cardInfo.funding, @"funding", cardInfo.country, @"country", cardInfo.countryCode, @"countryCode", cardInfo.level, @"level" , nil];
        resolve(dict);
    }] onFailureCallback:^(NSInteger status, NSString * _Nonnull message) {
        NSError *error = [NSError errorWithDomain:@"tappay" code:status userInfo:nil];
        NSString* code = [@(status) stringValue];
        reject(code,message,error);
    }] createTokenWithGeoLocation:geoLocation];
}

RCT_EXPORT_METHOD(lineInitial:(NSString * _Nonnull)url)
{
     self.linePay = [TPDLinePay setupWithReturnUrl:url];
}

RCT_EXPORT_METHOD(createLineToken: resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([TPDLinePay isLinePayAvailable]) {
         [[[self.linePay onSuccessCallback:^(NSString * _Nullable prime) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: prime,@"token",TRUE,@"result",nil];
                resolve(dict);
            });
        }] onFailureCallback:^(NSInteger status, NSString * _Nonnull message) {
            NSError *error = [NSError errorWithDomain:@"linepay" code:status userInfo:nil];
            NSString* code = [@(status) stringValue];
            reject(code,message,error);
        }] getPrime];
    }else{
        NSError *error = [NSError errorWithDomain:@"linepay" code:-1 userInfo:nil];
        NSString* code = [@(-1) stringValue];
        reject(code,@"",error);
    }
}
RCT_EXPORT_METHOD(lineRedirectUrl:(NSString * _Nonnull)url resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [self.linePay redirect:url withViewController:rootViewController completion:^(TPDLinePayResult * _Nonnull result) {
//  NSLog(@"status : %@ , orderNumber : %@ , recTradeId : %@ , bankTransactionId : %@",result.status , result.orderNumber , result.recTradeId , result.bankTransactionId);

    }];
}


RCT_EXPORT_METHOD(setMerchant:(NSString * _Nonnull)name WithMerchantIdentifier:(NSString * _Nonnull)merchantIdentifier WithCountryCode:(NSString * _Nonnull)countryCode WithCurrency:(NSString * _Nonnull)currency)
{
    self.merchant.merchantName               = name;
    self.merchant.merchantCapability         = PKMerchantCapability3DS;
    self.merchant.applePayMerchantIdentifier = merchantIdentifier;
    self.merchant.countryCode                = countryCode;
    self.merchant.currencyCode               = currency;
    self.merchant.supportedNetworks          = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa ,PKPaymentNetworkMasterCard];


    
}

RCT_EXPORT_METHOD(applePayment: resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    self.cart.shippingType   = PKShippingTypeShipping;
    self.applePay = [TPDApplePay setupWthMerchant:self.merchant
                                     withConsumer:self.consumer
                                         withCart:self.cart
                                     withDelegate:self];

    self.resolve = resolve;
    self.reject = reject;
    
    [self.applePay startPayment];
}

RCT_EXPORT_METHOD(clearCart)
{
    self.cart = [TPDCart new];
}

RCT_EXPORT_METHOD(addToCart:(NSString * _Nonnull)name WithAmount:(NSString  * _Nonnull) amount)
{
    TPDPaymentItem *item = [TPDPaymentItem paymentItemWithItemName:name
                                                        withAmount:[NSDecimalNumber decimalNumberWithString:amount]];
    [self.cart addPaymentItem:item];                                                    
}


- (void)tpdApplePayDidStartPayment:(TPDApplePay *)applePay {
    [self sendEventWithName:@"ApplePayStart" body:@{}];
}

- (void)tpdApplePay:(TPDApplePay *)applePay didSuccessPayment:(TPDTransactionResult *)result {

    [self sendEventWithName:@"ApplePaySuccessed" body:@{@"amount":[result.amount stringValue]}];
    
}

- (void)tpdApplePay:(TPDApplePay *)applePay didFailurePayment:(TPDTransactionResult *)result {
    
    [self sendEventWithName:@"ApplePayFailed" body:@{@"status": @(result .status), @"message": result.message}];
}

- (void)tpdApplePayDidCancelPayment:(TPDApplePay *)applePay {
    [self sendEventWithName:@"ApplePayCancel" body:@{}];
}

- (void)tpdApplePayDidFinishPayment:(TPDApplePay *)applePay {
    
    [self sendEventWithName:@"ApplePayFinish" body:@{}];
}

- (void)tpdApplePay:(TPDApplePay *)applePay didSelectShippingMethod:(PKShippingMethod *)shippingMethod {
    
    [self sendEventWithName:@"ApplePayDidSelectShipping" body:@{@"identifier": shippingMethod.identifier , @"detail": shippingMethod.detail}];
}

- (TPDCart *)tpdApplePay:(TPDApplePay *)applePay didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod cart:(TPDCart *)cart {
    
    //[self sendEventWithName:@"ApplePayPaymentDidSelect" body:@{  @"displayName": paymentMethod.displayName}];
    return self.cart;
}


- (BOOL)tpdApplePay:(TPDApplePay *)applePay canAuthorizePaymentWithShippingContact:(PKContact *)shippingContact {
    //[self sendEventWithName:@"ApplePayAuthorizeWithShippingContact" body:@{@"givenName": shippingContact.name.givenName , @"familyName": shippingContact.name.familyName, @"emailAddress": shippingContact.emailAddress, @"phoneNumber": shippingContact.phoneNumber.stringValue }];
    return YES;
}

// With Payment Handle
- (void)tpdApplePay:(TPDApplePay *)applePay didReceivePrime:(NSString *)prime {

    dispatch_async(dispatch_get_main_queue(), ^{
        
         NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:prime,@"token",
                               applePay.cart.totalAmount,@"totalAmount",
                               applePay.consumer.clientIP, @"ip",
                               self.merchant.applePayMerchantIdentifier, @"merchant.id",
                               applePay.consumer.shippingContact.name.givenName || applePay.consumer.shippingContact.name.familyName, @"username",
                               applePay.consumer.shippingContact.emailAddress,@"email",
                               applePay.consumer.shippingContact.phoneNumber.stringValue,@"phoneNumber",
                               nil];
        
        self.resolve(dict);
//        NSString *payment = [NSString stringWithFormat:@"Use below cURL to proceed the payment.\ncurl -X POST \\\nhttps://sandbox.tappaysdk.com/tpc/payment/pay-by-prime \\\n-H \'content-type: application/json\' \\\n-H \'x-api-key: partner_6ID1DoDlaPrfHw6HBZsULfTYtDmWs0q0ZZGKMBpp4YICWBxgK97eK3RM\' \\\n-d \'{ \n \"prime\": \"%@\", \"partner_key\": \"partner_6ID1DoDlaPrfHw6HBZsULfTYtDmWs0q0ZZGKMBpp4YICWBxgK97eK3RM\", \"merchant_id\": \"GlobalTesting_CTBC\", \"details\":\"TapPay Test\", \"amount\": %@, \"cardholder\": { \"phone_number\": \"+886923456789\", \"name\": \"Jane Doe\", \"email\": \"Jane@Doe.com\", \"zip_code\": \"12345\", \"address\": \"123 @synthesize description;
//
//                             @synthesize hash;
//
//                             @synthesize superclass;
//
//                             1st Avenue, City, Country\", \"national_id\": \"A123456789\" }, \"remember\": true }\'",prime,applePay.cart.totalAmount];
//        NSLog(@"%@", payment);
    });
    
    
    // 2. If Payment Success, set paymentReault = YES.
    
    
}

RCT_EXPORT_METHOD(successApplePayment:(NSString * _Nonnull)name){
    BOOL paymentReault = YES;
    [self.applePay showPaymentResult:paymentReault];
}
RCT_EXPORT_METHOD(failedApplePayment:(NSString * _Nonnull)name){
    BOOL paymentReault = NO;
    [self.applePay showPaymentResult:paymentReault];
    
}





@end


