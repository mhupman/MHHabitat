//
//  MHHabitat.h
//
//  Created by Matthew Hupman on 2/18/13.
//  Copyright (c) 2013 Matthew Hupman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MHMobileProvisionTypeUndetermined,
    MHMobileProvisionTypeDebug,
    MHMobileProvisionTypeAdHoc,
    MHMobileProvisionTypeAppStore,
    MHMobileProvisionTypeEnterprise
    
} MHMobileProvisionType;

@interface MHHabitat : NSObject

+ (MHMobileProvisionType)mobileProvisionType;
+ (NSString*)mobileProvisionTypeString;
+ (BOOL)isAppProduction;

@end