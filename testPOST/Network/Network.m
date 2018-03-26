//
//  Network.m
//  中港車司機版
//
//  Created by Mingcol on 15/11/24.
//  Copyright (c) 2015年 mingcol. All rights reserved.
//

#import "Network.h"
#import <UIKit/UIKit.h>

@implementation Network


+(NSData *)postNetWorkURL:(NSString *)url andDictionary:(NSDictionary *)dictionary{
    
    NSData *data1 = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *string = [[NSString alloc]initWithData:data1 encoding:NSUTF8StringEncoding];
    
    //设置请求体
    NSString *bodyString = [NSString stringWithFormat:@"request=%@",string];
    
    //创建请求
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    //设置请求超时的时间
    [theRequest setTimeoutInterval:20];
    //请求方式
    [theRequest setHTTPMethod:@"POST"];
    
    //设置http body
    [theRequest setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //NSLog(@"url:%@",[NSString stringWithFormat:@"%@%@",url,bodyString]);

     NSURLResponse *response;
     NSError *error;
    //开始请求
    NSData *resultData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    //json 数据中的 null 值转换为 "" 再解析
    NSString *resultString = [[NSString alloc]initWithData:resultData encoding:NSUTF8StringEncoding];
    NSString *str = [resultString stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"data:%@",resultData);
    //NSLog(@"error:%ld",(long)error.code);
    
    return data;
}

//上传图片
+(NSData *)imageNetworkURL:(NSString *)url andDictionary:(NSDictionary *)dic{

    
    NSString *name = @"currentImage.png";
    //获取沙盒目录 （并拼接路径）
    NSString *path =[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:name];

    //1.创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    //2 。设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //分界线标示符
    NSString *twitterfor = @"AaB03x";
    //分界线 --AaB03x
    NSString *mpboundary = [[NSString alloc]initWithFormat:@"--%@",twitterfor];
    //结束符 AaB03x--
    NSString *endMpboundary = [[NSString alloc]initWithFormat:@"%@--",mpboundary];
    
    //要上传的图片
   UIImage *images =[[UIImage alloc]initWithContentsOfFile:path];

    NSData *imageData;
    //获取图片的 data（判断图片的格式）
    if(UIImageJPEGRepresentation(images, 1.0)){
        imageData = UIImageJPEGRepresentation(images,0.2);
    }else if (UIImagePNGRepresentation(images)){
        imageData = UIImageJPEGRepresentation(images,0.2);
        
    }else{
        imageData = nil;
    }
    
    //HTTP body 的字符串
    NSMutableString *body =[[NSMutableString alloc]init];

    //请求体设置
    NSData *datass = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *str3 = [[NSString alloc]initWithData:datass encoding:NSUTF8StringEncoding];
    
    body = [Network setParamsKey:@"request" value:[NSString stringWithFormat:@"%@",str3] body:body];
    
    body = [Network setParamsKey:@"pic" value:[[NSBundle mainBundle] pathForAuxiliaryExecutable:path] body:body];
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",mpboundary];
    //声明文件字段，文件名
    [body appendFormat:@"Content-Disposition: form-data; name=\"pic\"; filename=\"currentImage.png\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMpboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将file的data加入
    [myRequestData appendData:imageData];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",twitterfor];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:myRequestData];
   
    //开始请求
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    return data;
}

+(NSMutableString*)setParamsKey:(NSString*)key value:(NSString *)value body:(NSMutableString*)body{
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //添加字段名称，换2行
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
    //添加字段的值
    [body appendFormat:@"%@\r\n",value];
    return body;
}

//上传视频
+(NSData *)videoNetworkURL:(NSString *)url andDictionary:(NSDictionary *)dic andPath:(NSString *)path{
    
    //1.创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    //2 。设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //分界线标示符
    NSString *twitterfor = @"AaB03x";
    //分界线 --AaB03x
    NSString *mpboundary = [[NSString alloc]initWithFormat:@"--%@",twitterfor];
    //结束符 AaB03x--
    NSString *endMpboundary = [[NSString alloc]initWithFormat:@"%@--",mpboundary];
    
    //要上传的二进制文件
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    
    //HTTP body 的字符串
    NSMutableString *body = [[NSMutableString alloc]init];
    
    //请求体设置
    NSData *datass = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *str3 = [[NSString alloc]initWithData:datass encoding:NSUTF8StringEncoding];
    
    body = [Network setParamsKey:@"request" value:[NSString stringWithFormat:@"%@",str3] body:body];
    
    body = [Network setParamsKey:@"video" value:[[NSBundle mainBundle] pathForAuxiliaryExecutable:path] body:body];
    
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",mpboundary];
    //声明文件字段，文件名
    [body appendFormat:@"Content-Disposition: form-data; name=\"video\"; filename=\"video.mp4\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: video/mp4\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMpboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将file的data加入
    [myRequestData appendData:imageData];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",twitterfor];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    
    //设置http body
    [request setHTTPBody:myRequestData];

    //开始请求
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    return data;
}

@end
