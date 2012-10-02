calculator-plus
===============

iOS calculator with added functionality. Created for CIS 195

Standard features
=================

This calculator satisfies the rubric for the CIS 195 homework. It has all four basic functions - add, subtract, multiply, and divide. Input is clearable via the "CLR" button. Numbers and operators are entered via UIButtons, not keyboard input. Input is shown one number at a time. The layout is intuitive and based on other calculator layouts. Divide-by-zero is handled via an error message that does not go away until you have fixed the divide-by-zero error (for example, by turning the "0" into a "0.5" or a "02"). The calculator will not permit you to enter two operators in a row or to end on an operator, ensuring that your computation works.

Extra features
==============

The entire operation is shown in infix notation on the second "LED screen."

There is an option to negate (or re-negate, hence making it positive) the current number you are working with. You can negate before, during, or after typing the number.

This calculator also has the exponent feature enabled.

Features that do NOT work
=========================

The following features were not completed by the time the homework was due. They are all extra features, but do not click the buttons, or bad things might happen:

Parentheses <br />
Logarithm <br />
Delete button (DEL) <br />

Sources
=======
Generally used Stack Overflow / Google / Apple documentation for little questions.

Reference on RPN was found <a href="http://en.wikipedia.org/wiki/Shunting-yard_algorithm">on Wikipedia</a> and <a href="http://learnyouahaskell.com/functionally-solving-problems">on Learn you a Haskell</a>.