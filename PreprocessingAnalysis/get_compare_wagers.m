function get_compare_wagers(iSubjectArray, doStats)
% computes HGF for given subjects and creates parametric modulators for
% concatenated design matrix, plus base regressors for event onsets
%



% for WAGAD_0006, no physlogs were recorded

paths = get_paths_wagad(); % dummy subject to get general paths



if nargin < 1
    % manual setting...if you want to exclude any subjects
    iExcludedSubjects = [14 25 32 33 34 37];
    iSubjectArray = get_subject_ids(paths.data)';
    % manual setting...if you want to exclude any subjects
    iSubjectArray = setdiff(iSubjectArray, iExcludedSubjects);
end

if nargin < 2
    doStats = 1;
end


addpath(paths.code.model);
nSubjects = numel(iSubjectArray);

% Get task structure
AdviceCodingUnstable=[zeros(25,1)' zeros(15,1)' ones(30,1)' zeros(25,1)' ones(25,1)' zeros(15,1)' ones(25,1)'];
RewardCodingUnstable=[zeros(25,1)' ones(15,1)' ones(30,1)' ones(25,1)' zeros(25,1)' zeros(15,1)' zeros(25,1)'];

AdviceCodingStable = [ones(25,1)' ones(15,1)' zeros(30,1)' ones(25,1)' zeros(25,1)' ones(15,1)' zeros(25,1)'];
RewardCodingStable = [ones(25,1)' zeros(15,1)' zeros(30,1)' zeros(25,1)' ones(25,1)' ones(15,1)' ones(25,1)'];

for s = 1:nSubjects
    iSubj = iSubjectArray(s);
    paths = get_paths_wagad(iSubj);
    for iRsp=1
        %%
        load(paths.fnFittedModel{iRsp},'est','-mat');
        actual_wager = est.y([2:end],2);
        predicted_wager = est.predict_wager;
        
        actual_wager_aStable = actual_wager(AdviceCodingStable);
        actual_wager_aUnstable = actual_wager(AdviceCodingUnstable);
        actual_wager_rStable = actual_wager(RewardCodingStable);
        actual_wager_rUnstable = actual_wager(RewardCodingUnstable);
        
        predicted_wager_aStable = predicted_wager(AdviceCodingStable);
        predicted_wager_aUnstable = predicted_wager(AdviceCodingUnstable);
        predicted_wager_rStable = predicted_wager(RewardCodingStable);
        predicted_wager_rUnstable = predicted_wager(RewardCodingUnstable);
        
        par{s,1} = actual_wager_aStable;
        par{s,2} = actual_wager_aUnstable;
        par{s,3} = actual_wager_rStable;
        par{s,4} = actual_wager_rUnstable;
        
        par{s,5} = predicted_wager_aStable;
        par{s,6} = predicted_wager_aUnstable;
        par{s,7} = predicted_wager_rStable;
        par{s,8} = predicted_wager_rUnstable;
           
    end
end

if doStats
    temp = cell2mat(par);
    figure; bar(mean(temp(:,[1:4]),1),'r');
    hold on; bar(mean(temp(:,[5:8]),1),'b');
    %
    [R,P,RLO,RUP]=corrcoef(temp(:,1),temp(:,5));
    figure; scatter(temp(:,1),temp(:,5));
    disp(['Significance correlation AStable' num2str(P(1,2))]);   
     %
    [R,P,RLO,RUP]=corrcoef(temp(:,2),temp(:,6));
    figure; scatter(temp(:,2),temp(:,6));
    disp(['Significance correlation AUnstable' num2str(P(1,2))]);
     %
    [R,P,RLO,RUP]=corrcoef(temp(:,3),temp(:,7));
    figure; scatter(temp(:,3),temp(:,7));
    disp(['Significance correlation RStable' num2str(P(1,2))]);
     %
    [R,P,RLO,RUP]=corrcoef(temp(:,4),temp(:,8));
    figure; scatter(temp(:,4),temp(:,8));
    disp(['Significance correlation RUnstable' num2str(P(1,2))]);
    
end
save([paths.stats.secondLevel.covariates, '/wagers_actual_versus_predicted.mat'],'temp', '-mat');
end