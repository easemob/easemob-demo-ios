//
//  EMChatViewController+ReportMessage.m
//  EaseIM
//
//  Created by li xiaoming on 2022/8/12.
//  Copyright © 2022 li xiaoming. All rights reserved.
//

#import "EMChatViewController+ReportMessage.h"

@implementation EMChatViewController (ReportMessage)

- (void)reportMenuItemAction:(EMChatMessage *)message
{
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    void(^block)(UIAlertAction*) = ^(UIAlertAction*action) {
        UIAlertController* showReason = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"report.reason", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [showReason addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"report.reason", nil);
            textField.delegate = self;
        }];
        NSString* tag = action.title;
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString* reason = showReason.textFields[0].text;
            [EMClient.sharedClient.chatManager reportMessageWithId:message.messageId tag:tag reason:reason completion:^(EMError * _Nullable error) {
                if(error) {
                    [EMAlertController showErrorAlert:[NSString stringWithFormat:NSLocalizedString(@"report.failed", nil),error.errorDescription]];
                }else{
                    [EMAlertController showSuccessAlert:NSLocalizedString(@"report.success", nil)];
                }
            }];
        }];
        [showReason addAction:okAction];
        [showReason addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:showReason animated:NO completion:nil];
    };
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"report.politics", nil) style:UIAlertActionStyleDefault handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"report.pornography", nil) style:UIAlertActionStyleDefault handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"report.advertisement", nil) style:UIAlertActionStyleDefault handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"report.abuse", nil) style:UIAlertActionStyleDefault handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"report.violent", nil) style:UIAlertActionStyleDefault handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"report.contraband", nil) style:UIAlertActionStyleDefault handler:block]];
    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"report.other", nil) style:UIAlertActionStyleDefault handler:block]];
    [self presentViewController:alertVC animated:NO completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    return newLength <= 500;
}
@end
