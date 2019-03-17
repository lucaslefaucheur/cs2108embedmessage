close all
clear all
cd 'C:\Users\hccha\Documents\Introduction to Media Computing'

% read audio file
filename = 'Edelweiss.mp3';
[y, Fs] = audioread(filename);
y = y(1 : Fs*36);
%sound(y,Fs);

% get peaks of the signal
[pks,locs] = findpeaks(abs(y), 0:length(y)-1);
[sortpks, index] = sort(pks, 'descend');

step = 1/Fs;
% random signal 1
t = [0:step:1-step];
sig = [sin(2*pi*5000*t) zeros(1,length(y)-length(t))];
% random signal 2
t1 = [0:step:2-step];
sig1 = [sin(2*pi*6000*t1) zeros(1,length(y)-length(t1))];

% add to original audio
y = y+sig+sig1;

% write to audio file
audiowrite('edelweiss_36seconds.mp4', y, Fs)
[y, Fs] = audioread('edelweiss_36seconds.mp4');

% fft result
figure
L = Fs*36;
Y = fft(y);
f = Fs*(0:(L/2))/L;
P2 = abs(Y);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f, P1)

[sortpks, sortlocs] = findpeaks(P1(4500:end));
for i = 1:length(sortpks)
   if sortpks(i) > 20000
       sortpks(i) 
       sortlocs(i) / 35.1
   end
end

% 6228
function [sortpks, sortlocs] = detect(Y)
[pks,locs] = findpeaks(Y);
[sortpks, index] = sort(pks, 'descend');
sortlocs = locs(index)';
end
