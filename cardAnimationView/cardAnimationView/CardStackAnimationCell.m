

#import "CardStackAnimationCell.h"

@interface CardStackAnimationCell ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation CardStackAnimationCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:(arc4random() %1000) /1000.0 - 0.2 alpha:1];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 450) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        self.tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tableView];
        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",self.model.count];
    cell.textLabel.textColor = [UIColor redColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)setModel:(CardModel *)model {
    _model = model;
    [self.tableView reloadData];
}

@end
