% Settings
% Set mainfolder to location of CSVs
mainFolder = '';
file = [mainFolder, '\traces.xlsx'];
dt = 0.09;   %sec
Fs = 1/dt;    %Hz
nFrames = 1500;
ganglia = {'ganglia1','ganglia2'};
tests = {'Norm','Hyp'};
ppO2 = [50;60;85;105];    % partial pressure O2 (mmHg)
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
%% Analyze ganglia
for g = ganglia
    file = [g{:},'_traces.xlsx'];  
    midbandpower = cell(numel(sets),numel(conditions));
    AUC_peaks = cell(numel(sets),numel(tests));
    interpeakintervals = cell(numel(sets),numel(conditions));
    for j = 1:numel(sets)
        % Import data
        tbl = readtable(file,'Sheet',sets{j});
        school = strcat(repmat('fish',[numel(finalfish{j}),1]),num2str(finalfish{j}'));
        school = cellstr(school);
        [midbandpower(j,:),AUC_peaks(j,:),interpeakintervals(j,:)] = ...
            fish_ganglia_analysis(tbl,school,tests,removeFlag, ...
            Fs,freqLow,freqHigh);
    end
    
    % Plot the results
    snacks_fish_plotcorrelationline(midbandpower,ppO2,conditions,...
        ['Mean Power: ', num2str(freqLow), ' to ', num2str(freqHigh)],...
        g,[mainFolder,'\corrPower_',g])
    snacks_fish_plotcorrelationline(AUC_peaks,ppO2,conditions,...
        ['Mean AUC'],...
        g,[mainFolder,'\corrAUC_',g])
    snacks_fish_plotcorrelationline(interpeakintervals,ppO2,conditions,...
        ['Interpeak Interval (secs)'],...
        g,[mainFolder,'\corrInterpeakIntervals_',g])
end