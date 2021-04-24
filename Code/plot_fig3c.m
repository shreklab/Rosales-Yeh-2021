% Settings
% Set mainfolder to location of CSVs
mainFolder = '';
file = [mainFolder, '\traces.xlsx'];
dt = 0.09;   %sec
Fs = 1/dt;    %Hz
nFrames = 1500;
tests = {'Norm','Hyp'};
conditions = {'Normoxia','Hypoxia'};
sets = {'50','60','85','105'};
clr = {'b','r'};
% Remove neurons with fewer than 2 transients
removeFlag = 1;
% Band-pass freqs
freqLow = 1/(round(nFrames*dt)/2);
freqHigh = 0.1;
% Fish in each set
Final_50 = [1,2,5,6,7];
Final_60 = [1,2,7,10,11];
Final_85 = [1,2,4,5];
Final_105 = [1:3,7];
finalfish = {Final_50;Final_60;Final_85;Final_105};
%% Analyze fish, condition = 50
j = 1;
% Import data
tbl = readtable(file,'Sheet',sets{j});
school = strcat(repmat('fish',[numel(finalfish{j}),1]),num2str(finalfish{j}'));
school = cellstr(school);
[pdgrams,f] = fish_analysis(tbl,school,tests,removeFlag,Fs);
% Plot periodograms
figure
hold on
clr = {'b','r'};
count = 1;
nCols = max(cellfun(@numel,finalfish));
for j = 1
    for l = 1:numel(tests)
        pdf = pdgrams{j,l};
        % Remove empty periodograms
        pdf(cellfun(@isempty,pdf)) = [];
        % Mean
        pdf = cell2mat(pdf');
        pdf_mu = mean(pdf,2);
        pdf_sigma = std(pdf,0,2);
        % Plot the periodogram
        plot(f,pdf_mu,clr{l})
    end
end
xline(freqLow,':')
xline(freqHigh,':')
xlim([0 freqHigh])
set(gcf,'color','w')
if exist('h','var')
    legend([h.mainLine], conditions)
else
    legend(conditions)
end
legend('boxoff')
ylim([0 1])
export_fig([mainFolder '\Fig3C.tif'],gcf,'-tif','-eps')