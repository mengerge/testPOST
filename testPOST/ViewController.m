//
//  ViewController.m
//  testPOST
//
//  Created by Mingcol on 2018/3/26.
//  Copyright © 2018年 Mingcol. All rights reserved.
//

#import "ViewController.h"
#include "Network.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self postwork];
}



-(void)postwork{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"home",@"action", nil];
        
        NSData *data = [Network postNetWorkURL:@"" andDictionary:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data == nil) {
                
            }else{
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                NSLog(@"dic:%@",dic);
            }
            
        });
    });
    
    
}

@end
