//
//  InterfaceController.m
//  CardsApp WatchKit Extension
//
//  Created by Mark Hall on 2015-05-12.
//  Copyright (c) 2015 Mark Hall. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController ()

@property (strong, nonatomic) IBOutlet WKInterfaceImage* cardView;
@property (strong, nonatomic) IBOutlet WKInterfaceImage* card2View;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *cardsListLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *getNewCardsButton;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *hitButton;
@property (strong, nonatomic) NSString *deckId;
@property (strong, nonatomic) NSString *cardListString;
@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    self.cardListString = @"0";
    [self.getNewCardsButton setEnabled:NO];
    [self doGetNewDeck];
    [self getNewCards];
}

- (IBAction)getNewCards
{
    [self.cardView setAlpha:1];
    [self.card2View setAlpha:1];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://deckofcardsapi.com/api/draw/%@/?count=2", self.deckId]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];

    NSURLResponse* response;
    NSError* error;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    NSString *errorString = [responseDict objectForKey:@"error"];
    if (!error && !errorString) {
        NSArray* cardsArray = [responseDict objectForKey:@"cards"];
        NSString* image1URLString = [[cardsArray objectAtIndex:0] objectForKey:@"image"];
        NSString* image2URLString = [[cardsArray objectAtIndex:1] objectForKey:@"image"];
        NSURL* imageURL = [NSURL URLWithString:image1URLString];
        NSURL* image2URL = [NSURL URLWithString:image2URLString];
        UIImage* cardImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        UIImage* card2Image = [UIImage imageWithData:[NSData dataWithContentsOfURL:image2URL]];
        self.cardListString = @"0";
        self.cardListString = [self getSumForNumber:[[cardsArray objectAtIndex:0] objectForKey:@"value"]];
        self.cardListString = [self getSumForNumber:[[cardsArray objectAtIndex:1] objectForKey:@"value"]];
        [self.cardView setImage:cardImage];
        [self.card2View setImage:card2Image];
        if ([self.cardListString integerValue] == 21) {
            [self.hitButton setEnabled:NO];
            [self.cardsListLabel setText:[NSString stringWithFormat:@"Count: %@ WINNER",self.cardListString]];
        }
        else{
            [self.cardsListLabel setText:[NSString stringWithFormat:@"Count: %@", self.cardListString]];
        }
        [self.getNewCardsButton setEnabled:NO];
        [self.hitButton setEnabled:YES];
    }
}
- (void)doGetNewDeck {
    [self.cardView setAlpha:0];
    [self.card2View setAlpha:0];
    NSURL* url = [NSURL URLWithString:@"http://deckofcardsapi.com/api/shuffle/?deck_count=6"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse* response;
    NSError* error;
    //send it synchronous
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    if (!error) {
        self.deckId = [responseDict objectForKey:@"deck_id"];
        self.cardListString = @"";
        [self.cardsListLabel setText:self.cardListString];
    }
}
- (IBAction)newDeck
{
    [self doGetNewDeck];
    [self.getNewCardsButton setEnabled:YES];
    [self.hitButton setEnabled:NO];
}
- (IBAction)hitMe {
    [self.card2View setAlpha:0];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://deckofcardsapi.com/api/draw/%@/?count=1", self.deckId]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse* response;
    NSError* error;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    NSString *errorString = [responseDict objectForKey:@"error"];
    if (!error && !errorString) {
        NSArray* cardsArray = [responseDict objectForKey:@"cards"];
        NSString* image1URLString = [[cardsArray objectAtIndex:0] objectForKey:@"image"];
        NSURL* imageURL = [NSURL URLWithString:image1URLString];
        UIImage* cardImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        [self.cardView setImage:cardImage];
        self.cardListString = [self getSumForNumber:[[cardsArray objectAtIndex:0] objectForKey:@"value"]];
        if ([self.cardListString integerValue] > 21) {
            [self.hitButton setEnabled:NO];
            [self.getNewCardsButton setEnabled:YES];
            [self.cardsListLabel setText:[NSString stringWithFormat:@"Count: %@ BUST",self.cardListString]];
        }
        else if ([self.cardListString integerValue] == 21) {
            [self.hitButton setEnabled:NO];
            [self.getNewCardsButton setEnabled:YES];
            [self.cardsListLabel setText:[NSString stringWithFormat:@"Count: %@ WINNER",self.cardListString]];
        }
        else{
            [self.cardsListLabel setText:[NSString stringWithFormat:@"Count: %@", self.cardListString]];
        }
    }
}
- (NSString *)getSumForNumber:(NSString *)number
{
    NSInteger currentSum = [self.cardListString integerValue];
    if ([number isEqualToString:@"ACE"]){
        currentSum +=11;
    }
    else if([number isEqualToString:@"KING"] || [number isEqualToString:@"QUEEN"] || [number isEqualToString:@"JACK"]){
        currentSum += 10;
    }
    else{
        currentSum += [number integerValue];
    }
    return [NSString stringWithFormat:@"%ld", (long)currentSum];
}
- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end
