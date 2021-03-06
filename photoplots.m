%% behavior markers with 
m = mDb(strcmp({mDb.MouseID}, 'F1728'));

GCaMP_color = [0.4660, 0.6740, 0.1880];
jRGECO_color = [0.6350, 0.0780, 0.1840];

BLA_color = [0, 0.4470, 0.7410];
CeM_color = [0.6350, 0.0780, 0.1840]; %[0.8500, 0.3250, 0.0980];

track_line_color = [0.9290, 0.6940, 0.1250];
centroid_color = [0.3010, 0.7450, 0.9330];

roi_names = {'open_arm', 'closed_arm', 'center'};
if sum(strcmp(m.MouseID, {'F0002', 'F1728'})) == 1
    if strcmp(m.MouseID, 'F0002')
        diff_start_times = [146, 164, 231, 275, 650, 665, 685, 745];
        diff_end_times =   [153, 167, 242, 300, 660, 675, 695, 750];
        same_start_times = [164, 209, 300, 610, 790];
        same_end_times =   [171, 231, 315, 615, 810];
    end
    if strcmp(m.MouseID, 'F1728')
        diff_start_times = [125, 490, 549, 570, 620, 650, 700, 740, 783, 810, 818, 885];
        diff_end_times =   [130, 511, 554, 603, 645, 690, 730, 765, 803, 815, 823, 895];
        same_start_times = [240, 410, 610, 840];
        same_end_times =   [310, 480, 620, 850];
    end
    
    m.EPM.track.CaSig_diff = false(size(m.EPM.t));
    for dtCount = 1:length(diff_start_times)
        m.EPM.track.CaSig_diff(m.EPM.t > diff_start_times(dtCount) & m.EPM.t < diff_end_times(dtCount)) = true;
    end
    m.EPM.track.CaSig_same = false(size(m.EPM.t));
    for stCount = 1:length(same_start_times)
        m.EPM.track.CaSig_same(m.EPM.t > same_start_times(stCount) & m.EPM.t < same_end_times(stCount)) = true;
    end
    roi_names{end+1} = 'CaSig_diff';
    roi_names{end+1} = 'CaSig_same';
end
% roi_names = {'open_arm_top', 'open_arm_bottom', 'closed_arm_left', 'closed_arm_right', 'center'};
figure('Units','normalized','OuterPosition',[0, 0, 1, 1]);
axEntry = subplot(2, 1, 1);
for roiCount = 1:length(roi_names)
    plot(m.EPM.t, m.EPM.track.(roi_names{roiCount}) - 1.2*roiCount); 
    hold all;
end
ylim([-1.2*roiCount-0.2, 0]);
legend(roi_names, 'Interpreter', 'none');
xlabel('Time(s)');
title(m.MouseID);

axBLA = subplot(2, 1, 2);
yyaxis left;
if strcmp(m.GCaMP6s, 'aIC_BLA')
    yl_prefix = 'GCaMP6s';
else
    yl_prefix = 'jRGECO1a';
end
plot(m.EPM.t, m.EPM.aIC_BLA, LineWidth=1.5, color=BLA_color);
xlabel('Time (s)');
ylabel([yl_prefix '  Fluorescence (a.u.)']);
% title('aIC-BLA');

% axCeM = subplot(3, 1, 3);
yyaxis right;
if strcmp(m.GCaMP6s, 'aIC_CeM')
    yl_prefix = 'GCaMP6s';
else
    yl_prefix = 'jRGECO1a';
end
plot(m.EPM.t, m.EPM.aIC_CeM, LineWidth=1.5, color=CeM_color);
xlabel('Time (s)');
ylabel([yl_prefix '  Fluorescence (a.u.)']);
% title('aIC-CeM');

linkaxes([axEntry, axBLA], 'x');

%% compare activity in aIC-BLA and aIC-CeM neurons


all_mID = {mDb.MouseID};
for mCount = 1:length(all_mID)
% m = mDb(strcmp({mDb.MouseID}, 'M1698'));
h = figure(Units="normalized", OuterPosition=[0, 0, 1, 1]);
m = mDb(mCount);
roi_names = {'closed_arm', 'open_arm', 'center'};
hax = [];
BLA_med = median(m.EPM.aIC_BLA);
BLA_std = std(m.EPM.aIC_BLA);
CeM_med = median(m.EPM.aIC_CeM);
CeM_std = std(m.EPM.aIC_CeM);
sel_BLA = m.EPM.aIC_BLA > BLA_med + BLA_std | m.EPM.aIC_BLA < BLA_med - BLA_std;
sel_CeM = m.EPM.aIC_CeM > CeM_med + CeM_std | m.EPM.aIC_CeM < CeM_med - CeM_std;
for roiCount = 1:length(roi_names)
    roi_name = roi_names{roiCount};
    hax(roiCount) = scatter(m.EPM.aIC_BLA(m.EPM.track.(roi_name)), m.EPM.aIC_CeM(m.EPM.track.(roi_name)));
    hold all;
end
legend(hax, roi_names, 'Interpreter','none');
plot([0, 0], get(gca, 'YLim'), 'k', LineWidth=1.5);
plot(get(gca, 'XLim'), [0, 0], 'k', LineWidth=1.5);
if strcmp(m.GCaMP6s, 'aIC_BLA')
    xl_pre = 'GCaMP6s';
    yl_pre = 'jRGECO1a';
else
    xl_pre = 'jRGECO1a';
    yl_pre = 'GCaMP6s';
end
xlabel(['aIC-BLA photometry signal (', xl_pre, ')']);
ylabel(['aIC-CeM photometry signal (', yl_pre, ')']);
if strcmp(m.MouseID, 'F1727')
    xlim([-1 1]*0.2e-3);
end
title(m.MouseID);
saveas(h, ['C:\Users\Praneeth\Desktop\Cajal2021\screenshots\', m.MouseID, '_population_scatter.png']);
close(h);
end
% m = mDb(strcmp({mDb.MouseID}, 'F1728'));
% m = mDb(strcmp({mDb.MouseID}, 'M1698'));

%%
% Fluorescence heat map
% Ca2+ fluorescence bar graph
% Scatter plot comparing Ca2+ activity - Scatter plot through time? Open vs closed arms, choose some points randomly to reduce the density.
% F0002, around 700s, look for divergent activity in the populations.
% 740 s - aIC-CeM activity falls right before a turn in the closed arm!!