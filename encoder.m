[y,Fs] = audioread('Edelweiss.mp3');

samples = [1,36*Fs];
[y1, Fs] = audioread('Edelweiss.mp3',samples);

audiowrite('edelweiss_36seconds.mp4',y1,Fs);
