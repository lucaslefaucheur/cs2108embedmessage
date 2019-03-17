[y,Fs] = audioread('Edelweiss.mp3');

samples = [1,36*Fs];
[y1, Fs] = audioread('Edelweiss.mp3',samples);

audiowrite('edelweiss_36seconds.mp4',y1,Fs);


message = "Today is a bright sunny day. It is the D day. Everyone is excited. We want to demonstrate our course project in our CS2108 Introduction to Media Computing.";

 images    = cell(3,1);
 images{1} = imread('frame-1.png');
 images{2} = imread('frame-2.png');
 images{3} = imread('frame-3.png');

 writerObj = VideoWriter('myVideo','MPEG-4');
 writerObj.FrameRate = 1;

 secsPerImage = [1 1 1];

 open(writerObj);

 for u=1:length(images)
     frame = im2frame(images{u});
     for v=1:secsPerImage(u) 
         writeVideo(writerObj, frame);
     end
 end

 close(writerObj);
