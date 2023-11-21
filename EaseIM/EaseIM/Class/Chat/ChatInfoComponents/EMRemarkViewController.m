//
//  EMRemarkViewController.m
//  EaseIM
//
//  Created by li xiaoming on 2023/9/15.
//  Copyright © 2023 li xiaoming. All rights reserved.
//

#import "EMRemarkViewController.h"
#import "ContactsStore.h"

@interface EMRemarkViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) NSString* userId;
@property (nonatomic,strong) NSString* remark;
@property (nonatomic,strong) UITextField* remarkField;
@property (nonatomic,copy) void (^complete)(NSString *remark);

@end

@implementation EMRemarkViewController

- (instancetype)initWithUserId:(NSString *)userId remark:(NSString *)remark  complete:(void (^)(NSString *remark))complete
{
    self = [super init];
    if (self) {
        _userId = userId;
        _remark = remark;
        _complete = complete;
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"contact.settingRemark", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveRemark)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backleft"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [self.view addSubview:self.remarkField];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.remarkField endEditing:YES];
}

- (void)saveRemark
{
    __weak typeof(self) weakSelf = self;
    NSString* remark = self.remarkField.text;
    [EMClient.sharedClient.contactManager setContactRemark:self.userId remark:remark completion:^(EMContact * _Nullable contact, EMError * _Nullable aError) {
        if (!aError) {
            [ContactsStore.sharedInstance setContact:weakSelf.userId remark:remark];
            [weakSelf backAction];
            if(weakSelf.complete) {
                weakSelf.complete(remark);
            }
        } else {
            [self showHint:[NSString stringWithFormat:NSLocalizedString(@"contact.setRemarkFaile", nil),aError.errorDescription]];
        }
    }];
}

- (UITextField *)remarkField
{
    if (!_remarkField) {
        _remarkField = [[UITextField alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 60)];
        _remarkField.placeholder = NSLocalizedString(@"contact.inputRemark", nil);;
        _remarkField.delegate = self;
        UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 50, 15)];
        rightLabel.font = [UIFont systemFontOfSize:12];
        rightLabel.textColor = [UIColor grayColor];
        _remarkField.backgroundColor = UIColor.whiteColor;
        _remarkField.rightView = rightLabel;
        _remarkField.rightViewMode = UITextFieldViewModeAlways;
        _remarkField.leftViewMode = UITextFieldViewModeAlways;
        _remarkField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 15)];
        _remarkField.text = self.remark;
        rightLabel.text = [NSString stringWithFormat:@"%ld/16  ",self.remark.length];
        
    }
    return _remarkField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(str.length > 16)
        return NO;
    UILabel* rightLabel = (UILabel*)textField.rightView;
    if ([rightLabel isKindOfClass:[UILabel class]]) {
        rightLabel.text = [NSString stringWithFormat:@"%ld/16  ",str.length];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
