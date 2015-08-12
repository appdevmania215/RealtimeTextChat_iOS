//
//  ChatViewController.m
//  Hayden
//
//  Created by Matti on 17/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "ChatViewController.h"
#import <Firebase/Firebase.h>
#import "Utils.h"
#import "ProgressHUD.h"

@interface ChatViewController () < UIActionSheetDelegate >
{
    NSString *roomname;
    Firebase *firebase;
    
    NSString *lastdate;
    NSString *messageType;
    NSDate *messageDate;
    NSString *messageStr;
    UIImage *messageImg;
    
    BOOL isLoading;
    
    NSMutableArray *users;
    NSMutableArray *messages;
    
    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage *incomingBubbleImageData;
    
    JSQMessagesAvatarImage *avatar2ImageData;
}
@end

@implementation ChatViewController

#pragma mark - Class methods
+ (UINib*)nib{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesViewController class]) bundle:[NSBundle mainBundle]];
}
+ (instancetype)messagesViewController{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([JSQMessagesViewController class]) bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title =@"CHATS";
    
    UIBarButtonItem *OKBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStylePlain target:self action:@selector(clickReport)];
    self.navigationItem.rightBarButtonItem = OKBarItem;
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.navigationItem.title;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont systemFontOfSize:15.f];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(BackPressed)];
    
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [PFUser currentUser][@"name"];
    
    roomname = [Utils generateChatRoom:[PFUser currentUser].objectId second:self.secondUser.objectId];
    
    messages = [[NSMutableArray alloc] init];
    
    
    firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/messages/%@", FirebaseURL, roomname]];
    [firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:snapshot.value[@"user1"]
                                             senderDisplayName:@"user2"
                                                          date:[Utils dateFromString:snapshot.value[@"date"] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"]
                                                          text:snapshot.value[@"message"]];
        [messages addObject:msg];
        [self finishSendingMessageAnimated:YES];
    }];

    self.inputToolbar.contentView.leftBarButtonItem = nil;
//    /**
//     *  You can set custom avatar sizes
//     */
//    if (![NSUserDefaults incomingAvatarSetting]) {
//        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
//    }
//
//    if (![NSUserDefaults outgoingAvatarSetting]) {
//        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
//    }
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    avatar2ImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"dollar"]
                                                                  diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", mainImageURL, self.otherAvatarUrl]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        avatar2ImageData.avatarImage = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
//        avatar2ImageData.avatarHighlightedImage = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
//        avatar2ImageData.avatarPlaceholderImage = [JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
//    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

-(void)clickReport{
    NSString * manStr = [NSString stringWithFormat:@"Report %@", self.secondUser[@"name"]];
    
    UIActionSheet *modeMenu = [[UIActionSheet alloc]
                               initWithTitle: nil
                               delegate:self
                               cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                               otherButtonTitles:manStr,
                               nil];
    [modeMenu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Report man
        [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self
                                                          selector: @selector(send_report) userInfo: nil repeats: NO];
        
    }else{
        //
    }
    
    [actionSheet isHidden];
}

-(void)send_report{
    [ProgressHUD showSuccess:@"Report sent!" Interaction:NO];
}

- (void)BackPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - UIImagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        if (img == nil) {
            img = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */

    NSDictionary *dict = @{@"user1" : [PFUser currentUser].objectId,
                          @"user2" : self.secondUser.objectId,
                          @"message" : text,
                           @"date" : [Utils dateToString:[NSDate date] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"]};
    [[firebase childByAutoId] setValue:dict];
}

- (void)didPressAccessoryButton:(UIButton *)sender{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Photo"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@"Take Photo", @"Camera Roll", nil];
//    [sheet showFromToolbar:self.inputToolbar];
//    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
//    imagePicker.navigationBar.titleTextAttributes = textAttributes;
//    
//    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{

}

#pragma mark - JSQMessages CollectionView DataSource
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return outgoingBubbleImageData;
    }
    
    return incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    else {
        return avatar2ImageData;
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    //    JSQMessage *currentmsg = [messages objectAtIndex:indexPath.item];
    //    if (indexPath.item > 0) {
    //        JSQMessage *prevmsg = [messages objectAtIndex:indexPath.item - 1];
    //        if (![currentmsg.senderId isEqualToString:prevmsg.senderId]) {
    //            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:currentmsg.date];
    //        } else{
    //            NSTimeInterval secs = [currentmsg.date timeIntervalSinceDate:prevmsg.date];
    //            if (secs > 60) {
    //                return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:currentmsg.date];
    //            }
    //        }
    //    } else{
    //        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:currentmsg.date];
    //    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return nil;//[[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
