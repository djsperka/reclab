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
mydir = 'C:\Data\Calib\test_in_place\';  %directory for Recanzone lab, make this different than the write directory

%write16File = 'E:\Core Grant\reclab\Calib4_newamp\Array16.mat';  %filename for writing, Kershaw
%write15File = 'E:\Core Grant\reclab\Calib4_newamp\Array15.mat';

writeFile = 'C:\Data\Calib\Array16.mat';  %filename for writing, Recanzone lab
%writeFile = 'C:\Data\Calib\Array15.mat';  %do this separately, from a different directory

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
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.01,0.1,1,60);
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

        outdB2=filtfilt(des.Numerator,1,outdB); %zero-phase filter the STF
        
        %this allows us to look at the filtering result against the
        %original STF
        %figure, plot(outax,outdB,'b'), hold on, plot(outax,outdB2,'r')
        %title(['speaker ' num2str(speaker) ', Aweight = ' num2str(isAweight)]);
        
        %and put the stuff in a structure
        if isAweight
            AFFT(speaker).stf = outdB2;
            AFFT(speaker).xax = outax;
            AFFT(speaker).dB = dB;
            numSpeakersProcessed = numSpeakersProcessed + 1;  %keep count of the number of figures processed
        end        
    end
    

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
outdB = 20*log10(hrir./max(hrir));  %amplitude version THIS, THIS, SO MUCH THIS
%outdB = 10*log10(hrir./max(hrir));  %power version, I think this is right NO
