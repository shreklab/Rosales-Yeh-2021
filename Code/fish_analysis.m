function [pdgram,f] = fish_analysis(tbl,school,conditions,removeFlag,Fs)

% Declare temp datum-structures
tempCount = zeros(numel(school),numel(conditions));
tempPDGRAM = cell(numel(school),numel(conditions));

for k = 1:numel(school)
    fish = [school{k},'_'];
    fishind = contains(tbl.Properties.VariableNames,fish);
    for l = 1:numel(conditions)
        conditionind = contains(tbl.Properties.VariableNames,conditions{l});
        % Find data for a fish in a given condition
        ind = and(fishind,conditionind);
        C = table2array(tbl(:,ind))';
        % Normalize
        C_final = bsxfun(@rdivide, C, max(C,[],2));
        % Find transients
        temp_peaks = nan(size(C_final,1),1);
        for j = 1:size(C_final,1)
            responses = smoothdata(C_final(j,:),'Gaussian');
            pks = findpeaks(responses,Fs,'MinPeakProminence',0.7*std(responses));
            temp_peaks(j) = numel(pks);
        end
        % Remove barely-active neurons
        if removeFlag == 1
            remove = temp_peaks < 2;
            C_final = C_final(~remove,:);
            if size(C_final,1) == 0
                continue
            end
        else
            tempPeaks(k,l) = mean(temp_peaks);
        end
        % Find the number of neurons
        tempCount(k,l) = size(C_final,1);
        % Average all time-series
        if size(C_final,1) > 1
            C_final_avg = mean(C_final);
        else
            C_final_avg = C_final;
        end
        % Spectral analysis (low-frequency)
        tempPDGRAM(k,l) = {periodogram(C_final_avg)};
    end
end
[~,f] = periodogram(C_final_avg,[],[],Fs);
% Remove fish with fewer than 2 recorded neurons
ind = any(tempCount < 2,2);
tempPDGRAM(ind,:) = [];
% Finalize
pdgram = {tempPDGRAM(:,1),tempPDGRAM(:,2)};