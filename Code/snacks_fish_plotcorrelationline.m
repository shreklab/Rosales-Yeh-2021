function out = snacks_fish_plotcorrelationline(results,conditions,testLabels,textstring,titlestring,savestring)

% Input:
% results: first column is Normoxia, second column is Hypoxia, rows are
% different levels of Hypoxia
% hyplevels: levels of Hypoxia
% testLabels: individual bar names
% textstring: the y-axis label

% Combine the results
fullresponse = cell(numel(testLabels),1);
for l = 1:numel(testLabels)
    response = results(:,l);
    counts = cellfun(@numel,response);
    index = [];
    for j = 1:numel(conditions)
        index = [index;repmat(conditions(j),[counts(j),1])];
    end
    fullresponse(l) = {[index,vertcat(response{:})]};
end
% Add scatter points
Rsquare = zeros(numel(testLabels),1);
Pvalue = zeros(numel(testLabels),1);
colorStr = {'b','r'};
data = zeros(2,2,numel(testLabels));
pos = [365,535,1212,758];
figure('Position',pos)
for l = 1:numel(testLabels)
    response = fullresponse{l};
    X = [ones(size(response(:,1))), response(:,1)];
    y = response(:,2);
    scatter(response(:,1),response(:,2),colorStr{l},...
        'Jitter','on','JitterAmount',0.1)
    h = lsline;
    data(:,:,l) = [h.XData.' h.YData.'];
    cla
    [~,~,~,~,stats] = regress(y,X);
    Rsquare(l) = stats(1);
    Pvalue(l) = stats(3);
end
% Plot the data, add line
hold on
h = [];
for l = 1:numel(testLabels)
    response = fullresponse{l};
    X = [ones(size(response(:,1))), response(:,1)];
    y = response(:,2);
    scatter(response(:,1),response(:,2),colorStr{l},'filled',...
        'Jitter','on','JitterAmount',0.4)
    for m = 1:numel(conditions)
        smallResponse = response(response(:,1)==conditions(m),:);
        errorbar(conditions(m),nanmean(smallResponse(:,2)),nanstd(smallResponse(:,2)),[colorStr{l}, 's'],...
            'MarkerSize',12)
    end
    h(l) = plot(data(:,1,l),data(:,2,l),colorStr{l});
end
% Trim
% Indicate the fits
dim = [0.435148514851485,0.840369394712525,0.174917486782121,0.065963059113334];
linelbl = {[testLabels{1} ' (R^2 = ', num2str(Rsquare(1),2), '; p = ', num2str(Pvalue(1),2),')'];
    [testLabels{2} ' (R^2 = ', num2str(Rsquare(2),2), '; p = ', num2str(Pvalue(2),2),')']};
annotation('textbox',dim,'String',linelbl,'FontSize',14,'FitBoxToText','on')
% En-title
if ~isempty(titlestring)
    title(titlestring)
end
% Finalize
xlim([min(conditions)-10,max(conditions)+10])
legend(h,testLabels,'AutoUpdate','off')
xlabel('Experimental Condition')
ylabel(textstring)
set(gca,'FontSize',18)
% Save
%export_fig(savestring,gcf,'-tif','-eps')