function argcheck(invar,default,r)

%ARGCHECK is a nifty little function that will set the default for any
%variable that is not assigned (or assigned empty) in a function call.  Not
%only does this save typing by replacing the three-line:
%
%if nargin < 1 || isempty(myvar)
%    myvar = defaultvalue;
%end
%
%but it also allows for the input arguments to shifted in order during
%function development without having to change the argument checking code
%that already exists.  Useful?  I hope so!
%
%Usage:  ARGCHECK('INVAR',DEFAULT,'R')
%
%Inputs: INVAR   - The variable name we are checking, make a string
%        DEFAULT - The default value for that variable.  If DEFAULT is
%                  empty, that means no default value, and a missing
%                  INVAR will error
%        R       - An optional "return" variable, 1 if argument was present, 0 if absent
%
%Written by Jeffrey Johnson 7-30-08
%Updated to return the R variable 3-22-10

if nargin < 1 || isempty(invar) || ~isstr(invar)
    help argcheck
    error('Incorrect usage of ARGCHECK!')
end

if nargin < 2
    default = [];
end

if nargin == 3 && isstr(r)
    ret = 1;
else
    ret = 0;
end

x = ['exist(''' invar ''',''var'')'];
y = evalin('caller',x);  %y is 0 if variable does not exist, 1 if it does

if y  %if the variable exists, check to see if it is empty
    x2 = ['isempty(' invar ')'];
    y2 = evalin('caller',x2); %y2 is 0 if not empty, 1 if empty
    settodefault = y2;  %set variable to default if it is empty
else
    settodefault = 1;  %set variable to default if it does not exist
end

if settodefault
    if ~isempty(default)
        assignin('caller',invar,default);
        if ret
            assignin('caller',r,0);  %return 0 if variable was absent
        end
    else
        error(['Variable ' invar ' was not specified and does not have a default value!'])
    end
else
    if ret
        assignin('caller',r,1);  %return 1 if variable was present
    end
end
