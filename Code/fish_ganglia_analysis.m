function [midbandpower,AUC_peaks,interpeakinterval] = fish_ganglia_analysis(tbl,school,conditions,removeFlag,Fs,freqLow,freqHigh)

% Declare temp datum-structures
tempCount = zeros(numel(school),numel(conditions));
tempPower = nan(numel(school),numel(conditions));
tempAUC = nan(numel(school),numel(conditions));
tempInterpeak = nan(numel(school),numel(conditions));

for k = 1:numel(school)
    fish = [school{k},'_'];
    fish = fish(~isspace(fish));
    fishind = contains(tbl.Properties.VariableNames,fish);
    for l = 1:numel(conditions)
        conditionind = contains(tbl.Properties.VariableNames,conditions{l});
        % Find data for a fish in a given condition
        ind = and(fishind,conditionind);
        C = table2array(tbl(:,ind))';
        % Normalize
        C_final = bsxfun(@rdivide, C, max(C,[],2));
        % Peak analysis
        temp_peaks = nan(size(C_final,1),1);
        temp_auc = nan(size(C_final,1),1);
        temp_intervals = nan(size(C_final,1),1);
        for j = 1:size(C_final,1)
            responses = smoothdata(C_final(j,:),'Gaussian');
            baseline = prctile(responses',20);
            maxresp = max(responses);
            [pks,ind] = findpeaks(responses,Fs,'MinPeakProminence',0.7*std(responses));
            temp_peaks(j) = numel(pks);
            temp_intervals(j) = mean(diff(ind));
            pk_auc = nan(numel(pks),1);
            pktimes_pre = nan(numel(pks),1);
            pktimes_post = nan(numel(pks),1);
            pkslopes = nan(numel(pks),1);
            for m = 1:numel(pks)
                % Find values near the baseline
                baseind = find(and(responses>baseline-0.01*maxresp,...
                    responses<baseline+0.01*maxresp))/Fs;
                % Pick the ones before peak
                beforeind = find(baseind < ind(m));
                beforeind = baseind(beforeind);
                % Pick the closest baseline, if the peak did not occur
                % early
                if ~isempty(beforeind)
                    beforeind = beforeind(end);
                    % Compute time to peak, and slope
                    pktimes_pre(m) = ind(m) - beforeind;
                    pkslopes(m) = (pks(m) - responses(round(beforeind*Fs)))/(ind(m) - beforeind);
                end
                % Pick the end of the transient
                afterind = find(baseind > ind(m));
                afterind = baseind(afterind);
                % Pick the closest baseline, if the peak did not occur too
                % late
                if ~isempty(afterind)
                    afterind = afterind(1);
                    % Compute time to peak, and slope
                    pktimes_post(m) = afterind - ind(m);
                    pkslopes(m) = (pks(m) - responses(round(beforeind*Fs)))/(ind(m) - beforeind);
                end
                if and(~isempty(beforeind),~isempty(afterind))
                    pk_auc(m) = trapz(C_final(j,round(beforeind*Fs):round(afterind*Fs)));
                end
            end
            temp_auc(j) = nanmean(pk_auc);
        end
        % Remove barely-active neurons
        if removeFlag == 1
            remove = temp_peaks < 2;
            tempAUC(k,l) = nanmean(temp_auc(~remove));
            tempInterpeak(k,l) = mean(temp_intervals(~remove));
            C_final = C_final(~remove,:);
            if size(C_final,1) == 0
                continue
            end
        else
            tempAUC(k,l) = nanmean(temp_auc);
            tempInterpeak(k,l) = mean(temp_intervals);
        end
        % Find the number of neurons
        tempCount(k,l) = size(C_final,1);
        % Spectral analysis (low-frequency)
        tempmidpower = nan(size(C_final,1),1);
        for j = 1:size(C_final,1)
            [power,freq] = periodogram(C_final(j,:),[],[],Fs);
            frange = and(freq>freqLow,freq<=freqHigh);
            tempmidpower(j) = mean(power(frange));
        end
        tempPower(k,l) = mean(tempmidpower);
    end
end
% Remove fish with fewer than 2 recorded neurons
ind = any(tempCount < 2, 2);
tempPower(ind,:) = [];
tempAUC(ind,:) = [];
tempInterpeak(ind,:) = [];
% Finalize
midbandpower = {tempPower(:,1),tempPower(:,2)};
AUC_peaks = {tempAUC(:,1),tempAUC(:,2)};
interpeakinterval = {tempInterpeak(:,1),tempInterpeak(:,2)};