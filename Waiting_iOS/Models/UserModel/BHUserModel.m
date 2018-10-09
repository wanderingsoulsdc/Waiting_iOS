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
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
        self.mobile             = [aDecoder decodeObjectForKey:@"mobile"];
        self.passwd             = [aDecoder decodeObjectForKey:@"passwd"];
        self.userID             = [aDecoder decodeObjectForKey:@"userID"];
        self.token              = [aDecoder decodeObjectForKey:@"token"];
        self.agreementUpdate    = [aDecoder decodeObjectForKey:@"agreementUpdate"];
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
    
    NSDictionary *dataDic = dict[@"data"][@"userInfo"];
    
    [BHUserModel sharedInstance].userID = [dataDic stringValueForKey:@"uid" default:@""];
    [BHUserModel sharedInstance].userName = [dataDic stringValueForKey:@"nickname" default:@""];
    [BHUserModel sharedInstance].birthday = [dataDic stringValueForKey:@"birthday" default:@""];
    [BHUserModel sharedInstance].gender = [dataDic stringValueForKey:@"gender" default:@"0"];
    [BHUserModel sharedInstance].gender_txt = [dataDic stringValueForKey:@"gender_txt" default:@""];
    [BHUserModel sharedInstance].age = [dataDic stringValueForKey:@"age" default:@"0"];
    [BHUserModel sharedInstance].remark = [dataDic stringValueForKey:@"remark" default:@""];
    [BHUserModel sharedInstance].userHeadImageUrl = [dataDic stringValueForKey:@"photo" default:@""];
    [BHUserModel sharedInstance].photoArray = [dataDic objectForKey:@"pic"];
    [BHUserModel sharedInstance].photoNum = [NSString stringWithFormat:@"%lu",(unsigned long)[[BHUserModel sharedInstance].photoArray count]];
    [BHUserModel sharedInstance].hobbyArray = [dataDic objectForKey:@"hobby"];
    
    [[BHUserModel sharedInstance] saveToDisk];

}

- (void)analysisUserInfoWithToken:(NSString *)token Uid:(NSString *)uid{
    [BHUserModel sharedInstance].token  = token;
    [BHUserModel sharedInstance].userID = uid;
    [[BHUserModel sharedInstance] saveToDisk];
}

- (void)analysisUserInfoWithDictionary:(NSDictionary *)dict Mobile:(NSString *)mobile Passwd:(NSString *)password Token:(NSString *)token
{
    [BHUserModel sharedInstance].mobile = mobile;
    [BHUserModel sharedInstance].passwd = password;
    [BHUserModel sharedInstance].token  = token;
    [BHUserModel sharedInstance].userID = [[dict objectForKey:@"data"]
                                           objectForKey:@"accountId"];
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
