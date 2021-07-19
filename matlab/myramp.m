function out = myramp(in,sample_rate,ramp_dur,is_cos)

%a quick cosine-squared ramp
%OUT = MYRAMP(IN,SAMPLE_RATE,RAMP_DUR)
%IN is the signal
%SAMPLE_RATE defaults to 44100
%RAMP_DUR is in milliseconds, defaults to 10
%IS_COS - if 1, do cosine ramp instead of cosine-squared ramp, default = 0

if nargin < 2
    sample_rate = 44100;
end

if nargin < 3
    ramp_dur = 10;  %in ms
end

if nargin < 4 || isempty(is_cos)
    is_cos = 0;
end


ramp_samp = ceil(sample_rate*ramp_dur/1000);  %number of samples in ramp
ramp = cos(linspace(0,pi/2,ramp_samp));
if is_cos == 0
    ramp = 1-ramp.^2;
else
    ramp = 1-ramp;
end

%check size of input
if min(size(in)) > 1 || length(size(in)) > 2  %if it's not a vector
    error('MYRAMP is currently only designed to work on vectors!')
end

if length(in) < 2*length(ramp)  %if the input vector is not twice the length of the ramp
    error('The requested ramp is too long!')
end

out = in;

if size(in,1) > size(in,2) %if it's a column vector, RAMP must be switched
    out(1:length(ramp)) = out(1:length(ramp)).*ramp';   %ramp beginning of tone
    out(end-length(ramp)+1:end) = out(end-length(ramp)+1:end).*fliplr(ramp)';  %ramp end of tone
else
    out(1:length(ramp)) = out(1:length(ramp)).*ramp;   %ramp beginning of tone
    out(end-length(ramp)+1:end) = out(end-length(ramp)+1:end).*fliplr(ramp);  %ramp end of tone
end