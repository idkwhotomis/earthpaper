#import "Tweak.h"


@interface SBWallpaperViewController : UIViewController 

@end



//%hook SBWallpaperViewController
//- (void)viewWillAppear:(BOOL)animated {
//    if (currentwallpaper){
//        [self view].hidden = YES;
//    }
//    %orig;
//}
//%end

%hook SBWallpaperImage
+ (id)alloc {
    if (enabled){
        return nil;
    }
    return %orig;
}
%end



%hook SBIconController

- (void)viewDidLoad {
    %orig;

    //backdrop = [[CustomClass alloc] initWithFrame:[[[[self view] superview] superview] bounds]];

    //wallpaperImageViewHS.bounds = CGRectInset(wallpaperImageViewHS.frame, -50, -50);
    //[backdrop setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //[backdrop setContentMode:UIViewContentModeScaleAspectFill];
    //[backdrop setClipsToBounds:YES];
    //backdrop.backgroundColor = [UIColor blackColor];
    //[[[[self view] superview] superview] insertSubview:backdrop atIndex:0];
    
    wallpaperImageViewHS = [[UIImageView alloc] initWithFrame:[[self view] bounds]];

    //wallpaperImageViewHS.bounds = CGRectInset(wallpaperImageViewHS.frame, -50, -50);
    [wallpaperImageViewHS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [wallpaperImageViewHS setContentMode:UIViewContentModeScaleAspectFill];
    [wallpaperImageViewHS setClipsToBounds:YES];
    [[self view] insertSubview:wallpaperImageViewHS atIndex:1];
    [self refreshWall];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshWall) 
                                                 name:@"com.idkwhotomis.earthpaperobjc.setwallpaper"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if (currentwallpaper) {	//if the cache image has an image linked to it 
        [wallpaperImageViewHS setImage:currentwallpaper];
    } else { //if it doesn't, set image view to nothing
        [wallpaperImageViewHS setImage:nil];
    }
}

%new
-(void)refreshWall{
    if (currentwallpaper) {	//if the cache image has an image linked to it 
        [wallpaperImageViewHS setImage:currentwallpaper];
    } else { //if it doesn't, set image view to nothing
        [wallpaperImageViewHS setImage:nil];
    }
}


%end
