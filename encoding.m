close all
clear all
warning('off', 'MATLAB:colon:nonIntegerIndex')

% read initial data
sourcePath = 'Edelweiss.mp3';
[y, Fs] = audioread(sourcePath);

% clip to _ seconds
time = 36;
y = y(1 : Fs*time);
timestr = num2str(time);
clipPath = strcat('edelweiss_', timestr, 'seconds.mp4');
audiowrite(clipPath, y, Fs)

% param
amp_scale = 0.01;
freq_scale = 110;

% embed message
message = 'Today is a bright sunny day. It is the D day. Everyone is excited. We want to demonstrate our course project in our CS2108 Intro to Media Computing.';
sig_len = time/length(message); % second(s)
y_encoded = encode(y, Fs, message, amp_scale, freq_scale, sig_len);
save param.mat freq_scale sig_len % export variables

% output encoded audio signal
writePath = 'edelweiss_with_message.mp4';
audiowrite(writePath, y_encoded, Fs);

function sig = encode(y, sampFreq, embedMsg, ampScale, freqScale, sigLen)
    
    step = 1/sampFreq;
    msg = double(embedMsg);
    t = 0 : step : sigLen-step;
    len = length(t); % sampFreq*sigLen
    sig = y;
    
    % apply low pass filter
    win = fir1(32, 0.1);
    fwin = fftshift(fft(win, length(sig)));
    fsig = fftshift(fft(sig));
    csig = fsig .* fwin;
    sig = ifft(fftshift(csig));
    
    left = -length(y)/2;
    right = length(y)/2-1;
    
    % plot for visualization
    figure
    subplot(3,1,1), plot([left:right], log(abs(fsig)));
    subplot(3,1,2), plot([left:right], log(abs(fwin)));
    subplot(3,1,3), plot([left:right], log(abs(csig)));
    
    for i = 1 : length(msg)
        f = freqScale*msg(i);
        s = sig((i-1)*len + 1 : i*len);
        sig((i-1)*len + 1 : i*len) = s + ampScale*sin(2*pi*f*t);
    end
    
    % plot for visualization
    Y = abs(fft(sig));
    Y = Y(1 : length(Y)/2 + 1); 
    X = (0 : length(Y)-1) * (sampFreq/(length(Y)*2));
    figure, plot(X, Y)
    
end

