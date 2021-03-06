//
//  Web_base.m
//  worldtrans
//
//  Created by itdept on 3/25/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import "Web_base.h"
#import <RestKit/RestKit.h>

@implementation Web_base

@synthesize il_url;
@synthesize ilist_resp_result;
@synthesize iresp_class;
@synthesize ilist_resp_mapping;

- (void) fn_get_data:(RequestContract*)ao_form
{
    RKObjectMapping *lo_searchMapping = [RKObjectMapping requestMapping];
    [lo_searchMapping addAttributeMappingsFromArray:@[@"os_column",@"os_value"]];
    
    RKObjectMapping *lo_authMapping = [RKObjectMapping requestMapping];
    [lo_authMapping addAttributeMappingsFromDictionary:@{ @"user_code": @"user_code",
                                                       @"password": @"password",
                                                          @"system": @"system" ,@"com_sys_code":@"com_sys_code",
                                                          @"encrypted":
                                                              @"encrypted",
                                                          @"company_code":@"company_code",
                                                          @"device_id": @"device_id",
                                                          @"app_code": @"app_code",@"version":@"version"}];
    RKObjectMapping *lo_addMapping=[RKObjectMapping requestMapping];
    
    RKObjectMapping *lo_reqMapping = [RKObjectMapping requestMapping];
    
    RKRelationshipMapping *searchRelationship = [RKRelationshipMapping
                                                 relationshipMappingFromKeyPath:@"SearchForm"
                                                 toKeyPath:@"SearchForm"
                                                 withMapping:lo_searchMapping];
    
    
    RKRelationshipMapping *authRelationship = [RKRelationshipMapping
                                               relationshipMappingFromKeyPath:@"Auth"
                                               toKeyPath:@"Auth"
                                               withMapping:lo_authMapping];
    RKRelationshipMapping *addRelationship=[RKRelationshipMapping relationshipMappingFromKeyPath:@"AdditSypara" toKeyPath:@"AdditSypara" withMapping:lo_addMapping];
    
    [lo_reqMapping addPropertyMapping:authRelationship];
    [lo_reqMapping addPropertyMapping:searchRelationship];
    [lo_reqMapping addPropertyMapping:addRelationship];
    
    NSString* path = il_url;
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:lo_reqMapping
                                                                                   objectClass:[RequestContract class]
                                                                                   rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKObjectMapping* lo_response_mapping = [RKObjectMapping mappingForClass:iresp_class];
    
    [lo_response_mapping addAttributeMappingsFromArray:ilist_resp_mapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:lo_response_mapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:_base_url]];
    [manager addRequestDescriptor:requestDescriptor];
    [manager addResponseDescriptor:responseDescriptor];
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    [manager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    
    [manager postObject:ao_form path:path parameters:nil
                success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    
                    ilist_resp_result = [NSMutableArray arrayWithArray:result.array];
                    if (_callBack) {
                        _callBack(ilist_resp_result,NO);
                    }
                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    RKLogError(@"Operation failed with error: %@", error);
                    NSString *str_error=[NSString stringWithFormat:@"%@",error];
                    if ([str_error rangeOfString:@"Code=-1001"].location!=NSNotFound) {
                        if (_callBack) {
                            _callBack(ilist_resp_result,YES);
                        }
                    }else{
                        if (_callBack) {
                            _callBack(ilist_resp_result,NO);
                        }
                    }
                    
                }];
}
@end
