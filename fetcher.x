#import "fetcher.h"
#import <Foundation/Foundation.h>
#import "Tweak.h"

UIImage* getImageFromURL(NSString* urlstring){
    NSURL *url = [NSURL URLWithString:urlstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data){
        return nil;
    }
    UIImage *img = [[UIImage alloc] initWithData:data];
    return img;
}


NSString* getURLForTimeXY(CFAbsoluteTime time, int x, int y){
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSDate* date= [NSDate dateWithTimeIntervalSince1970:time];
    [df setDateFormat:@"dd"];
    NSString* myDayString = [df stringFromDate:date];

    [df setDateFormat:@"MM"];
    NSString* myMonthString = [df stringFromDate:date];

    [df setDateFormat:@"yyyy"];
    NSString* myYearString = [df stringFromDate:date];
    
    [df setDateFormat:@"HH"];
    NSString* myHourString = [df stringFromDate:date];
    
    [df setDateFormat:@"mm"];
    NSString* myMinuteString = [df stringFromDate:date];
    
    //return [NSString stringWithFormat:@"A string: %@, a float: %1.2f", @"string", 31415.9265];
    NSString* link = [NSString stringWithFormat:@"https://himawari8-dl.nict.go.jp/himawari8/img/D531106/%dd/550/%@/%@/%@/%@%@000_%i_%i.png", scale, myYearString, myMonthString, myDayString, myHourString, [myMinuteString substringToIndex:1], x, y];   
    NSLog(@"%@",link);
    return link; 
}


NSArray* getTilesForTime(CFAbsoluteTime time){
    id arrayOfArrays[scale];
    for (int x = 0; x < scale; ++x){
        id strings[scale];
        for (int y = 0; y < scale; ++y){
            strings[y] = getImageFromURL(getURLForTimeXY(time,x,y));
            if (!strings[y]){strings[y] = getImageFromURL(getURLForTimeXY(time,x,y));}
            if (!strings[y]) return nil;
        }
        id arrayOfStrings = [NSArray arrayWithObjects:strings count:scale];
        arrayOfArrays[x] = arrayOfStrings;
    }
    id array = [NSArray arrayWithObjects:arrayOfArrays count:scale];
    return array;
}





UIImage* getCurrentImage(){
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight<screenWidth){
        // swap values
        NSLog(@"swapping height, width");
        screenWidth = screenWidth + screenHeight; // 1+2 =3
        screenHeight = screenWidth - screenHeight; // 3 -2 = 1
        screenWidth = screenWidth - screenHeight; // 3-1 = 2;
    }
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    int localwidth = (int)(screenWidth*screenScale); 
    int localheight = (int)(screenHeight*screenScale); 
    NSLog(@"%i",localwidth);
    NSLog(@"%i",localheight);
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent()+978307200- offset;
    NSArray* Tiles = getTilesForTime(time);
    if (!Tiles) return nil;
    UIGraphicsEndImageContext();
    

    //CGSize size = CGSizeMake(width*scale, height*scale);
    CGSize size = CGSizeMake(width*scale, height*scale);

    UIGraphicsBeginImageContext(size);

    //[baseimg drawInRect:CGRectMake(0, 0, width*scale, height*scale)];

    for (int x = 0; x < scale; ++x){
        for (int y = 0; y < scale; ++y){
            [Tiles[x][y] drawInRect:CGRectMake(x*width, y*height, width, height)];
        }
    }
    UIImage *uncroppedimage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext(); 
    
    CGSize imageSize = CGSizeMake(localwidth,localheight);
    UIColor *fillColor = [UIColor blackColor];
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    //UIImage *baseimg = UIGraphicsGetImageFromCurrentImageContext();
    //[baseimg drawInRect:CGRectMake(0, 0, 1125, 2436)];

    [uncroppedimage drawInRect:CGRectMake(0, localheight/2 -localwidth/2 + localheight/9, localwidth, localwidth)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];

    // Save image.
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    UIGraphicsEndImageContext();
    return image;
}
