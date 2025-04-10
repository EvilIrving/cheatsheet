将 temp 文件夹下的 15 个视频合并在一起，并且在合并后对最终合成的视频进行压缩

### 完整流程

将上述步骤整合起来，完整的流程如下：

1. 创建文件列表：

ls temp/*.mp4 | sed "s/^/file '/;s/$/'/" > filelist.txt

or

find temp -name "*.mp4" -exec echo "file '{}'" \; > filelist.txt
   2. 合并视频：

ffmpeg -f concat -safe 0 -i filelist.txt -c copy merged_video.mp4
   3. 压缩视频：

ffmpeg -i merged_video.mp4 -vcodec libx264 -crf 23 -preset medium compressed_video.mp4

---

### 注意事项

2. **视频格式一致性**：如果视频的编码格式、分辨率等不一致，可能会导致合并失败。在这种情况下，可以在合并前统一转码：

ffmpeg -i input.mp4 -vf "scale=1280:720" -c:v libx264 -crf 23 -preset medium output.mp4
