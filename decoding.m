close all
clear
warning('off', 'MATLAB:colon:nonIntegerIndex')

load param.mat

%{

% reading test
readPath = 'edelweiss_with_message.mp4';
[y, Fs] = audioread(readPath);

%}
%{x

% listening test
Fs = 44100;
music = audiorecorder(Fs, 16, 1);

% callbacks
music.StartFcn = 'disp("Start speaking.")';
music.StopFcn = 'disp("End of recording.")';

recordblocking(music, 6+2);
y = getaudiodata(music);
audiowrite('record.mp4', y, Fs);

%}

decode(y, Fs, freq_scale, sig_len)

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
            % return frequency with highest peak within encoding bandwidth
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