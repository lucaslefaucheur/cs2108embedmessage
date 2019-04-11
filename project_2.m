close all
clear

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

% output encoded audio signal
writePath = 'edelweiss_with_message.mp4';
audiowrite(writePath, y_encoded, Fs);

% read from audio file
readPath = writePath;
[y, Fs] = audioread(readPath);

%{
% listen from recording
Fs = 44100;
music = audiorecorder(Fs, 16, 1);

% callbacks
music.StartFcn = 'disp("Start speaking.")';
music.StopFcn = 'disp("End of recording.")';

recordblocking(music, 36+2);
y = getaudiodata(music);
audiowrite('record.mp4', y, Fs);
%}

decode(y, Fs, freq_scale, sig_len)

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

function msg = decode(y, sampFreq, freqScale, sigLen)
    
    msg = '';
    len = sampFreq*sigLen; % number of sample points for one character
    freq = freqScale*sigLen; % for retrieving real frequency
    
    for i = 1 : length(y)/len
        
        y_seg = y((i-1)*len + 1 : i*len);
        Y = abs(fft(y_seg)); % magnitude of fft result
        Y = Y(1 : len/2 + 1); % keep positive frequency
        X = (sampFreq/len) * (0 : len/2);
        
        % be very careful when running this command!!!
        % otherwise your memory will explode!!!
        % figure, plot(X, Y) 

        [pks, locs] = findpeaks(Y);
        [pks, idx] = sort(pks, 'descend'); % sort peaks
        
        for j = 1 : length(pks)
            % capture first character with highest magnitude after white space
            if locs(idx(j)) >= 32*freq 
                % pks(j), locs(idx(j))
                msg = [ msg, char(round(locs(idx(j))/freq)) ];
                break
            end
        end
        
    end
    
    Y = abs(fft(y));
    Y = Y(1 : length(Y)/2 + 1); 
    X = (0 : length(Y)-1) * (sampFreq/(length(Y)*2));
    figure, plot(X, Y)

end
