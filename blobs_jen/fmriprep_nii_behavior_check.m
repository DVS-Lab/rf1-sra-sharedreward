% created 3-1-2024 by Jen Yang
% last modified 3-1-2024 by Jen Yang
% to check data availability of incoming new data before running any analyses
% 1. fmriprep availability - must have for anything else
% 2. imaging data availability - check if both runs exist, list out subs by
% run availability
% 3. behavior data availability - same as above
% output
% 1. sub_BothRuns.txt - subject list with both runs available for analyses
% 2. sub_OnlyRunOne.txt - subject list with run 1 available for analyses
% 3. sub_OnlyRunTwo.txt - subject list with run 2 available for analyses

%% check fmriprep availability
fmriprep_dir = "/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep";
file_list = dir(fmriprep_dir);
file_list_cell = struct2cell(file_list);
[~,N_row] = size(file_list_cell);
sub_list = file_list_cell(1,:);
isdir_list = file_list_cell(5,:);
sub_list_clean = [];
% sub_list_clean_N = 0;
for i = 1:N_row
    % i = 11;
    isdir_i = isdir_list{i};
    if isdir_i > 0
        sub_list_i = sub_list{i};
        sub_ID_i = sscanf(sub_list_i,"sub-%d");
        sub_list_clean = [sub_list_clean, sub_ID_i];
        % sub_list_clean(sub_list_clean_N) = sub_ID_i;
    end
end

%% check confound, imaging data using the sub_list_clean generated
[~,N_sub] = size(sub_list_clean);
confound_dir = "/ZPOOL/data/projects/rf1-sra-data/derivatives/fsl/confounds";
behavior_dir = "/ZPOOL/data/projects/rf1-sra/stimuli/Scan-Card_Guessing_Game/logs";
brain_dir = "/ZPOOL/data/projects/rf1-sra-data/bids/";

for n = 1:N_sub
     % n = 74
    subID_n = sub_list_clean(1,n);
    for r = 1:2
        % r = 1;
        % check confound data availability
        file_confound_n_r = fullfile(...
            confound_dir, ...
            sprintf("sub-%d", subID_n), ...
            sprintf("sub-%d_task-sharedreward_run-%d_desc-fslConfounds.tsv",subID_n,r));
        if isfile(file_confound_n_r) == 0
            disp(sprintf("sub %d run %d confound missing", subID_n, r))
        end
        % check behavior data availability
        file_behavior_n_r = fullfile(...
            behavior_dir,...
            num2str(subID_n), ...
            sprintf("sub-%d_task-sharedreward_run-%d_raw.csv", subID_n,r));
        if isfile(file_behavior_n_r) == 0
            disp(sprintf("sub %d run %d behavior missing", subID_n, r))
        end
        % check frmi data availability
        file_brain_n_r = fullfile(...
            brain_dir,sprintf("sub-%d/func", subID_n), ...
            sprintf("sub-%d_task-sharedreward_run-%d_echo-1_bold.nii.gz", subID_n,r));
        if isfile(file_brain_n_r) == 0
            disp(sprintf("sub %d run %d brain missing", subID_n, r))
        end
        % mark runs with both behavior and brain data available
        sub_list_clean(r+1,n) = ...
            isfile(file_confound_n_r) .* ...
            isfile(file_behavior_n_r).* ...
            isfile(file_brain_n_r);
    end
end

sub_list_clean(4,:) = sub_list_clean(2,:) + sub_list_clean(3,:);
sub_all = sub_list_clean(1,:);
sub_BothRuns = sub_list_clean(1,sub_list_clean(4,:) == 2);
sub_OnlyRunOne = sub_list_clean(1,sub_list_clean(4,:) == 1 & sub_list_clean(2,:) == 1);
sub_OnlyRunTwo = sub_list_clean(1,sub_list_clean(4,:) == 1 & sub_list_clean(3,:) == 1);

sub_all = array2table(sub_all');
sub_BothRuns = array2table(sub_BothRuns');
sub_OnlyRunOne = array2table(sub_OnlyRunOne');
sub_OnlyRunTwo = array2table(sub_OnlyRunTwo');

code_dir = "/ZPOOL/data/projects/rf1-sra-sharedreward/code";

writetable(sub_all,...
    fullfile(code_dir,'sub_all.txt'),'Delimiter',' ', 'WriteVariableNames',false);
writetable(sub_BothRuns,...
    fullfile(code_dir,'sub_BothRuns.txt'),'Delimiter',' ', 'WriteVariableNames',false);
writetable(sub_OnlyRunOne,...
    fullfile(code_dir,'sub_OnlyRunOne.txt'),'Delimiter',' ', 'WriteVariableNames',false);
writetable(sub_OnlyRunTwo,...
    fullfile(code_dir,'sub_OnlyRunTwo.txt'),'Delimiter',' ', 'WriteVariableNames',false);






