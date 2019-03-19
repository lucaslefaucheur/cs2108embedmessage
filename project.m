close all
clear all

% read audio file
filename = 'Edelweiss.mp3';
[y, Fs] = audioread(filename);
y = y(1 : Fs*36);

step = 1/Fs;
% random signal 1
t = (0:step:1-step);
sig = [sin(2*pi*5000*t) zeros(1,length(y)-length(t))];
% random signal 2
t1 = (1-step:step:2-step);
sig1 = [zeros(1,length(t1)) sin(2*pi*6000*t1) zeros(1,length(y)-length(t1)*2)];

% add to original audio
y = encode(y,Fs,'abcde');

% write to audio file
audiowrite('edelweiss_36seconds.mp4', y, Fs)
[y, Fs] = audioread('edelweiss_36seconds.mp4');

y1 = y(1 : Fs*36);

% fft result
figure
L = Fs*36;
Y = fft(y1);
f = Fs*(0:(L/2))/L;
P2 = abs(Y);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f, P1)

[sortpks, sortlocs] = findpeaks(P1(4500:end));
for i = 1:length(sortpks)
   if sortpks(i) > 40000 
       %sortpks(i) 
       char(round(sortlocs(i)/3554))
   end
end

function y_encoded = encode(y,Fs,message)
    step = 1/Fs;
    y_encoded = y;
    message = double(message);
    
    for i=1:length(message)
        t = ((i-1)-step:step:i-step);
        sig = [zeros(1,(i-1)*length(t)) sin(2*pi*100*message(i)*t) zeros(1,length(y)-length(t)*i)];
        y_encoded = y_encoded + sig;
    end
end


