//
//  KMQNSDictionaryValidator.m
//  Pods
//
//  Created by Weinan Qiu on 2015-10-24.
//
//

#import "KMQNSDictionaryValidator.h"

@implementation KMQNSDictionaryValidator

+ (id<KMQValidator>)validator {
    return [[KMQNSDictionaryValidator alloc] init];
}

+ (id <KMQValidator> _Nonnull)dictionaryContainsKeys:(NSArray * _Nonnull)mandatoryKeys {
    KMQNSDictionaryValidator *validator = [[KMQNSDictionaryValidator alloc] init];
    validator.mandatoryKeys = mandatoryKeys;
    return validator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minSize = 0;
        self.maxSize = NSUIntegerMax;
    }
    return self;
}

- (BOOL)isValid:(id)object errors:(NSArray *__autoreleasing *)errors {
    NSAssert([object isKindOfClass:[NSDictionary class]], @"This validator can only deal with NSDictionary");
    NSDictionary *dict = object;
    NSMutableArray *localErrors = [NSMutableArray array];
    NSMutableDictionary *userInfo = [@{@"dictionary": dict} mutableCopy];
    
    if (![self passNullTest:dict]) {
        [localErrors addObject:[NSError errorWithDomain:KMQValidationErrorDomain code:kKMQValidationErrorDictionaryIsNull userInfo:userInfo]];
        return NO;
    }
    
    if (![self passMinSizeTest:dict]) {
        [userInfo setObject:@(self.minSize) forKey:KMQValidationDictionaryMinSizeKey];
        [localErrors addObject:[NSError errorWithDomain:KMQValidationErrorDomain code:kKMQValidationErrorDictionaryTooSmall userInfo:userInfo]];
        return NO;
    }
    
    if (![self passMaxSizeTest:dict]) {
        [userInfo setObject:@(self.maxSize) forKey:KMQValidationDictionaryMaxSizeKey];
        [localErrors addObject:[NSError errorWithDomain:KMQValidationErrorDomain code:kKMQValidationErrorDictionaryTooBig userInfo:userInfo]];
        return NO;
    }
    
    if (![self passMandatoryKeyTest:dict]) {
        [userInfo setObject:self.mandatoryKeys forKey:KMQValidationDictionaryMandatoryKey];
        [localErrors addObject:[NSError errorWithDomain:KMQValidationErrorDomain code:kKMQValidationErrorDictionaryMissingMandatoryKey userInfo:userInfo]];
        return NO;
    }
    
    if (![self passDisallowedKeyTest:dict]) {
        [userInfo setObject:self.disallowedKeys forKey:KMQValidationDictionaryDisallowedKey];
        [localErrors addObject:[NSError errorWithDomain:KMQValidationErrorDomain code:kKMQValidationErrorDictionaryContainsDisallowedKey userInfo:userInfo]];
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark - Tests

- (BOOL)passNullTest:(NSDictionary *)dict {
    return self.allowNull || dict != nil;
}

- (BOOL)passMinSizeTest:(NSDictionary *)dict {
    return dict.count >= self.minSize;
}

- (BOOL)passMaxSizeTest:(NSDictionary *)dict {
    return dict.count <= self.maxSize;
}

- (BOOL)passMandatoryKeyTest:(NSDictionary *)dict {
    for (NSString *key in dict) {
        if (!dict[key])
            return NO;
    }
    return YES;
}

- (BOOL)passDisallowedKeyTest:(NSDictionary *)dict {
    for (NSString *key in dict) {
        if (dict[key])
            return NO;
    }
    return YES;
}

@end
