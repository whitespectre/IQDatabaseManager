//
//  InsertViewController.m
//  DatabaseManager
//
//  Created by Canopus 4 on 31/01/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "InsertViewController.h"
#import "MyDatabaseManager.h"

@interface InsertViewController ()
{
    __weak IBOutlet UITextField *textFieldName;
    __weak IBOutlet UITextField *textFieldEmail;
    __weak IBOutlet UITextField *textFieldPhoneNumber;
    __weak IBOutlet UITextView *textViewComment;
    __weak IBOutlet UISwitch *switchUpdateIfExist;
}

@end

@implementation InsertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (IBAction)saveClicked:(UIButton *)sender
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          textFieldName.text,kName,
                          textFieldEmail.text,kEmail,
                          textFieldPhoneNumber.text,kPhoneNumber,
                          textViewComment.text,kComment,
                          nil];
    
    if (switchUpdateIfExist.on)
    {
        [[MyDatabaseManager sharedManager] insertUpdateRecordInRecordTable:dict];
    }
    else
    {
        [[MyDatabaseManager sharedManager] insertRecordInRecordTable:dict];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
