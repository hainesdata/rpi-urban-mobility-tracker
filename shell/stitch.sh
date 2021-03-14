ffmpeg -f image2 -i output/frame_%01d.jpg -vcodec h264 -filter:v "setpts=PTS/2" -y analyzed-frames.mp4
