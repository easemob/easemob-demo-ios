//
//  EMChatViewController+Translate.m
//  EaseIM
//
//  Created by lixiaoming on 2021/11/16.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "EMChatViewController+Translate.h"
#import "TranslateTextBubbleView.h"
#import "EMMessageCell.h"
#import <objc/runtime.h>

@implementation EMChatViewController (Translate)
- (NSMutableArray<EaseExtMenuModel *> *)customCellLongPressExtMenuItemArray:(NSMutableArray<EaseExtMenuModel*>*)defaultLongPressItems customCell:(UITableViewCell*)customCell
{
    NSArray<UIGestureRecognizer *>* gestureRecognizers = customCell.gestureRecognizers;
    if(gestureRecognizers.count > 0 && [customCell isKindOfClass:[EMMessageCell class]]) {
        EMMessageCell* cell = (EMMessageCell*)customCell;
        if(cell.model.message.body.type != EMMessageTypeText)
            return defaultLongPressItems;
        UIGestureRecognizer * gestureRecognizer = [gestureRecognizers objectAtIndex:0];
        CGPoint pt = [gestureRecognizer locationInView:customCell.contentView];
        __weak typeof(self) weakself = self;
        if([self point:pt insideView:cell.msgView] && cell.model.message.status == EMMessageStatusSucceed) {
            if(!cell.translateResult.showTranslation) {
                EaseExtMenuModel *translateMenu = [[EaseExtMenuModel alloc]initWithData:[UIImage imageNamed:@"translate"] funcDesc:NSLocalizedString(@"translate", nil) handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
                    if (isExecuted) {
                        [weakself translateMenuItemAction:cell];
                    }
                }];
                [defaultLongPressItems addObject:translateMenu];
            }
            return defaultLongPressItems;
        }
        if([self point:pt insideView:cell.translateView]) {
            EaseExtMenuModel *hideMenu = [[EaseExtMenuModel alloc]initWithData:[UIImage imageNamed:@"hide"] funcDesc:NSLocalizedString(@"hide", nil) handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
                if (isExecuted) {
                    [weakself hideTranslateMenuItemAction:cell];
                }
            }];
            NSMutableArray<EaseExtMenuModel *> * menuAarray =[NSMutableArray<EaseExtMenuModel *> array];
            [menuAarray addObject:hideMenu];
            if(cell.translateResult.translateTimes < 2) {
                EaseExtMenuModel *retanslateMenu = [[EaseExtMenuModel alloc]initWithData:[UIImage imageNamed:@"translate"] funcDesc:NSLocalizedString(@"retranslate", nil) handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
                    if (isExecuted) {
                        [weakself showAlertControllerWithMessage:NSLocalizedString(@"retranslatePrompt", nil) title:NSLocalizedString(@"translate", nil) handler:^(UIAlertAction *action) {
                            [weakself translateCell:cell];
                        }];
                        
                    }
                }];
                [menuAarray addObject:retanslateMenu];
            }
            return menuAarray;
        }
        
    }
    return defaultLongPressItems;
}

-(BOOL)point:(CGPoint)pt insideView:(UIView*)view
{
    if(pt.x >= view.frame.origin.x && pt.x <= (view.frame.origin.x + view.frame.size.width) && pt.y >= view.frame.origin.y && pt.y <=  (view.frame.origin.y + view.frame.size.height))
        return YES;
    return NO;
}

- (void)hideTranslateMenuItemAction:(EMMessageCell*)cell
{
    cell.translateResult.showTranslation = NO;
    [[TranslateManager sharedManager] updateTranslateResult:cell.translateResult conversation:cell.model.message.conversationId];
    NSIndexPath* path = [self.chatController.tableView indexPathForCell:cell];
    if(path) {
        [self.chatController.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (void)translateCell:(EMMessageCell*)cell
{
    if(cell.model.message.body.type != EMMessageTypeText)
        return;
    [self.translatingMsgIds addObject:cell.model.message.messageId];
    NSIndexPath* path = [self.chatController.tableView indexPathForCell:cell];
    if(path) {
        [self.chatController.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }
    EMTextMessageBody* textMsgBody = (EMTextMessageBody*)cell.model.message.body;
    __weak typeof(self) weakself = self;
    [[TranslateManager sharedManager] translateMessage:cell.model.message.messageId text:textMsgBody.text language:[EMDemoOptions sharedOptions].language conversationId:cell.model.message.conversationId completion:^(EMTranslateResult * _Nullable msg, EMError * _Nullable err) {
        [self.translatingMsgIds removeObject:cell.model.message.messageId];
        if(err) {
            [self showHint:@"翻译失败"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(path) {
                [weakself.chatController.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }];
}

- (void)translateMenuItemAction:(EMMessageCell*)cell
{
    EMTranslateResult* result = [[TranslateManager sharedManager] getTranslationByMsgId:cell.model.message.messageId];
    if(!result) {
        [self translateCell:cell];
    }else{
        // 展示
        result.showTranslation = YES;
        [[TranslateManager sharedManager] updateTranslateResult:result conversation:cell.model.message.conversationId];
        cell.translateResult = result;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* path = [self.chatController.tableView indexPathForCell:cell];
            if(path) {
                [self.chatController.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }
}

- (NSMutableSet<NSString*>*)translatingMsgIds
{
    NSMutableSet<NSString*>* dic = objc_getAssociatedObject(self,@selector(translatingMsgIds));
    if(!dic) {
        dic = [NSMutableSet<NSString*> set];
        objc_setAssociatedObject(self, @selector(translatingMsgIds), dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dic;
}
@end
