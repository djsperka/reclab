function [result xax] = fftax(data,fs,noreflect)

%FFTAX - a function that will do an FFT on DATA *AND* return the appropriate X-axis, in Hz
%
%Usage: [RESULT XAXIS] = FFTAX(DATA,FS)
%
%Inputs: DATA - The data to do the FFT on
%        FS   - The sampling frequency, in Hz
%        NOREFLECT - If 1, will automatically remove the reflected portion of the FFT
%                    Default = 0
%
%Outputs: RESULT - The FFT of the data
%         XAXIS  - The values of the X-axis of the data
%
%Written by Jeffrey Johnson 8-11-09, just 'cause
%Updated to allow FFT of matrices 4-12-10, because it was easy and needed

argcheck('noreflect',0)
argcheck('fs')
argcheck('data')


%this is the easy part
result = fft(data);  %takes FFT of columns, if matrix

%get number of time points for either case
if ~isvector(data)
    mylen = size(data,1);
else
    mylen = length(data);
end

%now the part I hate to do every time
sigdur = mylen/fs;  %duration of signal in seconds
freqs = (0:mylen)/sigdur;  %frequency of components, includes DC component
fftl = floor(mylen/2)+1;  %proper length of non-reflected FFT data, including DC
xax = freqs(1:fftl);  %get x-axis

%cut data, if requested
if noreflect
    if ~isvector(data)
        result = result(1:fftl,:);
    else
        result = result(1:fftl);
    end
end

