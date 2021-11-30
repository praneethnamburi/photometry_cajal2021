render_video(mDb, 'F0002');
render_video(mDb, 'F1728');
render_video(mDb, 'M1698');
render_video(mDb, 'F0004');
render_video(mDb, 'F1727');
render_video(mDb, 'M0001');
render_video(mDb, 'M0003');

function [] = render_video(mDb, mID)
m = mDb(strcmp({mDb.MouseID}, mID));
time_window = 60; % s
frame_delta = 1; % s
photodata_sr = 30;

GCaMP_color = [0.4660, 0.6740, 0.1880];
jRGECO_color = [0.6350, 0.0780, 0.1840];

BLA_color = [0, 0.4470, 0.7410];
CeM_color = [0.6350, 0.0780, 0.1840]; %[0.8500, 0.3250, 0.0980];

track_line_color = [0.9290, 0.6940, 0.1250];
centroid_color = [0.3010, 0.7450, 0.9330];

n_timepts_half = floor(photodata_sr*time_window/2);
n_timepts_track = floor(photodata_sr*10); % 10 seconds
tk = m.EPM.track;

% figure('Units','normalized','OuterPosition',[0, 0, 0.5, 1]);
% scatter(m.EPM.aIC_BLA, m.EPM.aIC_CeM);

h = figure('Units','normalized','OuterPosition',[0, 0, 1, 1]);

subplot(2, 2, [1, 3]);
v = VideoReader([m.fdir_EPM, m.fprefix_EPM, 'behaviour_cam.mp4']);
im = rgb2gray(read(v, 1));
hIm = imagesc(cat(3, im, im, im));
axis equal;
axis off;
hold all;
hPath = plot(rand(n_timepts_half, 1)*100, rand(n_timepts_half, 1)*100, LineWidth=2, Color=track_line_color);
hCentroid = scatter(500, 500, 100, centroid_color, 'filled');

if strcmp(m.GCaMP6s, 'aIC_BLA')
    yl_prefix = 'GCaMP6s';
else
    yl_prefix = 'jRGECO1a';
end
axBLA = subplot(2, 2, 2);
hBLA_ref = plot([0, 0], [0, 0], 'k', LineWidth=2);
hold all;
% hBLA = plot(m.EPM.t, m.EPM.aIC_BLA, LineWidth=1.5, color=BLA_color);
hBLA = plot(m.EPM.t, smooth(m.EPM.aIC_BLA, 10), LineWidth=1.5, color=BLA_color);
yl_BLA = get(axBLA, 'YLim');
hBLA_ref.YData = yl_BLA;
ylabel([yl_prefix '  Fluorescence (a.u.)']);
title('aIC-BLA');

if strcmp(m.GCaMP6s, 'aIC_CeM')
    yl_prefix = 'GCaMP6s';
else
    yl_prefix = 'jRGECO1a';
end
axCeM = subplot(2, 2, 4);
hCeM_ref = plot([0, 0], [0, 0], 'k', LineWidth=2);
hold all;
% hCeM = plot(m.EPM.t, m.EPM.aIC_CeM, LineWidth=1.5, color=CeM_color);
hCeM = plot(m.EPM.t, smooth(m.EPM.aIC_CeM, 10), LineWidth=1.5, color=CeM_color);
xlabel('Time (s)');
yl_CeM = get(axCeM, 'YLim');
hCeM_ref.YData = yl_CeM;
ylabel([yl_prefix '  Fluorescence (a.u.)']);
title('aIC-CeM');

linkaxes([axBLA, axCeM], 'x');
xlim([300 400]);
sgtitle(mID);


all_frames = round((m.EPM.t+time_window/2)*photodata_sr):frame_delta:length(m.EPM.t);
t_start = m.EPM.t(1);
video_frame_offset = round(t_start*photodata_sr);
sav_dir = 'C:\Users\Praneeth\Desktop\Cajal2021\screenshots\';
sav_vid = VideoWriter([sav_dir, mID]);
sav_vid.FrameRate = 30;
open(sav_vid);
for frameCount = 1:length(all_frames)
    frameNumber = all_frames(frameCount);
%     sav_name = [mID, '\', mID, '_f', num2str(frameNumber, '%03d'), '_', num2str(frameCount, '%03d')];
    
%     if ~exist(sav_name, 'file')
        im = rgb2gray(read(v, frameNumber + video_frame_offset));
        hIm.CData = cat(3, im, im, im);
        this_t = m.EPM.t(frameNumber);
        xlim(axCeM, time_window*[-0.5, 0.5] + this_t);
        hBLA_ref.XData = this_t*[1, 1];
        hCeM_ref.XData = this_t*[1, 1];
        hCentroid.XData = tk.mouseX(frameNumber);
        hCentroid.YData = tk.mouseY(frameNumber);
        hPath.XData = tk.mouseX(frameNumber+ (0:-1:-n_timepts_track));
        hPath.YData = tk.mouseY(frameNumber+ (0:-1:-n_timepts_track));
        writeVideo(sav_vid, getframe(h));
%         drawnow;
%         export_fig(sav_name);
%     end
end
close(sav_vid);
close(h);
end