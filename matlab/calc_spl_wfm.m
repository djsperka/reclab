function spl = calc_spl_wfm(inloc,dBref,fs,windw,Aweight,shush)

%CALC_SPL_WFM - a function that will take as its input the location of a .WFM file, open it,
%and estimate its SPL
%
%Usage: SPL = CALC_SPL_WFM(INLOC,DBREF,WINDW,FS,AWEIGHT)
%
%Inputs:  INLOC   - The location of the stimulus to load, or the actual stimulus if already
%                   loaded
%         DBREF   - A reference dB level. Default = 0, see below for usage
%         FS      - The sampling frequency, for use in doing multiple windows, WINDW must be
%                   specified. If left empty one calculation will be made for the entire signal
%                   However, if doing A-weighting, FS must be set, set WINDW to [] for no
%                   windowing.
%         WINDW   - The duration, in ms, for the sampling window, FS must be specified
%         AWEIGHT - If 1, perform A-weighting of signal.  If 0, do not, default = 0
%         SHUSH   - If 1, silences warning for too-large sample window, useful when "batching"
%                   Default = 0
%
%Output:  SPL     - The SPL, in dB, corrected to reference level
%
%For instance, to estimate the relative dB of a signal for calibration purposes, first 
%determine the dB (relative to 1) of a signal whose SPL has been measured with an SPL meter.
%
% spl = calc_spl_wfm('mystim.wfm',[],100000,400,1);  %let's say this result is (arbitrarily) 32
% reflevel = 65 - spl;  %and let's say that the stimulus was measured at 65 dB under circumstances X
% spl2 = calc_spl_wfm('mystim2.wfm',reflevel,100000,400,1);  %spl2 will now be mystim2's SPL
%                                                            under circumstances X
%
%Written by Jeffrey Johnson 12-14-09

%Argument Checking
if nargin < 1
    error('You done messed up!')
end

if ~ischar(inloc)
    noload = 1;
else
    noload = 0;
end

if nargin < 2 || isempty(dBref)
    dBref = 0;
end
if nargin < 3
    fs = [];
end
if nargin < 4
    windw = [];
end
if nargin < 5 || isempty(Aweight)
    Aweight = 0;
end
if nargin < 6 || isempty(shush)
    shush = 0;
end

if ((isempty(fs) && ~isempty(windw)) || (isempty(windw) && ~isempty(fs))) && ~shush
    disp('Warning!  If either FS or WINDW is specified, the other may not be empty!  Will not window SPL calculations!')
    windw = [];  %WINDW empty will signal no windowing
end

%load stimulus if given location, or put given stimulus into STIM
if ~noload
    stim = wfmread(inloc);  %gee, that's easy!
else
    stim = inloc;
end

%Perform A-weighting filter of stimulus, if applicable
warning off %ADSGN gives unknown warnings which don't seem relevant
if Aweight
    [B,A] = adsgn(fs);  %design the A filter
    stim = filter(B,A,stim);  %filter the stimulus
end
warning on

%Square voltage at each point
stim = stim.^2;

%Create nifty "windowing" matrix, if windowing
%Window every millisecond - every sample creates a matrix far too big for Matlab to handle
if ~isempty(windw)
   numsamp = fs*windw/1000;  %get number of points in the window
   %ms5samp = 5*fs/1000;  %number of samples in 5 milliseconds  %note that this line was used for the up/down, though it shouldn't make much difference.
   windowsamp = (windw/5)*fs/1000;  %number of samples allowing 5x overlap in the window
   if numsamp >= length(stim)
       if ~shush
           disp(['Warning! Requested windowing requires ' num2str(numsamp) ' samples per window, only ' num2str(length(stim)) ' samples available!  Using a single window!']);
       end
       pow = stim;  %set POW to entire signal
   else
       %[X Y] = meshgrid(0:ms5samp:length(stim)-numsamp,1:numsamp);  %note that this line was used for the up/down, though it shouldn't make much difference.
       [X Y] = meshgrid(0:windowsamp:length(stim)-numsamp,1:numsamp);
       Z = X + Y;  %create windowing matrix
       pow = stim(Z);  %fill POW with signal power in 1-step windows
   end
else
    pow = stim;
end

%get mean square (MS), which is equivalent to RMS^2  (we didn't root, and we didn't square)
%we could take the root to get RMS, but then we'd have to square it to use
%the power version of the dB conversion - it just takes a step out
pow = mean(pow);  %will be scalar if no window, or a row vector if windowing


%get dB measurement (relative to arbitrary "1") for all RMS^2 values 
warning off  %don't bother with possible log-of-zero warnings
dB = 10.*log10(pow/1);  %when using power, use 10*log10(P1/P2) rather than the amplitude version (20*log10(A1/A2))
warning on

%get maximum dB value from windows used
dB = max(dB);
%dB = mean(dB);

%give SPL value!
spl = dB + dBref;