//
//  MacUtils.mm
//  fHashMacUI
//
//  Created by Sun Junwen on 15/7/20.
//  Copyright (c) 2015 Sun Junwen. All rights reserved.
//
#import "MacUtils.h"

#include <string>
#include "strhelper.h"
#include "Utils.h"
#include "Global.h"

#import <Foundation/Foundation.h>

using namespace std;
using namespace sunjwbase;

namespace MacUtils {
    
    NSString *GetSystemVersion() {
        NSDictionary *systemVersionDictionary = [NSDictionary dictionaryWithContentsOfFile:
                                                 @"/System/Library/CoreServices/SystemVersion.plist"];
        NSString *systemVersion = [systemVersionDictionary objectForKey:@"ProductVersion"];
        return systemVersion;
    }
    
    NSInteger GetSystemMajorVersion() {
        NSInteger nsiMajorVersion = 0;
        
        NSString *systemVersion = GetSystemVersion();
        NSArray *versionParts = [systemVersion componentsSeparatedByString: @"."];
        if (versionParts != nil && versionParts.count > 0) {
            NSString *nsstrMajorVersion = [versionParts objectAtIndex:0];
            nsiMajorVersion = [nsstrMajorVersion integerValue];
        }
        
        return nsiMajorVersion;
    }
    
    NSInteger GetSystemMinorVersion() {
        NSInteger nsiMinorVersion = 0;
        
        NSString *systemVersion = GetSystemVersion();
        NSArray *versionParts = [systemVersion componentsSeparatedByString: @"."];
        if (versionParts != nil && versionParts.count > 1) {
            NSString *nsstrMinorVersion = [versionParts objectAtIndex:1];
            nsiMinorVersion = [nsstrMinorVersion integerValue];
        }
        
        return nsiMinorVersion;
    }
    
    NSString *GetSystemPreferredLanguage() {
        NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
        return language;
    }
    
    string ConvertNSStringToUTF8String(const NSString *nsstr) {
        string strRet = string([nsstr UTF8String]);
        return strRet;
    }
    
    NSString *ConvertUTF8StringToNSString(const string stdstrUtf8) {
        return [NSString stringWithUTF8String:stdstrUtf8.c_str()];
    }
    
    string GetStringFromRes(NSString *nsstrKey) {
        NSString *nsstrLocalized = NSLocalizedString(nsstrKey, @"");
        string strLocalized = ConvertNSStringToUTF8String(nsstrLocalized);
        // Fix Windows UI strings.
        // Fix zh-cn.
        for (char chTest = 'A'; chTest <= 'Z'; ++chTest) {
            string strTest = "(&";
            strTest += chTest;
            strTest.append(")");
            strLocalized = strreplace(strLocalized, strTest, ""); // Remove "(&X)"
        }
        // Fix en-us
        strLocalized = strreplace(strLocalized, "&", ""); // Remove "&"
        
        return strLocalized;
    }
    
    NSString *GetNSStringFromRes(NSString *nsstrKey) {
        string strLocalized = GetStringFromRes(nsstrKey);
        NSString *nsstrLocalized = ConvertUTF8StringToNSString(strLocalized);
        return nsstrLocalized;
    }
    
    void AppendFileNameToNSMutableString(const ResultData& result,
                                         NSMutableString *nsmutString) {
        string strAppend = GetStringFromResByKey(FILENAME_STRING);
        strAppend.append(" ");
        strAppend.append(tstrtostr(result.tstrPath));
        strAppend.append("\n");
        
        NSString *nsstrAppend = MacUtils::ConvertUTF8StringToNSString(strAppend);
        [nsmutString appendString:nsstrAppend];
    }
    
    void AppendFileMetaToNSMutableString(const ResultData& result,
                                         NSMutableString *nsmutString) {
        char chSizeBuff[1024] = {0};
        sprintf(chSizeBuff, "%llu", result.ulSize);
        string strShortSize = Utils::ConvertSizeToShortSizeStr(result.ulSize);
        
        string strAppend = GetStringFromResByKey(FILESIZE_STRING);
        strAppend.append(" ");
        strAppend.append(chSizeBuff);
        strAppend.append(" ");
        strAppend.append(GetStringFromResByKey(BYTE_STRING));
        if (strShortSize != "") {
            strAppend.append(" (");
            strAppend.append(strShortSize);
            strAppend.append(")");
        }
        strAppend.append("\n");
        strAppend.append(GetStringFromResByKey(MODIFYTIME_STRING));
        strAppend.append(" ");
        strAppend.append(tstrtostr(result.tstrMDate));
        strAppend.append("\n");
        
        NSString *nsstrAppend = MacUtils::ConvertUTF8StringToNSString(strAppend);
        [nsmutString appendString:nsstrAppend];
    }
    
    void AppendFileHashToNSMutableString(const ResultData& result,
                                         bool uppercase,
                                         NSMutableString *nsmutString) {
        string strFileMD5, strFileSHA1, strFileSHA256, strFileCRC32;
        
        if (uppercase) {
            strFileMD5 = str_upper(tstrtostr(result.tstrMD5));
            strFileSHA1 = str_upper(tstrtostr(result.tstrSHA1));
            strFileSHA256 = str_upper(tstrtostr(result.tstrSHA256));
            strFileCRC32 = str_upper(tstrtostr(result.tstrCRC32));
        } else {
            strFileMD5 = str_lower(tstrtostr(result.tstrMD5));
            strFileSHA1 = str_lower(tstrtostr(result.tstrSHA1));
            strFileSHA256 = str_lower(tstrtostr(result.tstrSHA256));
            strFileCRC32 = str_lower(tstrtostr(result.tstrCRC32));
        }
        
        string strAppend;
        strAppend.append("MD5: ");
        strAppend.append(strFileMD5);
        strAppend.append("\nSHA1: ");
        strAppend.append(strFileSHA1);
        strAppend.append("\nSHA256: ");
        strAppend.append(strFileSHA256);
        strAppend.append("\nCRC32: ");
        strAppend.append(strFileCRC32);
        strAppend.append("\n\n");
        
        NSString *nsstrAppend = MacUtils::ConvertUTF8StringToNSString(strAppend);
        [nsmutString appendString:nsstrAppend];
    }
    
    void AppendFileErrToNSMutableString(const ResultData& result,
                                        NSMutableString *nsmutString) {
        string strAppend;
        strAppend.append(tstrtostr(result.tstrError));
        strAppend.append("\n\n");
        
        NSString *nsstrAppend = MacUtils::ConvertUTF8StringToNSString(strAppend);
        [nsmutString appendString:nsstrAppend];
    }
    
    void AppendResultToNSMutableString(const ResultData& result,
                                       bool uppercase,
                                       NSMutableString *nsmutString) {
        if (result.enumState == ResultState::RESULT_NONE)
            return;
        
        if (result.enumState == ResultState::RESULT_ALL ||
            result.enumState == ResultState::RESULT_META ||
            result.enumState == ResultState::RESULT_ERROR ||
            result.enumState == ResultState::RESULT_PATH) {
            AppendFileNameToNSMutableString(result, nsmutString);
        }
        
        if (result.enumState == ResultState::RESULT_ALL ||
            result.enumState == ResultState::RESULT_META) {
            AppendFileMetaToNSMutableString(result, nsmutString);
        }
        
        if (result.enumState == ResultState::RESULT_ALL) {
            AppendFileHashToNSMutableString(result, uppercase, nsmutString);
        }
        
        if (result.enumState == ResultState::RESULT_ERROR) {
            AppendFileErrToNSMutableString(result, nsmutString);
        }
        
        if (result.enumState != ResultState::RESULT_ALL &&
            result.enumState != ResultState::RESULT_ERROR) {
            string strAppend = "\n";
            NSString *nsstrAppend = MacUtils::ConvertUTF8StringToNSString(strAppend);
            [nsmutString appendString:nsstrAppend];
        }
    }
    
}
