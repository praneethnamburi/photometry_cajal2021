fname_metadata = 'C:\dev\photometry_cajal2021\Mouse_assignments.csv';
mDb = table2struct(readtable(fname_metadata));
% m = mDb(strcmp({mDb.MouseID}, 'M1698'));

for mCount = 1:height(mDb)
    mDb(mCount).EPM = struct;
    [photodata, mDb(mCount).EPM.t, mDb(mCount).EPM.ref_img, mDb(mCount).EPM.track] = process_EPM(mDb(mCount));
    mDb(mCount).EPM.aIC_BLA = photodata.aIC_BLA;
    mDb(mCount).EPM.aIC_CeM = photodata.aIC_CeM;
end

mDb = epm_roi_analysis(mDb);


%----------------------------------------------
function [mDb] = epm_roi_analysis(mDb)
h = figure;
color_list = get(gca, 'ColorOrder');
close(h);
roi = struct;
roi.open_arm_top = struct('pos', [487, 270, 70, 345], 'color', color_list(1, :), 'index', 1);
roi.open_arm_bottom = struct('pos', [487, 665, 70, 355], 'color', color_list(2, :), 'index', 2);
roi.closed_arm_left = struct('pos', [128, 615, 372, 50], 'color', color_list(3, :), 'index', 3);
roi.closed_arm_right = struct('pos', [550, 615, 372, 50], 'color', color_list(4, :), 'index', 4);
roi.center = struct('pos', [497, 615, 50, 50], 'color', color_list(5, :), 'index', 5);

roi_names = fieldnames(roi);
for roiCount = 1:length(roi_names)
    this_roi_name = roi_names{roiCount};
    this_roi = roi.(this_roi_name);
    rectangle(Position=this_roi.pos, EdgeColor=this_roi.color, LineWidth=3);
    tmp1 = num2cell(this_roi.pos);
    [x, y, w, h] = tmp1{:};
    for mCount = 1:length(mDb)
        mDb(mCount).EPM.roi(roiCount).pos = this_roi.pos;
        mDb(mCount).EPM.roi(roiCount).color = this_roi.color;
        mDb(mCount).EPM.roi(roiCount).name = this_roi_name;
        tk = mDb(mCount).EPM.track;
        reg_bool = tk.mouseX > x & tk.mouseX < x+w & tk.mouseY > y & tk.mouseY < y+h;
        mDb(mCount).EPM.track.(this_roi_name) = reg_bool;
        mDb(mCount).EPM.roi(roiCount).dur = mean(reg_bool);
    end
end

for mCount = 1:length(mDb)
    mDb(mCount).EPM.track.open_arm = mDb(mCount).EPM.track.open_arm_top | mDb(mCount).EPM.track.open_arm_bottom;
    mDb(mCount).EPM.track.closed_arm = mDb(mCount).EPM.track.closed_arm_left | mDb(mCount).EPM.track.closed_arm_right;
end
end

% save a reference frame from the video
function [] = save_ref_img_EPM(metadata)
frame_number = 1000;
for mCount = 1:height(metadata)
    m = table2struct(metadata(mCount, :));
    v = VideoReader([m.fdir_EPM, m.fprefix_EPM, 'behaviour_cam.mp4']);
    ref_img = rgb2gray(read(v, frame_number));
    imwrite(cat(3, ref_img, ref_img, ref_img), [m.fprefix_EPM, '_EPM_frame' num2str(frame_number) '.png']);
end
end

% save a reference frame from the video
function [] = save_ref_img_OFT(mDb)
frame_number = 1000;
for mCount = 1:length(mDb)
    m = mDb(mCount);
    if ~isempty(m.fprefix_OFT)
        v = VideoReader([m.fdir_OFT, m.fprefix_OFT, 'behaviour_cam.mp4']);
        ref_img = rgb2gray(read(v, frame_number));
        imwrite(cat(3, ref_img, ref_img, ref_img), [m.fprefix_OFT, '_OFT_frame' num2str(frame_number) '.png']);
    end
end
end


function [photodata, t, ref_img, track] = process_EPM(m, plotflag)
if nargin == 1
    plotflag = false;
end
fname_vid_EPM = [m.fprefix_EPM, 'behaviour_cam.mp4'];
fname_pos_EPM = [m.fprefix_EPM 'behaviour_cam.txt'];
fname_photo_EPM = [m.fprefix_EPM '_all.csv'];

channels = [415, 470, 560];
flag_415 = 17;
flag_470 = 18;
flag_560 = 20;

region_red = 'Region0R';
region_green = 'Region1G';

photodata_target_sr = 30; % Hz
t_start = m.start_frame_EPM/photodata_target_sr; % s

% read photometry data
photodata_all = readtable([m.fdir_EPM fname_photo_EPM]);
photodata_all.Timestamp = photodata_all.Timestamp - photodata_all.Timestamp(1);

photodata_sr = round(1/(numel(channels)*mean(diff(photodata_all.Timestamp - photodata_all.Timestamp(1))))); % for each channel
assert(photodata_sr == photodata_target_sr);

t_all = (0:floor(max(photodata_all.Timestamp)*photodata_sr)-1)'/photodata_sr;

sel = ones(size(photodata_all.Timestamp));
if strcmp(m.MouseID, 'M1698')
    sel(photodata_all.Timestamp > 211.5 & photodata_all.Timestamp < 229.6) = NaN;
end
photodata_raw = table;
photodata_raw.GCaMP6s = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_470 & sel == 1), ...
    photodata_all.(region_green)(photodata_all.Flags == flag_470 & sel == 1), ...
    t_all, 'linear', 'extrap');
photodata_raw.GCaMP6s_iso = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_415 & sel == 1), ...
    photodata_all.(region_green)(photodata_all.Flags == flag_415 & sel == 1), ...
    t_all, 'linear', 'extrap');
photodata_raw.jRGECO1a = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_560 & sel == 1), ...
    photodata_all.(region_red)(photodata_all.Flags == flag_560 & sel == 1), ...
    t_all, 'linear', 'extrap');
photodata_raw.jRGECO1a_iso = interp1( ...
    photodata_all.Timestamp(photodata_all.Flags == flag_415 & sel == 1), ...
    photodata_all.(region_red)(photodata_all.Flags == flag_415 & sel == 1), ...
    t_all, 'linear', 'extrap');

% Get a frame from the EPM video at start time
v = VideoReader([m.fdir_EPM, fname_vid_EPM]);
ref_img = rgb2gray(read(v, (t_start+10)*photodata_target_sr));

% Read tracking data
track = readtable([m.fdir_EPM, fname_pos_EPM]);

% grapple with differing number of frames in video and photometry data
assert(v.NumFrames == height(track));
if v.NumFrames > height(photodata_raw)
    % DISCARD FRAMES IN THE END
    track = track(1:height(photodata_raw), :);
elseif v.NumFrames < height(photodata_raw)
    % DISCARD END OF PHOTOMETRY DATA
    photodata_raw = photodata_raw(1:height(track), :);
end

% find the time vector
assert(height(photodata_raw) == height(track));
frame_num = (0:height(track)-1)';
t_vec = frame_num/photodata_target_sr;
frame_sel = t_vec >= t_start;

% only keep data from start time
t = t_vec(frame_sel);
photodata_raw = photodata_raw(frame_sel, :);
track = track(frame_sel, :);

% plot raw GCaMP6s and jRGECO1a signals
subplot(1, 2, 2);
yyaxis left;
plot(t, photodata_raw.GCaMP6s);
yyaxis right;
plot(t, photodata_raw.jRGECO1a);

% detrend using airPLS algorithm
photodata_trend = table;
photodata_detrend = table;
for i = 1:length(photodata_raw.Properties.VariableNames)
    dim_name = photodata_raw.Properties.VariableNames{i};
    if ~strcmp(dim_name, 't')
        [res_sub, trend] = airPLS(photodata_raw.(dim_name)', 10e8);
        photodata_trend.(dim_name) = trend';
        photodata_detrend.(dim_name) = res_sub';
    end
end

% Regress the isosbestic signal from the reference
photodata_reg = table;
[b, ~, r] = regress(photodata_detrend.GCaMP6s, [photodata_detrend.GCaMP6s_iso, ones(length(t), 1)]);
photodata_reg.GCaMP6s = r+b(2);
[b, ~, r] = regress(photodata_detrend.jRGECO1a, [photodata_detrend.jRGECO1a_iso, ones(length(t), 1)]);
photodata_reg.jRGECO1a = r+b(2);

photodata_bandpass = table;
photodata_bandpass.GCaMP6s = bandpass(photodata_reg.GCaMP6s, [0.2, 6], photodata_sr);
photodata_bandpass.jRGECO1a = bandpass(photodata_reg.jRGECO1a, [0.2, 6], photodata_sr);

photodata = struct;
photodata.(m.GCaMP6s) = photodata_reg.GCaMP6s;
photodata.(m.jRGECO1a) = photodata_reg.jRGECO1a;

if plotflag
    % Plot EPM reference image and tracks
    figure;
    subplot(1, 2, 1);
    imagesc(ref_img);
    axis equal;
    colormap gray;
    hold all;
    plot(track.mouseX, track.mouseY);
    axis off;

    % plot the signal and the trend to check
    figure;
    ndim = length(photodata_raw.Properties.VariableNames);
    hax = [];
    for i = 1:ndim
        hax(i) = subplot(ndim, 1, i);
        dim_name = photodata_raw.Properties.VariableNames{i};
        plot(t, photodata_raw.(dim_name));
        hold all;
        plot(t, photodata_trend.(dim_name));
        title(dim_name);
    end
    linkaxes(hax, 'x');

    figure;
    subplot(2, 1, 1);
    plot(t, photodata_detrend.GCaMP6s);
    hold all;
    plot(t, photodata_reg.GCaMP6s);
    title('GCaMP6s');

    subplot(2, 1, 2);
    plot(t, photodata_detrend.jRGECO1a);
    hold all;
    plot(t, photodata_reg.jRGECO1a);
    title('jRGECO1a');
end
end