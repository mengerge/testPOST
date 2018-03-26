//
//  Network.h
//
//  Created by Mingcol on 15/11/24.
//  Copyright (c) 2015年 mingcol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Network : NSObject

//post
+(NSData *)postNetWorkURL:(NSString *)url andDictionary:(NSDictionary *)dictionary;

//上传图片
+(NSData *)imageNetworkURL:(NSString *)url andDictionary:(NSDictionary *)dic;

//上传视频
+(NSData *)videoNetworkURL:(NSString *)url andDictionary:(NSDictionary *)dic andPath:(NSString *)path;

@end
