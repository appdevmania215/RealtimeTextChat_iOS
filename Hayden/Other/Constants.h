//
//  Constants.h
//  Hayden
//
//  Created by Matti on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#ifndef Hayden_Constants_h
#define Hayden_Constants_h

#define COLORPurple         [UIColor colorWithRed:162/255.f green:75/255.f blue:221/255.f alpha:1.f]
#define COLORDarkPurple     [UIColor colorWithRed:133/255.f green:79/255.f blue:170/255.f alpha:1.f]
#define COLORRed            [UIColor colorWithRed:242/255.f green:78/255.f blue:78/255.f alpha:1.f]

#define LOGGEDNAME          @"LoginEmail"
#define LOGGEDPWD           @"LoginPassword"

#define FirebaseURL         @"https://hayden.firebaseio.com"

#endif


/*
2014.04.10
Hi Matti,

Please update me every 2 days with your app progress...

Also, I would like to share a little bit more about the app.

Just to refresh, Hayden is based on user cross-matching, meaning users match your photo with others to find you a perfect date. Every time users swipe they gain 1 swipe credit. Users collect swipe credits that they can use to find a match for themselves. If users dont want to match others or if they want to get a lot of swipe credits really fast they can buy 100 credits for $0.99.
The more credits they use the more potential matches they get. Each time a user presses on a "heart" button it becomes a match. That same exact match will be then shown to other users and if they too press the "heart" button then it means there is definitely a good correlation between a guy and a girl.

The final match is determined by the number of "hearts" collected in the process. To determine a match there should be a minimum of 10 "hearts" with at least 5 "hearts" for a specific guy/girl and have at least 3 "hearts" more than the 2nd best match. Here are the minimum criteria for the final match:

10 hearts: 5, 2, 1, 1, 1

or

10 hearts: 5, 1, 1, 1, 1, 1


Another criteria would be to have users matched who are within 5 years apart from one another (for example: 20 and 25 is ok, 20 and 27 is not ok)

Please let me know if this makes sense or if you have any questions for me.

Thanks,
-Alex
*/