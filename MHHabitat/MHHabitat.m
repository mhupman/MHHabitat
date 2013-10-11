//
//  MHHabitat.m
//
//  Created by Matthew Hupman on 2/18/13.
//  Copyright (c) 2013 Matthew Hupman. All rights reserved.
//

#import "MHHabitat.h"

@implementation MHHabitat

static BOOL hasChecked;
static MHMobileProvisionType _mobileProvisionType;

+ (MHMobileProvisionType)mobileProvisionType
{
    if (hasChecked)
        return _mobileProvisionType;
    
    _mobileProvisionType = [self parseMobileProvisionType];
    
    hasChecked = YES;
    
    return _mobileProvisionType;
}

+ (NSString*)mobileProvisionTypeString
{
    MHMobileProvisionType type = [self mobileProvisionType];
    
    switch (type)
    {
        case MHMobileProvisionTypeDebug:
            return @"MobileProvisionTypeDebug";
            
        case MHMobileProvisionTypeAdHoc:
            return @"MobileProvisionTypeAdHoc";
            
        case MHMobileProvisionTypeAppStore:
            return @"MobileProvisionTypeAppStore";
            
        case MHMobileProvisionTypeEnterprise:
            return @"MobileProvisionTypeEnterprise";
            
        default:
            return @"MobileProvisionTypeUndetermined";
    }
}

+ (BOOL)isAppProduction
{
    MHMobileProvisionType appType = [self mobileProvisionType];
    
    return appType == MHMobileProvisionTypeAppStore || appType == MHMobileProvisionTypeEnterprise || appType == MHMobileProvisionTypeAdHoc;
}

+ (MHMobileProvisionType)parseMobileProvisionType
{
    // Default to AppStore for safety.  If anything ever changes, like the format of the file or it's filename,
    // this would ensure that we would treat every build as "AppStore" and a developer would need to intervene
    // to re-enable testing/sandbox logic.
    MHMobileProvisionType type = MHMobileProvisionTypeAppStore;
    
    @try
    {
        // AppStore builds don't contain an embedded.mobileprovision file, Apple strips it out of the
        // IPA before submitting to the AppStore.
        NSString* file = [[NSBundle mainBundle] pathForResource:@"embedded.mobileprovision" ofType:nil];
        
        if (file)
        {
            //get plist XML
            NSString *fileString = [[NSString alloc] initWithContentsOfFile:file encoding:NSStringEncodingConversionAllowLossy error:nil];
            NSScanner *scanner = [[NSScanner alloc] initWithString:fileString];
            
            if ([scanner scanUpToString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" intoString:NULL])
            {
                
                NSString *plistString;
                
                if ([scanner scanUpToString:@"</plist>" intoString:&plistString])
                {
                    
                    NSDictionary *plist = [[plistString stringByAppendingString:@"</plist>"] propertyList];
                    
                    
                    // Only Debug and AdHoc can have provisioned devices
                    if ([plist valueForKeyPath:@"ProvisionedDevices"])
                    {
                        // Entitlements.get-task-allow allows a debugger to attach
                        if ([[plist valueForKeyPath:@"Entitlements.get-task-allow"] boolValue])
                        {
                            type = MHMobileProvisionTypeDebug;
                        }
                        else
                        {
                            type = MHMobileProvisionTypeAdHoc;
                        }
                    }
                    else if ([[plist valueForKeyPath:@"ProvisionsAllDevices"] boolValue])
                    {
                        type = MHMobileProvisionTypeEnterprise;
                    }
                }
            }
        }
        
        // Limit return of 'unknown' type to simulator only.  This helps prevent accidently breaking AppStore builds if Apple decides to change
        // the way that *.mobileprovision files are handled.
#if TARGET_IPHONE_SIMULATOR
        else
        {
            type = MHMobileProvisionTypeUndetermined;
        }
#endif
        
    }
    @catch (NSException* e) {}
    
    return type;
}

@end