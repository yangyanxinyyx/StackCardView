

#import "ViewController.h"
#import "CardStackAnimationView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"开始");
    
    CardStackAnimationView *v = [[CardStackAnimationView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    v.center = self.view.center;
    [self.view addSubview:v];
}

@end
