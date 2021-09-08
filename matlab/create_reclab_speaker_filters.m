function create_reclab_speaker_filters

%This function will go through a directory and create the filters to be
%used for trying to determine the approximate dB level of an arbitrary
%stimulus being played through a known speaker.

%For now, we will be creating filters only for FFT filtering (slower, more
%frequency resolution, but way better) 

%Note that a lot of tested functionality has been pulled out of this file,
%but remains in the "_old" version on Kershaw.

%Also note that any file present in the directory that cannot be
%name-parsed (including an Array16.mat) will result in an error.  The directory should be "clean".

stf_pulse_duration = 5;  %set this appropriately, in seconds, will throw an error in subfunction if less than 2

%mydir = 'E:\Core Grant\reclab\Calib4_newamp\';  %directory which contains speaker transfer information
%mydir = 'C:\Data\Calib\Array16Calib\';  %directory for Recanzone lab, make this different than the write directory
%mydir = 'E:\Core Grant\reclab2017\StandaloneCalib\';  %directory which contains speaker transfer information
%mydir = 'I:\Data\Calib\Array15Calib\';
%mydir = 'I:\Data\Calib\Array16Calib\';
mydir = 'I:\Data\Calib\StandaloneCalib\';

%write16File = 'E:\Core Grant\reclab\Calib4_newamp\Array16.mat';  %filename for writing, Kershaw
%write15File = 'E:\Core Grant\reclab\Calib4_newamp\Array15.mat';

%writeFile = 'C:\Data\Calib\Array16.mat';  %filename for writing, Recanzone lab
%writeFile = 'E:\Core Grant\reclab2017\StandaloneCalib\Standalone.mat';  %filename for writing, Recanzone lab
%write15File = 'C:\Data\Calib\Array15.mat';  %do this separately, from a different directory
%writeFile = 'I:\Data\Calib\Array15.mat\';
%writeFile = 'I:\Data\Calib\Array16.mat\';
writeFile = 'I:\Data\Calib\Standalone.mat\';

AFFT = [];  %initialize structure for A data, using Fourier filtering

%We're going to need to automatically parse the stimulus name.  I've come
%up with what appears to be a reasonable naming scheme that should work.
%The naming scheme looks like this:
%
%spkr8_uniform_A_83.2dB_fft.mat
%
%spkr8   - the number indicates which speaker, we will need to have different
%          filenames if speaker numbers duplicate on different arrays
%uniform - indicates uniform noise was used to gather the STF, currently no
%          other options are used
%A       - indicates A-weighting was applied inside the sound level meter
%          as the STF was being recorded.  The other option is "open",
%          which indicates no weighting applied.  I'm not sure which is
%          truly the best way to go here.  Note that A-weighting is being
%          recorded at an FSD of 100, while open is being recorded at an
%          FSD of 120, so there may be a 20 dB difference between the two
%          versions.
%83.2dB  - indicates the decibel level of the sound as determined by the
%          sound level meter
%fft     - indicates that the file holds fft data, the other option is
%          "raw", which contains raw data

%variables we'll fill when we parse the filename
speaker = 0;
isAweight = 0;
dB = 0;
isFFT = 0;

numSpeakersProcessed = 0;

%for filtering filter the speaker transfer function (raw version), because damn is it noisy
%h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.01,0.1,1,60);
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.001,0.01,.1,100);  %this is quite a bit smoother - dialing in parameters on this is quite difficult, but this looks OK
des=design(h,'equiripple'); %Lowpass FIR filter


x = dir(mydir);
for i = 3:length(x)  %skip '.' and '..'
    %% parse filename
    fname = x(i).name;
    %get speaker number
    [spkr remainder] = strtok(fname,'_');
    r = findstr(spkr,'r');
    if length(r) ~= 1
        error(['Filename ' fname ' does not have a standard speaker specification!']);
    end
    speaker = str2num(spkr(r+1:end));
    %skip uniform
    [trash remainder] = strtok(remainder,'_');  %get rid of first underscore AND "uniform"
    %get weighting
    [w remainder] = strtok(remainder,'_');  %get rid of first underscore
    if strcmpi(w,'a')
        isAweight = 1;
    elseif strcmpi(w,'open')
        isAweight = 0;
    else
        error(['Filename ' fname ' does not have a standard weighting specification!']);
    end
    %get dB
    [d remainder] = strtok(remainder,'d');  %d will have a leading underscore
    dB = str2num(d(2:end));
    if isempty(dB)
        error(['Filename ' fname ' does not have a standard dB specification!']);
    end
    %get FFT/raw file type
    [trash remainder] = strtok(remainder,'_');  %remainder will have a leading underscore
    ftype = remainder(2:4);
    if strcmpi(ftype,'fft')
        isFFT = 1;
    elseif strcmpi(ftype,'raw')
        isFFT = 0;
    else
        error(['Filename ' fname ' does not have a standard file type specification!']);
    end
    %OK, the filename has been successfully parsed
    
    %% Do .raw file version, this goes to FFT space
    if isFFT == 0
        [outdB outax] = speaker_transfer_function2([mydir fname],stf_pulse_duration);  %load raw file, get speaker transfer function in dB down

        %outdB2 = outdB;  %do not zero-phase filter the STF
        outdB2=filtfilt(des.Numerator,1,outdB); %zero-phase filter the STF
        
        %this allows us to look at the filtering result against the
        %original STF
        %figure, plot(outax,outdB,'b'), hold on, plot(outax,outdB2,'r')
        %title(['speaker ' num2str(speaker) ', Aweight = ' num2str(isAweight)]);
        
        %We may want to set a seed so all STFs have the same basis
        seed = 9488477;
        s = RandStream.create('mt19937ar','seed',seed);  %seed with system clock
        RandStream.setGlobalStream(s);
        
        %we need to know what spl level that calc_spl_wfm thinks a
        %full-scale white noise is.
        sampfreq = 100000;
        stimulus = rand(1,sampfreq)-0.5;  %make uniform-distributed noise
        stimulus = stimulus / max(abs(stimulus));  %scale to -1 to 1
        stimulus = stimulus * 32767;  %scale to 16 bit
        stimulus_STF = filt_stim(stimulus,sampfreq,outdB2,outax);   %filter with the speaker transfer function
        %hmm = filt_stim(stimulus,sampfreq,outdB,outax);   %filter with the unadjusted speaker transfer function
        spl_guess = calc_spl_wfm(stimulus_STF,[],sampfreq,400,0,1); %and get an spl guess with no reference adjustment
        %hmm = calc_spl_wfm(hmm,[],sampfreq,400,0,1)
        %spl_guess_orig = calc_spl_wfm(stimulus,[],sampfreq,400,0,1)
        adj = dB - spl_guess;  %this ADJ value can now be fed to calc_spl_wfm to get values in "real" dB

        %and put the stuff in a structure
        if isAweight
            AFFT(speaker).stf = outdB2;
            AFFT(speaker).xax = outax;
            AFFT(speaker).dB = adj;  
            numSpeakersProcessed = numSpeakersProcessed + 1;  %keep count of the number of figures processed
        end        
    end
%     max(stimulus)
%     min(stimulus)
%     max(stimulus_STF)
%     min(stimulus_STF)
%     figure, plot(stimulus(1:1000)), hold on, plot(stimulus_STF(1:1000),'r')
%assignin('base','AFFT',AFFT);
%    error('testing')

end


%% Write the data thus created to file
save(writeFile,'AFFT');

disp(['Number of speakers processed is ' num2str(numSpeakersProcessed)])









function [outdB outax] = speaker_transfer_function2(loc,stimdur)

%[OUTDB OUTAX] = SPEAKER_TRANSFER_FUNCTION2(LOC,STIMDUR) opens the .mat-file speaker transfer function 
%in LOC and returns the transfer function in dB in OUTDB and the frequency values in OUTAX.
%The function expects LOC to be a .mat file with the data in Ch2 and the timing info in Ch30.
%
%STIMDUR is the duration of each pulse, in seconds.
%
%This function just does all the little math that needs to be done for convenience

if stimdur < 2
    error('Error!  The stimulus duration is simply too short to effectively chop one half second off each side!');
end

%%%calculate an estimated speed-of-sound delay, in seconds, will convert to samples later
dist = 1;  %in meters, approx, on high end, should measure
speed_sound = 343;  %in meters/second
delay = dist/speed_sound;  %delay in seconds

%%%load the file
data = load(loc);


%%%check to see if the actual times of the stimulus onset have been recorded - there was an error
%%%in the original CED script causing no timing data to be recorded
if ~isfield(data,'Ch30')
    error('Error!  The data appears to not contain a Channel 30! (Timing channel)');
end
times = data.Ch30.times;



%%%get data
in = data.Ch2.values';  %change input data to row vector
fs = 1/data.Ch2.interval;  %extract sampling frequency


delay = round(delay*fs);  %speed-of-sound delay in samples, rounded
halfsec = round(0.5*fs);  %one half second in samples
points = round(times*fs);  %estimated times of onset, in samples
points(end+1) = points(end)+points(end)-points(end-1);  %hallucinate a "final" point
nsamp = round(fs*(stimdur-0.5));
%figure, plot(in), hold on

points = points + delay;
for i = 1:length(points)-1 %for each repetition of the stimulus
    start = points(i) + halfsec;
    %plot([start start],[min(in) max(in)],'r')
    %plot([start+nsamp start+nsamp],[min(in) max(in)],'m')
    data2(i,:) = in(start:start-1+nsamp);  %get samples corresponding to each repetition
end


for i = 1:size(data2,1)
    [hrir2 outax] = fftax(data2(i,:),round(fs),1);  %get rid of the reflected portion of the data
    hrir(i,:) = abs(hrir2);  %get ABS, toss out the phase
end

%%%get rid of DC component
hrir = hrir(:,2:end);
outax = outax(2:end);  %yes, the out axis, too

%%%get mean amplitude across all measurements
hrir = mean(hrir,1);  %specify which direction to take the mean in case there is only one measurement  

%%%convert to dB
outdB = 20*log10(hrir./max(hrir));  %amplitude version, THIS ONE, THIS ONE!
%outdB = 10*log10(hrir./max(hrir));  %power version, I think this is right NO






%% Subfunction FILT_STIM %%%
%so we don't have to repeat the code a bunch of times
function out = filt_stim(in,fs,stf,stfax)

[stimfft stimax] = fftax(in,fs,1);  %get FFT of stimulus
stimamp = abs(stimfft);  %get amplitude of FFT
stimphase = angle(stimfft)';  %get phase of FFT, columnize it
DC = stimamp(1);  %hold on to DC component
stimamp = stimamp(2:end);  %truncate DC component
stimax = stimax(2:end);  %truncate DC component on stimulus x-axis
%stimdB = 20*log10(stimamp./max(stimamp));  %convert stimulus to dB
stimdB = 20*log10(stimamp);  %convert stimulus to dB
[trash stf2]  = runningmean2(stfax,stf,stimax,'c',1,'b',0,1);  %resample STF, if necessary
%stimdB = stimdB + stf2';  %filter in dB/frequency space
%figure, plot(stimax,stf2,'g')
%hold on, plot(stfax,stf,'k')
%figure, plot(stimdB,'b')
stimdB = stimdB' + stf2';  %filter in dB/frequency space, so for some reason now I double swap orientation
%figure, plot(stimdB,'r')
stimamp2 = db2ratio(stimdB);  %get filtered stim in amplitude/frequency space
%stimamp2 = stimamp2.*(mean(stimamp)/mean(stimamp2));  %equalize the overall amplitude or it won't be close
if mod(length(in),2)  %if it's odd, we'll need to reflect the last Fourier value
    myend = length(stimamp2);
else  %otherwise, do not reflect the last Fourier value
    myend = length(stimamp2)-1;
end
stimamp2 = [DC; stimamp2; stimamp2(myend:-1:1)];   %concatenate DC component, reflected portion, will be col vector
stimphase = [stimphase; stimphase(myend:-1:1)];  %reflect phase component as well (reflection removed by FFTAX)
stimfft2 = mag_phase2sin_cos(stimamp2,stimphase);
out = ifft(stimfft2,'symmetric');



%% subfunction runningmean2
function [xout yout] = runningmean2(xin,yin,xout,bintype,binwidth,filttype,plotflg,silent)

%RUNNINGMEAN2 - a function which will compute a running mean of input data, designed to replace
%               RUNNINGMEAN
%
%Usage:   [XOUT YOUT] = RUNNINGMEAN(XIN,YIN,XOUT,BINTYPE,BINWIDTH,FILTTYPE,PLOTFLG)
%
%Inputs:  XIN       - The X values of the data to be analyzed
%         YIN       - The Y values of the data to be analyzed
%         XOUT      - The X values of the return data
%         BINTYPE   - The type of bin to use (constant, linear, octave)
%                       'constant','c' - same bin width at all X values
%                       'linear','l' - bin width is a constant times the
%                       bin center value
%                       'octave','o' - bin width is specific number of
%                       octaves centered around each bin center value
%                       Default = constant
%         BINWIDTH  - If bintype is 'c', the width of the bin.  If bintype 
%                       is 'l', the width in percentage of center value.
%                       If bintype is 'o', the number of octaves surrounding each bin
%                       value.  Default = 1/20th of X range (constant),
%                       1/10 (linear), or 1 (octave)
%         FILTTYPE  - The type of filter to use, 'b' - boxcar, 'g' - Gaussian
%                     Default = 'b'oxcar
%         PLOTFLG   - If 1, open a new window and plot the results
%         SILENT    - If 1, does not give "resampling" warning
%
%Outputs: XOUT      - The X values of the chosen bins (centers)
%         YOUT      - The running means


%The main problem with RUNNINGMEAN (aside from its slowness) is that it's difficult to control
%the desired x-axis of the output. After lots and lots (and way too much) thought, I've come to
%the conclusion that it's probably best to simply specify the desired x-axis.  It will reduce
%the computation time required to calculate the x-axis (which might be excessive) and will
%prevent a bunch of NaN outputs on octave-based means.  Direct control of the output axis.
%Should just plain be better overall.   Note that the first output, XOUT, is pretty redundant
%here, but for compatibility I'm keeping it.  Not that compatibility really matters, as it's a
%new function, not an update.  But still.

%Argument checking
argcheck('xin');
argcheck('yin');
argcheck('xout',xin,'xdiff');  %XDIFF will be 1 if XOUT is specified, 0 if XOUT is empty (and therefore XIN == XOUT)
argcheck('bintype','c');
if lower(bintype(1)) == 'c'
    argcheck('binwidth',(max(xout)-min(xout))/20);
    binwidth = round(binwidth);  %this has to be an integer value
elseif lower(bintype(1)) == 'l'
    argcheck('binwidth',0.1);
elseif lower(bintype(1)) == 'o'
    argcheck('binwidth',1);
else
    error(['Unrecognized bin type "' bintype '"!'])
end
argcheck('filttype','b');
argcheck('plotflg',0);
argcheck('silent',0);

%check for user error
if numel(xin) ~= numel(yin)
    error('ERROR! XIN and YIN must have the same number of elements!')
end
if ~isvector(xin) || ~isvector(yin)
    error('ERROR! Both XIN and YIN must be vectors!')
end


%should warn if "new" bin centers will produce more than one sample per collected sample
%at the same time, we can find the nearest neighbor for assigning XOUT
%honestly, it's pretty easy to catch the "more than one sample" while solving the
%nearest neighbor problem, so...this is primarily a nearest neighbor section
if xdiff  %should check if XDIFF is 1, if 0, by definition bin centers are the same
    if iscolvector(xin)  %maintain column/row vector orientation, but for work below, use row vectors
        xin2 = [-inf xin' inf];  %pad with -inf, inf
    else
        xin2 = [-inf xin inf];
    end
    %assume that the inputs are unique and properly sorted - if not, that's an issue anyways
    [xint xinsame xoutsame] = intersect(xin2,xout);  %get intersection of in and out X axes, XINSAME holds indices of XIN2 that are exactly found in XOUT, etc.
    xoutdiffind = setdiff(1:length(xout),xoutsame);  %XOUTDIFFIND holds indices of XOUT that need to have nearest neighbor (NN) problem solved
    xoutdiff = xout(xoutdiffind);  %XOUTDIFF holds the values from XOUT that need NN
    if iscolvector(xoutdiff)
        xcombo = [xin2 xoutdiff'];  %XCOMBO holds the concatenation of ALL XIN2 values and the XOUT values that need NN 
    else
        xcombo = [xin2 xoutdiff];
    end
    xcombo_xin2_ind = 1:length(xin2);  %get indices from XCOMBO that are from XIN2, also an index into XIN2
    xcombo_xout_ind = length(xin2)+1:length(xcombo);  %get indices from XCOMBO that are from XOUTDIFF
    [xcombo srt] = sort(xcombo);  %sort XCOMBO, SRT holds original index numbers
    [trash sort_xout_indices] = ismember(xcombo_xout_ind,srt);  %holds the indices into XCOMBO that have XOUTDIFF values
    sortdiff = diff(sort_xout_indices);  %holds the difference
    sortdiff = 1-sortdiff;  %is zero if SORT_XOUT_INDICES are contiguous, negative otherwise
    sortdiff = ~~sortdiff;  %is zero is SORT_XOUT_INDICES are contiguous, 1 otherwise
    if any(sortdiff == 0)  %sidestep to warn if there are adjacent values
        if ~silent
            disp('Warning!  The output axis produces more than one value for each input value!  Creating mean anyway!')
        end
    end
    sortdifflow = [1 sortdiff];  %pad a 1 for the low end - if 1, it's good to go on the low side
    sortdiffhigh = [sortdiff 1]; %pad a 1 for the high end - if 1, it's good to go on the high side
    count = 1;
    for i = 1:length(sortdifflow)  %now, go through and label how many zeroes there are in a row, +2
        if sortdifflow(i) ~= 1
            count = count + 1;
            sortdifflow(i) = count;
        else
            count = 1;
        end
    end
    count = 1;
    for i = length(sortdiffhigh):-1:1
        if sortdiffhigh(i) ~= 1
            count = count + 1;
            sortdiffhigh(i) = count;
        else
            count = 1;
        end
    end
    %now, SORTDIFFLOW holds how many indices we have to go DOWN from an index in
    %SORT_XOUT_INDICES to get to a value from XIN2, and SORTDIFFHIGH holds how many we have to
    %go UP.
    xcombo_xin2_inds = [(sort_xout_indices - sortdifflow); (sort_xout_indices + sortdiffhigh)];  %the indices in the top/bottom row of this will be the XIN2 indices that "flank" the XOUT indices
    xcombo_xin2_inds(xcombo_xin2_inds > length(xcombo)) = length(xcombo);  %in case any values are out-of-bounds
    xcombo_xin2_inds(xcombo_xin2_inds < 1) = 1;  %in case any values are out-of-bounds
    xcombo_xin2_vals = xcombo(xcombo_xin2_inds); %the values of the XIN2 entries above and below each XOUT entry
    if isrowvector(xcombo_xin2_vals)
        xcombo_xin2_vals = xcombo_xin2_vals';
    end
    xcombo_xout_vals = [xcombo(sort_xout_indices); xcombo(sort_xout_indices)];  %value of XOUT indices, repeated to be same size as above
    [trash loc] = min(abs(xcombo_xin2_vals-xcombo_xout_vals));  %LOC holds the locations of the closest XIN2 value
    loc = loc + ([0:length(loc)-1]*size(xcombo_xin2_vals,1));  %LOC holds the "vertical position", calculate the vertical + horizontal
    closest_xin2_val = xcombo_xin2_vals(loc);  %now index into the matrix of XIN2 values, result will hold the closest XIN2 value!
    [trash diffinds] = ismember(closest_xin2_val,xin);  %these are the indices that correspond to the correct values on XIN!
    [trash sameinds] = ismember(xint,xin);  %these are the indices that correspond to the correct values on XIN, when they're the same.
    xin2xout(xoutsame) = sameinds;  
    xin2xout(xoutdiffind) = diffinds;
    
else  %if ~xdiff
    xin2xout = 1:length(xout);  %if XIN and XOUT are the same, the indices to retrieve are simple 
end

%do we even care about ERRTYPE?  FILTER2 actually doesn't return anything like this, and the
%definition of error based on a running window may be kind of iffy.

%so what's the plan?
%constant boxcar, just use filter and take the exact (or nearest) value
%constant gaussian - tricky.  Ah, just shift 'em.
%so if it's constant, just use filter, then select the nearest value

yout = ones(size(xout))*NaN;  %initialize YOUT, so we don't have to "grow inside a loop" 

if bintype == 'c'  %constant width bin, easy
    if filttype == 'b'
        flt = ones(1,binwidth)/binwidth;  %make a boxcar filter, normalize
    elseif filttype == 'g'
        flt = normpdf(linspace(-3,3,binwidth));  %make Gaussian filter, the "edge" of the filter will have a value
                                                 %of about 1.1 - 1.2% of the max value of the filter
        flt = flt./sum(flt);  %normalize filter
    else
        error(['Unrecognized filter type "' filttype '"!!'])
    end

    %[yflt zf] =filter(flt,1,yin);  %apply filter
    yflt = conv(yin,flt,'same');  %OK, so 1: CONV does the same thing as FILTER, without a lag (which varies based on size of filter)
                                  %and 2: CONV does it in about half the time
                                  %and 3: CONV does it in sensible terms instead of this bizarre numerator, denominator shit.  
                                  %I guess I don't get the point of FILTER to calculate a mean

    yout = yflt(xin2xout);  %resample (without interpolation)
    
    %yout = interp1(xin,yflt,xout);  %this one line takes about twice as long as the umpteen
    %lines above, but at 320 ms isn't outrageous.
    
else
    error(['Bintype "' bintype '" is not implemented!'])
end





%% stupid subfunction because runningmean2 calls it

function t = iscolvector(x)
%ISCOLVECTOR True for column vector input.
%
%   ISCOLVECTOR(X) returns 1 if X is a column vector and 0 otherwise.
%
%   An array is considered a colum vector if the length along each
%   dimension, except possibly the first, is never larger than one.  That
%   is, SIZE(X, DIM) <= 1 for all DIM except possibly when DIM = 1.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:51:06 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   t = ndims(x) == 2 & size(x, 2) == 1;


   

%% subfunction isrowvector   
   
function t = isrowvector(x)
%ISROWVECTOR True for row vector input.
%
%   ISROWVECTOR(X) returns 1 if X is a row vector and 0 otherwise.
%
%   An array is considered a row vector if the length along each dimension,
%   except possibly the second, is never larger than one.  That is,
%   SIZE(X, DIM) <= 1 for all DIM except possibly when DIM = 2.

%   Author:      Peter J. Acklam
%   Time-stamp:  2002-03-03 13:50:55 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   t = ndims(x) == 2 & size(x, 1) == 1;
