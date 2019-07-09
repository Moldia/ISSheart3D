
section = 'week6.5_2';

%% region annotation after alignment
fid = fopen('..\RCPatlas\aligned_week6.6_2.csv', 'r');
aligned = textscan(fid, '%s %f %f %f %f %s %s %s %f %f %f %*[^\n]', 'HeaderLines', 1, 'Delimiter',',', 'CollectOutput', true);
fclose(fid);

figure; gscatter(aligned{2}(:,1), aligned{2}(:,2), aligned{3}(:,3))

%% ontology
ontology = importdata('..\RCPatlas\ontology.csv');
ontology = cellfun(@(v) strsplit(v, ','), ontology, 'UniformOutput', 0);
ontology = cat(1, ontology{:});

%%
load(['..\CellCalling\20190603\o_heart_cellcall_' section '_20190603.mat']);

[uRegions, ~, iRegion] = unique(aligned{3}(:,3));

figure; 
subplot(3,6,[1 2 3 7 8 9 13 14 15]); cla;
% gscatter(o.CellYX(:,2), o.CellYX(:,1), aligned{3}(:,3))
hold on;
for i = 1:numel(uRegions)
    if ~strcmp(uRegions{i}, 'NA')
        plot(o.CellYX(iRegion==i,2), o.CellYX(iRegion==i,1),...
            '.', 'Color', hex2rgb(strrep(ontology(strcmp(ontology(:,3), uRegions{i}), end), '"', '')))
        text(max(o.CellYX(:,2))-2000-4200*(i-(ceil(i/3)-1)*3-1), -3000+ceil(i/3)*800,...
            strrep(ontology(strcmp(ontology(:,3), uRegions{i}), 4), '"', ''),...
            'Color', hex2rgb(strrep(ontology(strcmp(ontology(:,3), uRegions{i}), end), '"', '')),...
            'FontSize', 12, 'FontWeight', 'bold');
    else
        plot(o.CellYX(iRegion==i,2), o.CellYX(iRegion==i,1),...
            '.', 'Color', [0 0 0])
        text(max(o.CellYX(:,2))-2000-4200*1, -3000+3*800,...
            'NA',...
            'Color', [0 0 0],...
            'FontSize', 12, 'FontWeight', 'bold');
    end
        
end
set(gca, 'XDir', 'reverse', 'YDir', 'reverse');
ylim([-6000 inf])
axis image
axis off
% legend(cellfun(@(v) strrep(v, '"', ''), uRegions, 'UniformOutput', 0));


[maxp, celltype] = max(o.pCellClass(2:end,:), [], 2);

colors = o.ClassCollapse;
colors(:,1) = cellfun(@(v) v{1}, colors(:,1), 'UniformOutput', 0);
subplotpos = [4 5 6 10 11 16 12 17];

for i = 1:numel(uRegions)
%     subplot(3,6,6*(ceil(i/3)-1)+3+3-mod(i,3));
    subplot(3,6,subplotpos(i));
    cla;
    temp = hist(celltype(maxp>0.5 & iRegion==i), 1:numel(o.ClassNames));
    ph = pie(temp, o.ClassNames);
    for j = 1:2:length(ph)
        ph(j).FaceColor = colors{strcmp(colors(:,1), ph(j+1).String),3};
    end
    if strcmp(uRegions{i}, 'NA')
        title('NA', 'Color', [0 0 0]);
    else
        title(strrep(ontology(strcmp(ontology(:,3), uRegions{i}), 4), '"', ''), 'Color', hex2rgb(strrep(ontology(strcmp(ontology(:,3), uRegions{i}), end), '"', '')));
    end
end

set(gcf, 'Position', [208 101 1157 724], 'Color', 'w', 'InvertHardcopy', 'off');
print('atlas aligned.png', '-dpng', '-r600');


