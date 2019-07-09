load(['..\CellCalling\20190603\o_heart_cellcall_week6.5_2_20190603.mat']);
MinReads = 5;

[maxp, celltype] = max(o.pCellClass(1:end-1,:), [], 2);
thesecells = sum(o.pSpotCell(:,1:end-1), 1) > MinReads;

towrite = [o.ClassNames(celltype),...    % class name
    num2cell(full(thesecells') & celltype~=13 & maxp>0.5),... % include?
    cellfun(@rgb2hex, o.ClassCollapse(celltype,3), 'UniformOutput', 0)]';   % class color


fid = fopen('cell_class.csv', 'w');
fprintf(fid, 'celltype,include,color\n');
fprintf(fid, '%s,%d,%s\n', towrite{:});
fclose(fid);

fid = fopen('segmentation.csv', 'w');
fprintf(fid, 'x,y,intensity,area\n');
fprintf(fid, '%d,%d,nan,nan\n', flipud(o.CellYX'));
fclose(fid);