//
//  TPDTransactionResult.h
//
//  Copyright © 2017 Cherri Tech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

@interface TPDTransactionResult : NSObject

// orderID, An Identifier Specific For This Transaction. Save This Value For Refund Purposes.
@property (nonatomic, strong) NSString *orderID;

// authCode, Credit Card Transaction Authorization Code From The Bank.
@property (nonatomic, strong) NSString *authCode;

// message, Report Message.
@property (nonatomic, strong) NSString *message;

// status, Result Code, '0' Means Success.
@property (nonatomic, assign) NSInteger status;

// amount
@property (nonatomic, strong) NSDecimalNumber *amount;

// paymentMehod
@property (nonatomic, strong) PKPaymentMethod *paymentMethod;

@end
