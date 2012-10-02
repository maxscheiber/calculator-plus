//
//  MNSViewController.m
//  Calculator+
//
//  Created by Max Scheiber on 09/25/12.
//  Copyright (c) 2012 Max Scheiber. All rights reserved.
//

#import "MNSViewController.h"

@interface MNSViewController ()
@property (weak, nonatomic) IBOutlet UILabel *number;
@property (weak, nonatomic) IBOutlet UILabel *infixEqn;

- (IBAction)enterZero:(id)sender;
- (IBAction)enterOne:(id)sender;
- (IBAction)enterTwo:(id)sender;
- (IBAction)enterThree:(id)sender;
- (IBAction)enterFour:(id)sender;
- (IBAction)enterFive:(id)sender;
- (IBAction)enterSix:(id)sender;
- (IBAction)enterSeven:(id)sender;
- (IBAction)enterEight:(id)sender;
- (IBAction)enterNine:(id)sender;
- (IBAction)enterDecimal:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)subtract:(id)sender;
- (IBAction)multiply:(id)sender;
- (IBAction)divide:(id)sender;
- (IBAction)exponent:(id)sender;
- (IBAction)leftParens:(id)sender;
- (IBAction)rightParens:(id)sender;

- (IBAction)clear:(id)sender;
- (IBAction)equals:(id)sender;
- (IBAction)negate:(id)sender;
@end

@implementation MNSViewController
@synthesize number; //label for specific number being inputted
@synthesize infixEqn; //label for entire equation

NSMutableArray *input = nil; //stack of operators to input
NSMutableArray *output = nil; //queue of things to output in RPN
NSString *currentNumber = @""; //current number entered
NSString *currentOp = @""; //current oeprator selected
BOOL divisionByZero = false; //currently trying to divide by zero
BOOL decimalUsed = false; //ensures we do not use multiple deciaml points
                          //per number

+ (void)initialize {
    if (!input) {
        input = [[NSMutableArray alloc] init];
    }
    
    if (!output) {
        output = [[NSMutableArray alloc] init];
    }
}

- (int)precedence:(NSString*)op {
    if ([op isEqualToString: @"^"]) {
        return 4;
    }
    
    if ([op isEqualToString: @"x"] || [op isEqualToString: @"/"]) {
        return 3;
    }
    
    if ([op isEqualToString: @"+"] || [op isEqualToString: @"-"]) {
        return 2;
    }
    
    return 0;
}

- (BOOL)isOperator:(NSString*)op {
    return [self precedence: op] > 0;
}

/**
 Algorithm to convert an infix expression into reverse Polish 
 notation.
 **/
- (void)updateRPN {
    NSString* op = currentOp;
    
    if ([self isOperator: op]) {
        while ([input count] > 0 && [self precedence: op] <= [self precedence: [input objectAtIndex: [input count] - 1]]) {
            [output addObject: [input objectAtIndex: [input count] - 1]];
            [input removeObjectAtIndex: [input count] - 1];
        }
        [input addObject: op];
    }
}

/**
 Given that the input stack and output queue are updated from
 the updateRPN algorithm, computes the answer of the current
 expression the user has inputted into the program.
 **/
- (double)calculate {
    // temporary stack to track computation
    NSMutableArray *ans = [[NSMutableArray alloc] init];
    // temporary queue to push numbers and all remaining operators onto
    NSMutableArray *tmpOutput = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [output count]; i++) {
        [tmpOutput addObject: [output objectAtIndex: i]];
    }
    
    if (![currentOp isEqualToString: @"="] && ![currentNumber
        isEqualToString: @"-"]) {
        [tmpOutput addObject: currentNumber];
    }
    
    for (int i = [input count] - 1; i >= 0; i--) {
        [tmpOutput addObject: [input objectAtIndex: i]];
    }
    
    // performs the instantaneous calculation
    double tmp = 0;
    
    for (int i = 0; i < [tmpOutput count]; i++) {
        NSString* cur = [tmpOutput objectAtIndex: i];
        double x, y;
        
        if (![self isOperator: cur]) {
            [ans addObject: cur];
        }
        
        else if ([ans count] >= 2){
            x = [[ans objectAtIndex: [ans count] - 2] doubleValue];
            y = [[ans objectAtIndex: [ans count] - 1] doubleValue];
        }
        
        else {
            return [[ans objectAtIndex: 0] doubleValue];
        }
        
        if ([cur isEqualToString: @"+"]) {
            tmp = x + y;
        }
        
        else if ([cur isEqualToString: @"-"]) {
            tmp = x - y;
        }
        
        else if ([cur isEqualToString: @"x"]) {
            tmp = x * y;
        }
        
        else if ([cur isEqualToString: @"/"]) {
            if (y == 0) {
                divisionByZero = true;
                return 0;
            }
            divisionByZero = false;
            tmp = x / y;
        }
        
        else if ([cur isEqualToString: @"^"]) {
            tmp = pow(x, y);
        }
        
        if ([self isOperator: cur]) {
            [ans removeLastObject];
            [ans removeLastObject];
            [ans addObject: [NSString stringWithFormat:@"%f", tmp]];
        }
    }
    
    if ([input count] == 0) {
        return [currentNumber doubleValue];
    }
    
    return tmp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.number.text = @"";
    self.infixEqn.text = @"";
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setNumber:nil];
    [self setInfixEqn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

/**
 Generic method to push any number onto the output queue. Will
 update the RPN conversion and will calculate the new answer.
 **/
- (void)pushNumber:(id)num {
    if ([currentOp isEqualToString: @"="]) {
        return;
    }
    
    [self updateRPN];
    currentOp = @"";
    
    currentNumber = [currentNumber stringByAppendingString: num];
    self.infixEqn.text = [self.infixEqn.text stringByAppendingString: num];
    [self updateRPN];
    
    double calced = [self calculate];
    if (divisionByZero) {
        self.number.text = @"Division by zero";
    } else {
        self.number.text = [NSString stringWithFormat:@"%f", calced];
    }
}

/**
 Generic method to push any operator onto the input stack. Does not
 yet update the RPN or perform any computation.
 **/
- (void)pushOperator:(id)op {
    decimalUsed = false;
    
    if ([currentOp isEqualToString: @"="] ||
      [self isOperator: currentOp]) {
        return;
    }
    
    [output addObject: currentNumber]; //update RPN with number
    currentNumber = @"";
    currentOp = op;
    self.infixEqn.text = [self.infixEqn.text stringByAppendingString: op];
}

- (IBAction)enterZero:(id)sender {
    [self pushNumber: @"0"];
}

- (IBAction)enterOne:(id)sender {
    [self pushNumber: @"1"];
}

- (IBAction)enterTwo:(id)sender {
    [self pushNumber: @"2"];
}

- (IBAction)enterThree:(id)sender {
    [self pushNumber: @"3"];
}

- (IBAction)enterFour:(id)sender {
    [self pushNumber: @"4"];
}

- (IBAction)enterFive:(id)sender {
    [self pushNumber: @"5"];
}

- (IBAction)enterSix:(id)sender {
    [self pushNumber: @"6"];
}

- (IBAction)enterSeven:(id)sender {
    [self pushNumber: @"7"];
}

- (IBAction)enterEight:(id)sender {
    [self pushNumber: @"8"];
}

- (IBAction)enterNine:(id)sender {
    [self pushNumber: @"9"];
}

/**
 Adds a decimal point to the currentNumber
 **/
- (IBAction)enterDecimal:(id)sender {
    if (!decimalUsed) {
        [self pushNumber: @"."];
        decimalUsed = true;
    }
}

- (IBAction)add:(id)sender {
    [self pushOperator: @"+"];
}

- (IBAction)subtract:(id)sender {
    [self pushOperator: @"-"];
}

- (IBAction)multiply:(id)sender {
    [self pushOperator: @"x"];
}

- (IBAction)divide:(id)sender {
    [self pushOperator: @"/"];
}

- (IBAction)exponent:(id)sender {
    [self pushOperator: @"^"];
}

/**
 IMPLEMENTATION IS INCOMPLETE, DO NOT USE
 **/
- (IBAction)leftParens:(id)sender {
    if ([currentOp isEqualToString: @"="]) {
        return;
    }
    
    [input addObject: @"("];
    self.infixEqn.text = [self.infixEqn.text stringByAppendingString: @"("];
}

/**
 IMPLEMENTATION IS INCOMPLETE, DO NOT USE
 **/
- (IBAction)rightParens:(id)sender {
    if ([currentOp isEqualToString: @"="]) {
        return;
    }
    
    while (![[input objectAtIndex: [input count] - 1] isEqualToString: @"("]) {
        [output addObject: [input objectAtIndex: [input count] - 1]];
        [input removeObjectAtIndex: [input count] - 1];
    }
    
    [input removeObjectAtIndex: [input count] - 1];
    
    self.infixEqn.text = [self.infixEqn.text stringByAppendingString: @")"];
    self.number.text = [NSString stringWithFormat:@"%f", [self calculate]];
}

/**
 Clears number, infixEqn, and all parameters - essentially
 resets the calculator.
 **/
- (IBAction)clear:(id)sender {
    currentNumber = @"";
    currentOp = @"";
    self.infixEqn.text = @"";
    self.number.text = @"";
    [input removeAllObjects];
    [output removeAllObjects];
    divisionByZero = false;
    decimalUsed = false;
}

/**
 Equals button is mostly useless here because computation is
 performed on the fly. Equals button will ensure that nothing
 else can be inputted to the equation; must clear after using it.
 **/
- (IBAction)equals:(id)sender {
    if ([currentOp isEqualToString: @"="] ||
      divisionByZero) {
        return;
    }
    
    self.infixEqn.text = [self.infixEqn.text stringByAppendingString: @"="];
    [output addObject: currentNumber];
    currentOp = @"=";
    [self updateRPN];
    self.number.text = [NSString stringWithFormat:@"%f", [self calculate]];
}

/**
 Negates the current number. Can be used before, during, or
 after the number is being entered.
 **/
- (IBAction)negate:(id)sender {
    NSString *num = currentNumber;
    self.infixEqn.text = [self.infixEqn.text substringToIndex:
        [self.infixEqn.text length] - [num length]];
    
    [self updateRPN];
    currentOp = @"";
    
    if ([currentNumber length] == 0) {
        currentNumber = @"-";
    }
    else if ([currentNumber characterAtIndex: 0] == '-') {
        currentNumber = [currentNumber substringFromIndex: 1];
    } else {
        currentNumber = [@"-" stringByAppendingString: currentNumber];
    }
    
    self.infixEqn.text = [self.infixEqn.text stringByAppendingString:
       currentNumber];
    [self updateRPN];
    
    double calced = [self calculate];
    if (divisionByZero) {
        self.number.text = @"Division by zero";
    } else {
        self.number.text = [NSString stringWithFormat:@"%f", calced];
    }

}
@end
