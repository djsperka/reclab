function gah

Wav = zeros(1,100000);
duration = 1;
TF = 100;
inc = (duration*2*pi*TF)/(length(Wav)-1);
for i = 2:length(Wav)
    Wav(i) = Wav(i-1)+inc;
end
Wav = cos(Wav);


figure, plot(Wav)

% TF += ToneFreq;  'increment TF by the value in ToneFreq; TF initializes to zero so we start at ToneFreq
%             inc := (duration*2*pi*TF)/(len(Wav[])-1);
%             arrconst(Wav[],0);
%             for i% := 1 to len(Wav[])-1 do
%                 Wav[i%] := Wav[i%-1] + inc;
%             next;
%             cos(Wav[]); 