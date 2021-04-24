% Settings
% Set mainfolder to location of CSVs
mainFolder = '';
file = [mainFolder, '\traces.xlsx'];
dt = 0.09;   %sec
Fs = 1/dt;    %Hz
conditions = {'Normoxia','Hypoxia'};
clr = {'b','r'};
% Import data. Focus on most hypoxic conditions, and fish 5 (it has 5
% active neurons under Normoxia and Hypoxia)
tbl = readtable(file,'Sheet','50');
N_ind = contains(tbl.Properties.VariableNames,'Norm');
H_ind = contains(tbl.Properties.VariableNames,'Hyp');
Nfish_ind = contains(tbl.Properties.VariableNames,'fish5');
Hfish_ind = contains(tbl.Properties.VariableNames,'fish5');
N_ind = and(N_ind,Nfish_ind);
H_ind = and(H_ind,Hfish_ind);
Norm = table2array(tbl(:,N_ind))';
Hypo = table2array(tbl(:,H_ind))';
activity = {Norm,Hypo};
% Plot  example traces
step = 2;
figure
hold on
for l = 1:numel(conditions)
    yoffset = (l-1)*5*step;
    C = activity{l};
    C = bsxfun(@rdivide, C, max(C,[],2));
    for n = 1:size(C,1)
        plot(dt:dt:size(C,2)/Fs,yoffset+C(n,:)*step/2+step*n,clr{l},'LineWidth',1.5)
    end
    h(l) = plot(nan,nan,clr{l});
end
ylim([step/2 yoffset+size(C,1)*step+1])
labels = string(1:size(C,1));
ax = gca;
ax.TickLength = [0 0];
xlim([0 size(C,2)/Fs])
ylim([step/2 yoffset+size(C,1)*step+step/2])
set(gca,'FontSize',14)
xlabel('Time (sec)')
legend(h,conditions)
legend('boxoff')
export_fig([mainFolder '\Fig3B.tif'],gcf,'-tif','-eps')