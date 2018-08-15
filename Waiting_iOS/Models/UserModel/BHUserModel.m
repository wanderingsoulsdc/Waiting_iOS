//
//  BHUserModel.m
//  Customer
//
//  Created by ChenQiuLiang on 2017/5/11.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import "BHUserModel.h"

NSString * const kUserCacheKey = @"kUserCacheKey";

@implementation BHUserModel

#pragma mark - Getters and Setters

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

#pragma mark - NSCoding Delegate

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.passwd forKey:@"passwd"];
    [aCoder encodeObject:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.agreementUpdate forKey:@"agreementUpdate"];
    [aCoder encodeInteger:self.treasureCount forKey:@"treasureCount"];
    [aCoder encodeObject:self.isSubAccount forKey:@"isSubAccount"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
        self.mobile             = [aDecoder decodeObjectForKey:@"mobile"];
        self.passwd             = [aDecoder decodeObjectForKey:@"passwd"];
        self.userID             = [aDecoder decodeObjectForKey:@"userID"];
        self.token              = [aDecoder decodeObjectForKey:@"token"];
        self.agreementUpdate    = [aDecoder decodeObjectForKey:@"agreementUpdate"];
        self.treasureCount      = [aDecoder decodeIntegerForKey:@"treasureCount"];
        self.isSubAccount       = [aDecoder decodeObjectForKey:@"isSubAccount"];
    }
    return self;
}

#pragma mark - public methods

static id user;
+ (instancetype)sharedInstance
{
    @synchronized (self)
    {
        if (!user)
        {
            @try {
                user = [self readFromDisk];
            }
            @catch (NSException *exception) {
                NSLog(@"user is erro");
            }
            @finally {
                if (!user)
                {
                    user = [[[self class] alloc] init];
                }
            }
        }
        
    }
    return user;
}

- (void)analysisUserInfoWithDictionary:(NSDictionary *)dict{
    
    NSDictionary *dataDic = dict[@"data"];
    
    [BHUserModel sharedInstance].userID = [dataDic stringValueForKey:@"accountId" default:@""];
    [BHUserModel sharedInstance].userMobile = [dataDic stringValueForKey:@"mobile" default:@""];
    [BHUserModel sharedInstance].businessName = [dataDic stringValueForKey:@"businessName" default:@""];
    [BHUserModel sharedInstance].businessLicenceImg = [dataDic stringValueForKey:@"businessLicenceImg" default:@""];
    [BHUserModel sharedInstance].auditStatus = [dataDic stringValueForKey:@"auditStatus" default:@""];
    [BHUserModel sharedInstance].aptitudeOneId = [dataDic stringValueForKey:@"aptitudeOneId" default:@""];
    [BHUserModel sharedInstance].aptitudeTwoId = [dataDic stringValueForKey:@"aptitudeTwoId" default:@""];
    [BHUserModel sharedInstance].balance = [dataDic stringValueForKey:@"balance" default:@""];
    [BHUserModel sharedInstance].refuseReason = [dataDic stringValueForKey:@"refuseReason" default:@""];
    
    [[BHUserModel sharedInstance] saveToDisk];

}

- (void)analysisUserInfoWithDictionary:(NSDictionary *)dict Mobile:(NSString *)mobile Passwd:(NSString *)password Token:(NSString *)token
{
//    NSInteger treasureCount = [[dict objectForKey:@"shop"] integerValue];
    [BHUserModel sharedInstance].mobile = mobile;
    [BHUserModel sharedInstance].passwd = password;
    [BHUserModel sharedInstance].token  = token;
//    [BHUserModel sharedInstance].treasureCount = treasureCount;
    [BHUserModel sharedInstance].userID = [[dict objectForKey:@"data"]
                                           objectForKey:@"accountId"];
//    [BHUserModel sharedInstance].businessName = [[[dict objectForKey:@"data"]
//                                                         objectForKey:@"account"]
//                                                        objectForKey:@"businessName"];
//    [BHUserModel sharedInstance].permissionAll = dict[@"data"][@"permission"][@"all"];
//    [BHUserModel sharedInstance].permissionWechat = dict[@"data"][@"permission"][@"pyq"];
//    [BHUserModel sharedInstance].permissionWcrd = dict[@"data"][@"permission"][@"wcrd"];
//    [BHUserModel sharedInstance].permissionSMS = dict[@"data"][@"permission"][@"timingSms"];
//    [BHUserModel sharedInstance].permissionWiFiAD = dict[@"data"][@"permission"][@"wifiAd"];
//    [BHUserModel sharedInstance].isNoviceGuide = dict[@"data"][@"task"][@"task"];
//    [BHUserModel sharedInstance].isFinishGuideStore = dict[@"data"][@"task"][@"shop"];
//    [BHUserModel sharedInstance].isFinishGuideAD = dict[@"data"][@"task"][@"advertisement"];
//    [BHUserModel sharedInstance].isFinishGuidePhone = dict[@"data"][@"task"][@"phone"];
//    [BHUserModel sharedInstance].isFinishGuideMessage = dict[@"data"][@"task"][@"sms"];
//    [BHUserModel sharedInstance].isSubAccount = dict[@"data"][@"isphoneson"];
    
    [[BHUserModel sharedInstance] saveToDisk];
}

- (void)modifyUserInfoWithDictionary:(NSDictionary *)dict
{
    // 根据dict赋值   然后savaToDisk
    self.mobile = [dict objectForKey:@"mobile"] ? [dict objectForKey:@"mobile"] : self.mobile;
    self.passwd = [dict objectForKey:@"passwd"] ? [dict objectForKey:@"passwd"] : self.passwd;
    self.userID = [dict objectForKey:@"userID"] ? [dict objectForKey:@"userID"] : self.userID;
    self.agreementUpdate = [dict objectForKey:@"agreementUpdate"] ? [dict objectForKey:@"agreementUpdate"] : self.agreementUpdate;
    
    [self saveToDisk];
}

+ (void)cleanupCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserCacheKey];
    user = nil;
}



#pragma mark - private methods

+ (instancetype) readFromDisk {
    NSData * userData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserCacheKey];
    BHUserModel * currUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    
    return currUser;
}

- (void) saveToDisk {
    NSData * userData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:kUserCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end