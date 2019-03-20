close all

filename = 'Edelweiss.mp3';
[y, Fs] = audioread(filename);
y = y(1 : Fs*36);

message = '12345678901234567890123456789012345';

encode(y,Fs,message, 0.005, 150);
decode(length(message), 0.005, 150);

function encode(y,Fs,message, a, f)
    step = 1/Fs;
    y_encoded = y;
    message = double(message);
    
    for i=1:length(message)
        t = ((i-1)-step:step:i-step);
        sig = [zeros(1,(i-1)*length(t)) a*sin(2*pi*f*message(i)*t) zeros(1,length(y)-length(t)*i)];
        y_encoded = y_encoded + sig;
    end
    
    audiowrite('edelweiss_36seconds.mp4',y_encoded,Fs);
end

function decode(n, a, f)
    [y, Fs] = audioread('edelweiss_36seconds.mp4');
    message = '';
    
    for i=1:n
        y_decode = y((i-1)*Fs+1 : Fs*i);
        L = Fs*1;
        Y = fft(y_decode);
        fx = Fs*(0:(L/2))/L;
        P2 = abs(Y);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        
        %figure, plot(fx, P1)

        [pks, locs] = findpeaks(P1);
        for j = 1:length(pks)
            if pks(j) > 40000*a && locs(j) > 32*f
                %locs(j)
                message = strcat(message, char(round(locs(j)/f)));
                char(round(locs(j)/f))
            end
        end
    end
    
    message %it doesn't include the spaces idk why
end