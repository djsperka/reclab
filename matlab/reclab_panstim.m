function [stimulus atten65 seed] = reclab_panstim(dur,sampfreq,lohz,hihz,issweep,amfreq,amdepth,amphase,tonephase,gauss,ramp,seed,pad,calib)

%RECLAB_PANSTIM - a function, called by CED's Spike2, which is capable of
%making a ton of different stimuli for the RecRoom suite.  The function can
%create tones, AM tones, BB noise, BP noise, AM noise (BB or BP), and can
%specify AM phase, tone phase, whether noise is Gaussian or uniform, ramp
%durations, and random seed.
%
%Usage: [stimulus atten65 seed] = reclab_panstim(DUR,SAMPFREQ,LOHZ,HIHZ,ISSWEEP,AMFREQ,AMDEPTH,AMPHASE,TONEPHASE,GAUSS,RAMP,SEED,PAD,CALIB)
%
%Inputs:  DUR       - Duration of the stimulus, in ms.  No default.
%         SAMPFREQ  - Sampling frequency, in Hz.  No default
%         LOHZ      - For tones, tone frequency (set HIHZ = LOHZ); for BP
%                     noise, frequency of low cutoff; for no limit or BB
%                     noise, use -1.  No default.
%         HIHZ      - For tones, tone frequency (set LOHZ = HIHZ); for BP
%                     noise, frequency of high cutoff; for no limit or BB
%                     noise, use -1.  No default.
%         ISSWEEP   - Determines how to deal with LOHZ/HIHZ. If LOHZ = HIHZ
%                     then ISSWEEP is ignored, tone is created. If ISSWEEP
%                     is 0 (default) then values will represent frequency
%                     cutoffs for BP noise. If ISSWEEP is 1, LOHZ/HIHZ will
%                     be the start and end points of an FM sweep.  Note
%                     that this is the only circumstance under which LOHZ
%                     can be greater than HIHZ - that would indicate a
%                     downward sweep.  Sweep will be logarithmic.
%         AMFREQ    - Frequency in Hz of amplitude modulation to apply to
%                     the stimulus.  Default = 0, no modulation.
%         AMDEPTH   - Depth in percent (0-100) of amplitude modulation to
%                     apply to the stimulus.  Default = 0, no modulation.
%                     Only applies if AMFREQ is non-zero.
%         AMPHASE   - Phase in degrees of amplitude modulation at onset of
%                     stimulus.  0 = 360 = envelope is 0 at t=0;
%                     180 = envelope is maximal at t=0;  Default = 0.  Only
%                     applies if AMFREQ and AMDEPTH are non-zero.
%         TONEPHASE - Phase in degrees of tone at onset of stimulus.  Uses
%                     sine phase; 0 = 0 and rising; 90 = 1; 180 = 0 and
%                     falling; 270 = -1.  Default = 0.  Only applies to
%                     tone or tone carrier.  Also not currently implemented
%                     for tone sweeps
%         GAUSS     - If 1, use Gaussian distributed noise.  If 0, use
%                     uniformly distributed noise.  If 2 <= N <= 100, use 
%                     Gaussian noise cut off at Nth percentile value of 
%                     stimulus (note that default scaling is to max value 
%                     of stimulus).  Default = 1.  Only applies to BB/BP 
%                     noise or carrier.
%         RAMP      - Duration, in ms, of onset/offset ramps using a cos^2
%                     function.  Default = 0.  Ramping is applied after all
%                     other manipulations.
%         SEED      - A random seed with which to seed Matlab's random
%                     number generator.  Only used for BB/BP noise.  If 0,
%                     will use function CLOCKSEED to set random seed with
%                     system clock.  Default = 0.
%         PAD       - The size (scalar) to pad the stimulus to.  To
%                     transfer from Matlab to CED, the CED variable must be
%                     the same size as the Matlab variable, but unlike
%                     Matlab, CED can't generate arbitrary-sized arrays.
%                     This variable tells us how big the CED destination
%                     variable is, and pads zeros longer than that.  If a
%                     1x2 vector, interpret as [FPP PAD] where FPP is front
%                     pad points, a zero buffer in points attached in front
%                     of the stimulus, PAD remains total length.  If empty,
%                     no padding.
%         CALIB     - A cell array containing the B/A coefficients for STF
%                     filtering.  If empty, there will be no calibration,
%                     but that shouldn't happen
%
%Outputs: STIMULUS  - The stimulus, returned in 16-bit integer form.
%         ATTEN65   - Approximate value used to attenuate to 65 dB, not yet
%                     implemented to return realistic values
%         SEED      - The random seed used.  If stimulus/carrier is a tone,
%                     will return 0 even if an input value of SEED is
%                     specified.
%
%This function has been designed as a one-stop shop for all your CED stimulus
%needs (except for clicks, because there's really no reason to farm those
%out).  The Recanzone lab's RecRoom program reads a stimulus definition
%file which includes all of the above inputs as columns.  Here I provide a
%single function which simply takes the entire row (each stimulus is a row
%in the file) and creates the stimulus specified.  Easy-peasy, and it makes
%coding easy from the CED side.
%
%Please note that there are fundamental problems involved with applying an
%AM envelope to a BP noise (see EA Strickland and NF Viemeister in The
%Effects Of Frequency Region And Bandwidth On The Temporal Modulation 
%Transfer Function, JASA 102(3), September 1997, 1799-1810.)  Viemeister
%proposes a solution but the implementation (see Jeff: BANDLIMITED_AM.m)
%requires far too much computational time to be viable for online stimulus
%creation.  If you wish to use bandlimited-noise-carrier AM the best method
%may be to create the stimuli offline ahead of time and load them as files.
%In the event that you do wish to create bandlimited-noise-carrier AM
%stimuli online, this program will first apply the AM and then apply the
%band filtering.  This will somewhat reduce AM depth as measured by the
%Hilbert Transform, but will ensure that no excluded frequencies are
%reintroduced (as occurs if AM is applied after band filtering).
%
%As far as timing is concerned, this takes about 15 ms to create a 50,000
%sample AM BP noise.  That ought to be the slowest to generate (AM and
%requires moving into the Fourier domain for the BP noise), and it's still
%plenty fast.
%
%When creating Gaussian noise, scaling can become an issue.  Typically we
%scale the maximum absolute value of the stimulus to the maximum output
%value (here, usually +/- 2^15-1 = +/- 32767).  This works great for
%uniform white noise, but Gaussian noise has the additional complication
%that the maximum value is on the extreme tail of the distribution and can
%vary substantially across random exemplars.  For most applications, this
%is not a problem because here we calculate and supply an attenuation value 
%for each created stimulus which can be used to bring the stimuli into 
%approximate register in volume.  However, for some purposes - specifically 
%in this case Gregg's LongNoise paradigm (which plays successive 1-second 
%stretches of Gaussian noise but cannot readjust the attenuation on the 
%fly) - we want the Gaussian noise to be approximately  equal in intensity 
%from the start. By setting the Gauss to "99", we now construct a longer
%stimulus than requested (100/99 longer) and then remove the extreme 1% of
%values to remove the large variability in scaling values.  Other values
%than "99" may be similarly requested (down to 2, which is surely not
%useful, but whatever). 
%
%Dependencies: CLOCKSEED, FFTAX, MYRAMP
%
%Written by Jeffrey Johnson, 6/5/2012
%Updated 12/4/2012 to include FM sweeps
%Updated 1/22/2020 to allow percentile cutoff of Gaussian noise


%% Do Argument Checking, Preliminaries

if nargin < 4
    error('There must be at least four input arguments!')
end

dur = dur/1000;  %convert to seconds

if lohz == 0  %0, -1 are the same for LoHz
    lohz = -1;
end
if hihz == 0 || hihz > 100000  %again, these values are out of range; over 100kHz is unexpected and hardcoded out
    hihz = -1;
end

if nargin < 5 || isempty(issweep)
    issweep = 0;
end

if nargin < 6 || isempty(amfreq)
    amfreq = 0;
end

if nargin < 7 || isempty(amdepth)
    amdepth = 0;
end

if nargin < 8 || isempty(amphase)
    amphase = 0;
end

if nargin < 9 || isempty(tonephase)
    tonephase = 0;
end

amphase = (amphase-90)*pi/180;  %this must be moved 90 degrees to correspond to phases listed above
tonephase = (tonephase)*pi/180;

if nargin < 10 || isempty(gauss)
    gauss = 1;
end

if gauss >= 100  %if alternate scaling is requested, but is set to 100 (full scaling) or greater than 100 (error) set to full scaling
    gauss = 1;
end

if nargin < 11 || isempty(ramp)
    ramp = 0;
end

if nargin < 12 || isempty(seed)
    seed = 0;
end

if nargin < 13 || isempty(pad)
    pad = nan;
end

fpp = 0;

if length(pad) == 1 && pad == 0
    pad = nan;
elseif length(pad) == 2
    fpp = pad(1);
    pad = pad(2);
elseif length(pad) > 2
    error('Value for PAD cannot have more than two values!')
end

no_calib = 0;  %by default, we return a calibration value
if nargin < 14 || isempty(calib)
    no_calib = 1;  %arbitrary - in all honesty, this function isn't meant to be called except by CED, so...
elseif ~isstruct(calib)
    no_calib = 1;
end


%set scale value for 16-bit output
scale_val = 32767;


%% Determine what type of stimulus we are going to create, which steps to use
do_tone = 0;
do_bb = 0;
do_am = 0;
do_bp = 0;
do_FM = 0;

%determine if stim/carrier is tone, BB noise, BP noise, FM
if lohz == hihz
    if lohz == -1  %lohz -1, hihz -1 is BB noise
        do_bb = 1;
    else  %lohz X, hihz X is tone at X Hz
        do_tone = 1;
        tonefreq = lohz;
    end
else  %if lohz ~= hihz, do BP noise or FM sweep, depending on issweep
    if issweep == 0
        do_bp = 1;
    else
        do_FM = 1;
    end
end

%determine if there is AM
if amfreq > 0 && amdepth > 0
    do_am = 1;
end



%% Set random seed, if we're not doing a tone/FM

if do_bp + do_bb > 0  %either BB or BP
    if seed == 0
        seed = clockseed(1);  %use "ultrafast" option of CLOCKSEED because we may reseed very soon
    else
        s = RandStream.create('mt19937ar','seed',seed);  %seed with system clock
        RandStream.setGlobalStream(s);  %and set this value to the default stream
    end
else
    seed = 0;  %if we are doing a tone/FM, get rid of any extraneous SEED input
end


%% Create stimulus/carrier, scale to 16 bits

num_samples = round(sampfreq*dur);  %total length of sound vector
if do_tone
    stimulus = sin(linspace(0,tonefreq*2*pi*dur,num_samples)+tonephase);
elseif do_FM
    stimulus = logsweep(lohz,hihz,dur,sampfreq);  %logarithmic sweep
elseif gauss == 1 %BP or BB, create noise
    stimulus = randn(1,num_samples);  %Gaussian-distributed noise
elseif gauss > 1 %BP or BB, create noise with percentile cutoff
    stimulus = randn(1,round(num_samples*100/gauss));  %Gaussian-distributed noise, create extra samples, will cut out extremes before scaling
    %stimulus = randn(1,num_samples);
else
    stimulus = rand(1,num_samples)-0.5;  %Uniform-distributed noise
end

%Scale stimulus to 16 bits before doing AM
%if gauss >= 2 && do_bb == 1 %if using alternate Gaussian scaling, scale broadband here
if gauss >= 2
    [~,inds] = sort(abs(stimulus));
    stimulus = stimulus(sort(inds(1:num_samples)));  %cut out extreme samples, return to original random order
    stimulus = stimulus / max(abs(stimulus));  
    stimulus = stimulus * scale_val;     
%elseif gauss >= 2 && do_bp == 1  %no scaling at all, we'll do that later
    %do nothing
else
    stimulus = stimulus / max(abs(stimulus));  
    stimulus = stimulus * scale_val;
end


%% Add AM envelope, if appropriate

if do_am
    propmod = amdepth/100.0;  %convert from percentage to proportion
    
    num_cyc = amfreq * dur;
    inc = (2 * pi * num_cyc)/num_samples;
    x = (amphase: inc: (2* pi * num_cyc) + amphase -inc);

    env = sin(x) / (max(sin(x)) - min(sin(x)));
    env = env + max(env); % scale sinusoid to 0-1
    env = propmod * env;
    env = env + (1 - propmod);
    stimulus = stimulus .* env;
end
    

%% Apply bandpass filtering, if appropriate



if do_bp
    [f ax] = fftax(stimulus,sampfreq);
    lolim = find(ax<lohz,1,'last');
    hilim = find(ax>hihz,1,'first');
    f(2:lolim) = 0;
    f(hilim:end) = 0;
    stimulus = real(ifft(f,'symmetric'));
    
    %Rescale BP stimulus to 16 bits
    if gauss >= 2 %if using alternate Gaussian scaling, scale bandpass here NO THIS IS AWFUL IT JUST CRACKLES LIKE MAD
%         [~,inds] = sort(abs(stimulus));
%         stimulus = stimulus(sort(inds(1:num_samples)));  %cut out extreme samples, return to original random order
%         stimulus = stimulus / max(abs(stimulus));
%         stimulus = stimulus * scale_val;

%         srt = sort(abs(stimulus));
%         stimulus = stimulus / srt(length(srt)-100);
%         stimulus(stimulus>1) = 1;
%         stimulus(stimulus<-1) = -1;
%         stimulus = stimulus * scale_val;
    else
%         stimulus = stimulus / max(abs(stimulus));
%         stimulus = stimulus * scale_val;
    end
    stimulus = stimulus / max(abs(stimulus));
    stimulus = stimulus * scale_val;
end

%% Apply ramp, if appropriate

if ramp
    stimulus = myramp(stimulus,sampfreq,ramp);
end



%% Compute approximate attenuation to bring to 65 dB

%Yeah, I've really got no idea how this one is going to work.
%One guess would be to filter the thing with a STF (and A-Weighting, if
%used) and then do short-term RMS (maybe 200 ms or so) to find a peak?
%
%Well, calc_spl_wfm is probably a decent start point
%
%Filtering with the STF could presumably be done with the "filt_stim"
%subfunction found in "run_IC_simulation_final", but I think that may turn
%out to be pretty slow.  Another method (which appears to be kosher and
%maybe even more kosher) is to build a digital IIR (Infinite Impulse
%Response) filter from the STF.  This actually is relatively easy and the
%result could be stored in a .mat file for quick access.  The steps are
%below:
%
%Assume your STF is in structure x.Ch1, which will have fields "interval",
%"length", and "values" at the least.
%
%f = 0:x.Ch1.interval:x.Ch1.interval*x.Ch1.length;  %frequency vector, Hz
%f = f/max(f);  %scale frequency vector to 0-1 for YULEWALK
%m = [0; x.Ch1.values]';  %magnitude (row) vector, set DC component to 0
%[b a] = yulewalk(50,f,m);  %this creates a 50-pole filter, which may be
%                           %overkill, but then again there is a lot of
%                           %structure to a STF.  I tried 100-pole but no
%                           %dice, too big.
% %The next two lines allow you to check the filter result against the STF
% %[h,w] = freqz(b,a,128);
% %figure, plot(f,m,w/pi,abs(h),'--')
%
% %At this point, the B and A components to the filter could be saved and
% %the final filter step done once the stimulus is created:
%
%out = filter(b,a,in);  %this does the actual filtering

%Use SPKLIST (should be 15, 16, 31...) to determine which pre-created file
%of B,A to load and SPK to select a speaker.  Format not yet determined,
%but ought to be easy enough.  B and A are arrays, but I'm sure some
%reasonable 3-D array or something could be arranged.
%
%The best (or at least current!) method is to gather all the data in a
%structure, and to pass a subsection of that structure corresponding to the
%speaker in use to Reclab_Panstim.  I'll set this up to be able to use
%either the "standard" filtering or the "FFT-space" filtering without
%actually having to be told which is which.

if no_calib == 0 
    %determine which method is being used
    if isfield(calib,'a')  %if standard filtering, this is not a good method and is likely to be removed eventually
        B = calib.b;
        A = calib.a;
        
        %In principle, we know we need about 30 dB of attenuation to get
        %the stimuli into a reasonable range.  Don't know if that's 60 dB
        %or 70 dB or what, but it's not blast-off values.  Standard
        %filtering (A weight) is giving values in the -30 range, so we'll 
        %adjust that here.
        atten_baseline = 60;  %use this if a-weighted
        %atten_baseline = 80;  %use this if open
    
        %sampling frequency of original STF for filtering is 100 kHz, this
        %means that the stimulus has to be at 100 kHz or no dice.
        if sampfreq == 100000     
            stimulus_STF = filter(B,A,stimulus);  %this does the actual filtering
        else  %make identical stimulus at 100 kHz, won't work so hot for noise
            stimulus2 = reclab_panstim(dur*1000,100000,lohz,hihz,issweep,amfreq,amdepth,(amphase*180/pi)+90,tonephase*180/pi,gauss,ramp,seed,pad,[]);
            stimulus_STF = filter(B,A,stimulus2);  %filter the 100 kHz stimulus
        end
        spl_guess = calc_spl_wfm(stimulus_STF,80,sampfreq,400,0,1);  %80 dB base is arbitrary, more study needed
        
        atten65 = spl_guess-65+atten_baseline; 
    elseif isfield(calib,'stf')  %if FFT-based filtering
        stf = calib.stf;
        xax = calib.xax;
        
        %In principle, we know we need about 30 dB of attenuation to get
        %the stimuli into a reasonable range.  Don't know if that's 60 dB
        %or 70 dB or what, but it's not blast-off values.  FFT
        %filtering (A weight) is giving values in the 95 range, so we'll 
        %adjust that here.
        %atten_baseline = 0;  %no longer necessary
        
        %We are having memory issues, and I think this is the problematic
        %line.  If the stimulus is too long, only use a subset of the
        %stimulus, since in these cases (100 sec noise) the statistics are
        %plenty stationary
        
        if length(stimulus) <= 1000000  %10 seconds at 100kHz seems fine
            stimulus_STF = filt_stim(stimulus,sampfreq,stf,xax);   %this does the actual filtering
            %figure, hold on, plot(xax,stf)
            spl_guess = calc_spl_wfm(stimulus_STF,calib.dB,sampfreq,400,0,1);  %calib.dB is directly calculated
        else
            stimulus_STF = filt_stim(stimulus(1:1000000),sampfreq,stf,xax);   %this does the actual filtering
            %figure, hold on, plot(xax,stf)
            spl_guess = calc_spl_wfm(stimulus_STF,calib.dB,sampfreq,400,0,1);  %calib.dB is directly calculated
        end
            
        
        %atten65 = spl_guess-65+atten_baseline;  %no longer necessary
        atten65 = spl_guess-65;
    else
        atten65 = 0;  %in case of error, though one might want to let the user know... 
    end
    
else  %if we haven't been pointed to calibration values, don't calibrate
    atten65 = 0;
end


%% Pad out stimulus, if appropriate

%don't add any pad until after we've estimated the SPL, if appropriate
if ~isnan(pad)     
    if fpp+length(stimulus) > pad
        error('Front pad plus stimulus exceeds requested length!')
    end
    temp = zeros(1,pad);
    temp(fpp+1:fpp+length(stimulus)) = stimulus;  %Put on front-end padding, if requested
    stimulus = temp;
end


%% Columnize outputs

%stimulus is a row vector, must be a column vector for CED to cope
stimulus = stimulus';



%And done!


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








%We also want the LOGSWEEP subfunction, so we don't have to carry a
%separate file around...

%% subfunction logsweep
function out = logsweep(startfreq,endfreq,duration,samplingfreq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOGSWEEP - creates a logarithmic frequency sweep (of constant amplitude 1).  The sweep begins in
%            cosine phase.
% 
% Usage:  OUT = LOGSWEEP(STARTFREQ,ENDFREQ,DURATION,SAMPLINGFREQ)
%
% Inputs:   STARTFREQ    - the starting frequency
%           ENDFREQ      - the ending frequency
%           DURATION     - the duration, in seconds, default = 1
%           SAMPLINGFREQ - the sampling frequency, default = 44100
%
% Outputs:  OUT   - The output sound
%           INSTF - The instantaneous frequency of the output sound
%           INSTP - The instantaneous phase of the output sound
%
% Written by Jeffrey Johnson 5-17-06 in a fit of true self-loathing but ultimately resulting in
% triumph
%
% Note that the version copied below does not return INSTF or INSTP because they are not useful.
% The commented-out code to create these outputs is left in place, in case it is ever wanted.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check input arguments
if nargin < 2
    error('You must specify the starting and ending frequencies!');
end
if nargin < 3
    duration = 1;
end
if nargin < 4
    samplingfreq = 44100;
end

%prepare variables
a = log10(startfreq);
b = log10(endfreq);
s = samplingfreq;
c = round(duration*s);  %sometimes this turns out to be just incrementally non-integer for some reason, so round it
t = linspace(1/s,duration,c);  %time vector


%create signal
out = cos(2*pi*1/s/(b-a)/log(10)*10.^(a+(t*s-1)*(b-a)/(c-1))*c-1/s/(b-a)/log(10)*10.^(a+(t*s-1)*(b-a)/(c-1)));


% %Note: the signal is cos(2*pi*phase(t)), where phase(t) = the integral of f(t)dt, where f(t) is the
% %instantaneous frequency at times t, which is a time vector in seconds.
% %
% %The math is nasty, but here it is, since you (or I) won't be able to recapitulate it easily:
% %
% %The logarithmically spaced frequency list is obtained as follows:
% %f(t) = 10^(a+((t*s)-1)*(b-a)/(c-1))
% %
% %This is a modification of the meat of the function LOGSPACE, changed so that T is a true time vector in
% %seconds (for the integration) and T*S is a vector of integers 1:DURATION, which is what LOGSPACE requires
% %
% %Integration of this is nasty, so use Matlab's symbolic functions:
% %myfunc = sym('f(t) = 10^(a+((t*s)-1)*(b-a)/(c-1))');
% %int(myfunc)
% %
% %The result (phase(t)) is the following:
% %1/s/(b-a)/log(10)*10^(a+(t*s-1)*(b-a)/(c-1))*c-1/s/(b-a)/log(10)*10^(a+(t*s-1)*(b-a)/(c-1))
% %
% %Whatever. I won't pretend to break that down, I just stuck it in to the standard cosine creation function:
% %OUT = COS(2*PI*(PHASE(T))) as above.  And it worked (eventually).
%
%instf = 10.^(a+((t.*s)-1).*(b-a)./(c-1));
%instp = 1./s./(b-a)./log(10).*10.^(a+(t.*s-1).*(b-a)./(c-1)).*c-1./s./(b-a)./log(10).*10.^(a+(t.*s-1).*(b-a)./(c-1));








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

   
   
   
   
 %% subfunction db2ratio 
   
   function out = db2ratio(in,power)
%DB2RATIO - A super simple function that converts a dB value to a ratio
%
%Usage OUT = DB2RATIO(IN,POWER), where IN is a dB value and OUT is a ratio
%    If POWER is non-zero, will compute ratio in power, otherwise will compute
%    ratio in amplitude (default = amplitude)
%
%Also see: ratio2db

if nargin < 2 || isempty(power)
    power = 0;
end

if power  %do power version
    out = 10.^(in./10);
else  %do amplitude version
    out = 10.^(in./20);
end
   
   
   
 %% subfunction mag_phase2sin_cos  
   
   function out = mag_phase2sin_cos(mag,phs)

%MAG_PHASE2SIN_COS is a super-simple function that converts a magnitude/phase pair
%to the sine/cosine complex value as output by Matlab's FFT and expected by IFFT.
%
%Usage: OUT = MAG_PHASE2SIN_COS(MAG,PHS)
%
%Inputs:  MAG - The magnitude values (see M below, in M-file)
%         PHS - The phase values (see THETA below, in M-file)
%Outputs: OUT - The sine/cosine complex value (see Z below, in M-file)
%
%I do this because I can never remember this conversion and I don't want to look it up every
%time.

%The remedial math (for remedial mathematicians like myself):
%Take a vector X in the time domain
%Let Z be the Fourier Transform of X,       Z = FFT(X);
%Z will be a complex vector the same length as X.  The first value in Z will be the DC
%component (real), and subsequent values (complex) will correspond to 1 cycle/vector, 
%2 cycles/vector, etc. up to the Nyquist frequency (N/2 cycles/vector).  Beyond the 
%Nyquist frequency, values are reflected (if the Nyquist actually exists - vector is of
%even length - the Nyquist is not reflected; if the Nyquist does not exist - vector is of
%odd length - the final value is reflected).  Reflected values are usually disposed of.
%The complex values have (as all complex values do) a real and an imaginary component.
%The real component   REAL(Z)   is the magnitude of the sine wave at the corresponding
%frequency and the imaginary component   IMAG(Z)  is the same, but for the cosine wave.
%However, the REAL and IMAG components (the sine/cosine pair) are not usually terribly 
%useful.  Rather, it is usually preferable to convert things into terms of a single 
%sinusoidal wave which has magnitude M and initial phase THETA (where the initial phase
%of a sine wave is 0 and the initial phase of a cosine wave is pi/2).  This is done by:
%M = ABS(Z);   %The magnitude of the sinusoid
%THETA = ANGLE(Z);  %The phase of the sinusoid
%This magnitude/phase pair form a frequency-based representation ("frequency space") of
%the original vector, and the magnitudes are often useful in transforming a stimulus
%(e.g. a speaker transfer function or a head-related transfer function).  However, if we
%wish to reconstruct a transformed version of our vector, we have to convert the 
%magnitude/phase pair into a complex sine/cosine pair Z2 for use by IFFT.  This is the step
%with the difficult-to-remember math.  The formula is:   Z2 = M2.*(exp(1i*THETA));
%Then, the transformed vector in the time domain can be found by:   X2 = IFFT(Z2,'symmetric');
%where the 'symmetric' argument tells IFFT to treat the input Z2 as symmetric even if there
%are round-off errors.  I have found that occasionally even explicitly reflected vectors
%have strange, small round-off errors which result in the result of IFFT being complex (with
%very small values in the imaginary domain).  The 'symmetric' option avoids this problem.
%So, in summary:
%1) Z = FFT(X);  %The sine/cosine complex pair
%2) M = ABS(Z);  %Extract the magnitude component
%3) THETA = ANGLE(Z);  %Extract and store the phase component
%4) M2 = (Operations with M)  %Alter M, restore DC component and reflected portion if necessary
%5) Z2 = M2.*(exp(1i*THETA));  %Convert magnitude/phase pair to complex sine/cosine pair
%6) X2 = IFFT(Z2,'symmetric');  %Return modified X in time domain
%This function does only step 5).  It's just that step 5) is the hard one to remember.

out = mag.*(exp(1i*phs));  %There you go, one functional line and 49 lines of comments.  So it goes.