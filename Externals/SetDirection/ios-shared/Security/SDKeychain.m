//
//  SDKeychain.m
//
//  Created by brandon on 3/27/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

//  Created by Buzz Andersen on 10/20/08.
//  Based partly on code by Jonathan Wight, Jon Crosby, and Mike Malone.
//  Copyright 2008 Sci-Fi Hi-Fi. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "SDKeychain.h"
#import <Security/Security.h>

static NSString *SDKeychainErrorDomain = @"SDKeychainErrorDomain";

@implementation SDKeychain

+ (NSString*)stringForKey:(NSString*)key serviceName:(NSString *)serviceName
{
	OSStatus status;

    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, kSecReturnData,
                           kSecClassGenericPassword, kSecClass,
                           key, kSecAttrAccount,
                           serviceName, kSecAttrService,
                           nil];
    
    CFDataRef stringData = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&stringData);

	if (status) 
        return nil;
	
    NSString *string = [[NSString alloc] initWithData:(__bridge id)stringData encoding:NSUTF8StringEncoding];
    if (stringData)
        CFRelease(stringData);

	return string;	
}

+ (BOOL)setString:(NSString*)string forKey:(NSString*)key serviceName:(NSString *)serviceName
{
	if (!string)  
    {
		//Need to delete the Key 
        NSDictionary *spec = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword, kSecClass, key, kSecAttrAccount, serviceName, kSecAttrService, nil];
        return !SecItemDelete((__bridge CFDictionaryRef)spec);
    } 
    else
    {
        NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *spec = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword, kSecClass, key, kSecAttrAccount, serviceName, kSecAttrService, nil];
        
        if(!string)
            return !SecItemDelete((__bridge CFDictionaryRef)spec);
        else
        if ([SDKeychain stringForKey:key serviceName:serviceName])
        {
            NSDictionary *update = [NSDictionary dictionaryWithObject:stringData forKey:(__bridge id)kSecValueData];
            return !SecItemUpdate((__bridge CFDictionaryRef)spec, (__bridge CFDictionaryRef)update);
        }
        else
        {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:spec];
            [data setObject:stringData forKey:(__bridge id)kSecValueData];
            return !SecItemAdd((__bridge CFDictionaryRef)data, NULL);
        }
    }
}

+ (NSString *)getPasswordForUsername:(NSString *)username andServiceName:(NSString *)serviceName error:(NSError **)error
{
	if (!username || !serviceName)
	{
		if (error != nil)
			*error = [NSError errorWithDomain:SDKeychainErrorDomain code:-2000 userInfo:nil];
		return nil;
	}

	if (error != nil)
		*error = nil;

	// Set up a query dictionary with the base query attributes: item type (generic), username, and service

	NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass, kSecAttrAccount, kSecAttrService, nil];
	NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword, username, serviceName, nil];

	NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];

	// First do a query for attributes, in case we already have a Keychain item with no password data set.
	// One likely way such an incorrect item could have come about is due to the previous (incorrect)
	// version of this code (which set the password as a generic attribute instead of password data).

	NSMutableDictionary *attributeQuery = [query mutableCopy];
	[attributeQuery setObject:(id) kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
	CFTypeRef cfResult = nil;
	OSStatus status = SecItemCopyMatching( (__bridge CFDictionaryRef)attributeQuery, &cfResult);
	if (cfResult)
		CFRelease(cfResult);


	if (status != noErr)
	{
		// No existing item found--simply return nil for the password
		if (error != nil && status != errSecItemNotFound)
		{
			//Only return an error if a real exception happened--not simply for "not found."
			*error = [NSError errorWithDomain:SDKeychainErrorDomain code:status userInfo:nil];
		}

		return nil;
	}

	// We have an existing item, now query for the password data associated with it.

	NSData *resultData = nil;
	NSMutableDictionary *passwordQuery = [query mutableCopy];
	[passwordQuery setObject:(id) kCFBooleanTrue forKey:(__bridge id)kSecReturnData];

	CFTypeRef cfResultData;
	status = SecItemCopyMatching( (__bridge CFDictionaryRef)passwordQuery, &cfResultData );
	resultData = (__bridge NSData*)cfResultData;


	if (status != noErr)
	{
		if (status == errSecItemNotFound)
		{
			// We found attributes for the item previously, but no password now, so return a special error.
			// Users of this API will probably want to detect this error and prompt the user to
			// re-enter their credentials.  When you attempt to store the re-entered credentials
			// using storeUsername:andPassword:forServiceName:updateExisting:error
			// the old, incorrect entry will be deleted and a new one with a properly encrypted
			// password will be added.
			if (error != nil)
				*error = [NSError errorWithDomain:SDKeychainErrorDomain code:-1999 userInfo:nil];
		}
		else
		{
			// Something else went wrong. Simply return the normal Keychain API error code.
			if (error != nil)
				*error = [NSError errorWithDomain:SDKeychainErrorDomain code:status userInfo:nil];
		}

		return nil;
	}

	NSString *password = nil;

	if (resultData)
		password = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	else
	{
		// There is an existing item, but we weren't able to get password data for it for some reason,
		// Possibly as a result of an item being incorrectly entered by the previous code.
		// Set the -1999 error so the code above us can prompt the user again.
		if (error != nil)
			*error = [NSError errorWithDomain:SDKeychainErrorDomain code:-1999 userInfo:nil];
	}

    if (cfResultData)
        CFRelease(cfResultData);
	return password;
}

+ (BOOL)storeUsername:(NSString *)username andPassword:(NSString *)password forServiceName:(NSString *)serviceName updateExisting:(BOOL)updateExisting error:(NSError * *)error
{
	if (!username || !password || !serviceName)
	{
		if (error != nil)
			*error = [NSError errorWithDomain:SDKeychainErrorDomain code:-2000 userInfo:nil];
		return NO;
	}

	// See if we already have a password entered for these credentials.
	NSError *getError = nil;
	NSString *existingPassword = [SDKeychain getPasswordForUsername:username andServiceName:serviceName error:&getError];

	if ([getError code] == -1999)
	{
		// There is an existing entry without a password properly stored (possibly as a result of the previous incorrect version of this code.
		// Delete the existing item before moving on entering a correct one.

		getError = nil;

		[self deleteItemForUsername:username andServiceName:serviceName error:&getError];

		if ([getError code] != noErr)
		{
			if (error != nil)
				*error = getError;
			return NO;
		}
	}
	else 
    if ([getError code] != noErr)
    {
		if (error != nil)
			*error = getError;
		return NO;
	}

	if (error != nil)
		*error = nil;

	OSStatus status = noErr;

	if (existingPassword)
	{
		// We have an existing, properly entered item with a password.
		// Update the existing item.

		if (![existingPassword isEqualToString:password] && updateExisting)
		{
			//Only update if we're allowed to update existing.  If not, simply do nothing.

			NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass,
			                  kSecAttrService,
			                  kSecAttrLabel,
			                  kSecAttrAccount,
			                  nil];

			NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword,
			                     serviceName,
			                     serviceName,
			                     username,
			                     nil];

			NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];

			status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge NSString *)kSecValueData]);
		}
	}
	else
	{
		// No existing entry (or an existing, improperly entered, and therefore now
		// deleted, entry).  Create a new entry.

		NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass,
		                  kSecAttrService,
		                  kSecAttrLabel,
		                  kSecAttrAccount,
		                  kSecValueData,
		                  nil];

		NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword,
		                     serviceName,
		                     serviceName,
		                     username,
		                     [password dataUsingEncoding:NSUTF8StringEncoding],
		                     nil];

		NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];

		status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
	}

	if (error != nil && status != noErr)
	{
		// Something went wrong with adding the new item. Return the Keychain error code.
		*error = [NSError errorWithDomain:SDKeychainErrorDomain code:status userInfo:nil];
		return NO;
	}

	return YES;
}

+ (BOOL)deleteItemForUsername:(NSString *)username andServiceName:(NSString *)serviceName error:(NSError * *)error
{
	if (!username || !serviceName)
	{
		if (error != nil)
			*error = [NSError errorWithDomain:SDKeychainErrorDomain code:-2000 userInfo:nil];
		return NO;
	}

	if (error != nil)
		*error = nil;

	NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass, kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil];
	NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword, username, serviceName, kCFBooleanTrue, nil];

	NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];

	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);

	if (error != nil && status != noErr)
	{
		*error = [NSError errorWithDomain:SDKeychainErrorDomain code:status userInfo:nil];
		return NO;
	}

	return YES;
}

@end