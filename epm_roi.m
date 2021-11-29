figure('Units','normalized','OuterPosition',[0, 0, 0.5, 1]);
imagesc(mDb(1).EPM.ref_img);
impixelinfo;
colormap gray;
axis equal;
hold all;
plot(mDb(1).EPM.track.mouseX, mDb(1).EPM.track.mouseY);



%%
mID = 'M1698';

m = mDb(strcmp({mDb.MouseID}, mID));
tk = m.EPM.track;
ref_img = m.EPM.ref_img;

bin_size = 10; % pixels
Xsize = 1024;
Ysize = 1280;
[N, c] = hist3([tk.mouseX, tk.mouseY], ctrs={bin_size/2:bin_size:Xsize-bin_size/2, bin_size/2:bin_size:Ysize-bin_size/2});
Hmap = N'/30; % seconds

figure('Units','normalized','OuterPosition',[0, 0, 0.5, 1]);
imagesc(cat(3, ref_img, ref_img, ref_img));
impixelinfo;
colormap hot;
axis equal;
hold all;
% plot(tk.mouseX, tk.mouseY);
imagesc(c{1}, c{2}, Hmap, 'AlphaData', Hmap > 0); colorbar;
caxis([0, bin_size*1.2]);