#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)

+ (NSString *) MD5StringWithContentsOfFile: (NSString *) path;
//- (NSString *) MD5String;

@end


@implementation NSString (MD5)

+ (NSString *) MD5StringWithContentsOfFile: (NSString *) path {
  NSData *data = [NSData dataWithContentsOfFile: path];
  unsigned char *result = malloc(16);
  CC_MD5([data bytes], [data length], result);
  NSString *r = [NSString stringWithFormat:
                 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 result[0], result[1],  result[2],  result[3],  result[4],  result[5],  result[6],  result[7],
                 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
                 ];
  free(result);
  return r;
}

// Return the hexadecimal string representation of the MD5 digest of the target
// NSString. In this example, this is used to generate a statistically unique
// ID for each fortune file.
//- (NSString *) MD5String {
//  CC_MD5_CTX digestCtx;
//  unsigned char digestBytes[CC_MD5_DIGEST_LENGTH];
//  char digestChars[CC_MD5_DIGEST_LENGTH * 2 + 1];
//  NSRange stringRange = NSMakeRange(0, [self length]);
//  unsigned char buffer[128];
//  NSUInteger usedBufferCount;
//  CC_MD5_Init(&digestCtx);
//  while ([self getBytes:buffer
//              maxLength:sizeof(buffer)
//             usedLength:&usedBufferCount
//               encoding:NSUnicodeStringEncoding
//                options:NSStringEncodingConversionAllowLossy
//                  range:stringRange
//         remainingRange:&stringRange])
//    CC_MD5_Update(&digestCtx, buffer, usedBufferCount);
//  CC_MD5_Final(digestBytes, &digestCtx);
//  for (int i = 0;
//       i < CC_MD5_DIGEST_LENGTH;
//       i++)
//    sprintf(&digestChars[2 * i], "%02x", digestBytes[i]);
//  return [NSString stringWithUTF8String:digestChars];
//}

@end
