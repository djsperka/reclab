function varargout = clockseed(ultrafast)

%CLOCKSEED creates a random seed from the system clock and applies it to
%Matlab's random number generator (using the 'seed' option).  It will
%return the seed used.
%CLOCKSEED takes into account the seed rules for the 'seed' option, which
%are not explicitly expressed in the help for the RAND function.  Those
%rules are empirically determined to be as follows:
%
%1. Only the integer portion of a seed is considered
%2. Any seed equal to or greater than 4294967295 ((2^32)-1) places the algorithm in
%   the same state **Note: With the new syntax any seed greater than (2^32)-1
%   will cause an error.
%
%sum(100*clock), which appears to be Matlab's favorite method, is a crappy,
%crappy way to seed the random number generator.  Why?  Well, first off,
%even though it will give you a "new" random seed every 100th of a second,
%only 14200 of those 8.64 million seeds are unique.  As an example, if you
%were to seed the clock at precisely 10:09 AM, the seed would be identical
%to if you seeded at precisely 9:10 AM, or at 12:07 PM, or at 18:01 (PM),
%etc.  Even worse, on a day-by-day basis (assuming year is constant) you
%only add 100 new, unique seeds for each difference in the date-sum.  That
%is, on 4-10-2012 there are 14200 possible seeds.  On 4-11-2012 there are
%also 14200 possible seeds.  But taken together, over the period of 4-10 to
%4-11 there are only 14300 possible seeds - 14100 of the seeds on the 11th 
%were also possible on the 10th.  This is terrible, and I can't justify
%using this method.
%
%Instead of using sum(100*clock), we can instead use the "now" (datenum) 
%version of the system clock, which has the format 734969.42985441 where the
%portion greater than zero represents the number of days since January 1 of 
%the year 1 A.D. and the decimal portion is a decimal representation of the
%time of day (i.e. 0.5 = 12 noon).  Obviously the datenum will never
%repeat, but it has much more precision than the random number generator
%seeds can handle (see above point 2).  The best solution for this is to
%choose a period over which you're willing to risk a repeat.  For this
%script, I have decided that "myseed = floor(rem(now,10^4)*10^5);" is just
%about right - this will guaranteed not repeat over any given 27+ year
%period.  However, on the flip side, if the random clock is re-seeded with
%the system clock too closely (within 0.864 seconds), the clock output
%will not have rolled to a new state and you will be resetting the random 
%seed to the same state.
%
%Despite the fact that re-seeding the random number generator (rather than
%simply allowing the seed to continue) is poor form and can according to
%the MathWorks results in less randomness, I'll accept that you might for
%some reason feel that you need to do this.  FOr instance, you may be
%creating multiple white noise stimuli with different seeds which you are
%saving so that the stimuli can be recreated later.  Such a batch process
%might "re-seed" multiple times per second. So I have included the
%ULTRAFAST input to allow for quick clock-based re-seeding.
%
%If the ULTRAFAST input is non-zero, the function will assume that you may
%indeed be resetting the random seed within about a second of the last time
%you last set it, and will shift its "focus" on the datenum to the fastest
%portion. However, repeats may occur at a low probability.
%
%So, in short: In the standard case there is no chance of seed repeat over
%a 27+ year period, but unique seeds may only be generated every 0.864
%seconds.  In the ULTRAFAST case, the period is only 8.64 seconds, so there
%is 1 in 10^9 possibility of repeat over a reasonable time scale, but
%arbitrarily fast reseeding will be unique.
%
%The maximum allowable random seed is ~4.29 x 10^9, but in either case we
%are generating only 10^9 seeds before repeat, so we are using somewhat 
%less than 1/4 of the allowable dynamic range of the random seed pool.  
%
%Written by Jeffrey Johnson 04-09-08, updated 9-2-10 because the old syntax
%for setting a random seed was deprecated.  Update includes both "straight
%up" seeding and ultafast seeding.  Also now uses VARARGOUT so that if the 
%user does not specify an output argument, no output is set even if the 
%CLOCKSEED call is not terminated by a semicolon.  Nifty!
%Updated 4-10-12 because of the realization that sum(clock*100) sucks.

if nargin < 1 || isempty(ultrafast)
    ultrafast = 0;
end

%This syntax has apparently been deprecated.  Despite the fact that it was
%perfectly good.
% myseed = floor(rem(now,10^-4)*10^13);  %get a random value from the system clock, 9 digit integer,
%                                        %largest digit cycles in about 10 seconds
% 
% rand('seed',myseed);

%Here is the new syntax
if ultrafast
    myseed = floor(rem(now,10^-4)*10^13);
else
    %myseed = sum(100*clock);
    myseed = floor(rem(now,10^4)*10^5);
end
s = RandStream.create('mt19937ar','seed',myseed);  %seed with system clock
RandStream.setGlobalStream(s);  %and set this value to the default stream

%If there aren't any output arguments specified, don't assign MYSEED to VARARGOUT, and no 
%suppression is necessary.  Nifty!
if nargout 
    varargout{1} = myseed;
end