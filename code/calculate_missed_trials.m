% Script to determine proportion of missed trials for socialdoors
% Prints files to be excluded & missing files in the command window
% Jimmy Wyngaarden, 11 Feb 2022

clear; close all;
maindir = '/data/projects/istart/Shared_Reward/logs';
warning off all

% Specify subs
subs = [1001, 1003, 1004, 1006, 1009, 1010, 1011, 1012, 1013, 1015, 1016, ... %1002, 1007 have no substance use covars
    1019, 1021, 1242, 1243, 1244, 1248, 1249, 1251, 1253, 1255, 1276, ... %1240 1245 1247 missing from log files
    1282, 1286, 1294, 1300, 1301, 1302, 1303, 3116, 3122, 3125, 3140, ... %3101 missing from log files
    3143, 3152, 3164, 3166, 3167, 3170, 3173, 3176, 3189, 3190, ... %3175 missing from log files, 3186 bad data
    3199, 3200, 3206, 3210, 3212, 3218, 3220];

% Create a framework for data_mat--3 columns, sub ID, doors missed, social
% missed
data_mat = zeros(length(subs),3);

% Loop through each subject
for s = 1:length(subs)
    
    % Assign sub ID to first column of data_mat
    data_mat(s,1) = subs(s);
    
    % Loop through monetary then social domains
    run = {'01', '02'};
    for r = 1:length(run)
        
        % Build path for data
        sourcedatadir = fullfile(maindir, num2str(subs(s)));
        sourcedata = fullfile([sourcedatadir '/sub-' num2str(subs(s)) '_task-sharedreward_run-' run{r} '_raw.csv']);
        
        % Confirm file exists
        if isfile(sourcedata)
        
            % Read file
            T = readtable(sourcedata);
        
            % Isolate decision phase
            alltrials = T.resp == 2 | T.resp == 3 | T.resp == 0;
            missedtrials = T.resp == 0;
        
               % Calculate proportion of missed trials
            prop_missed = sum(missedtrials)/sum(alltrials);
        
            % Assign missed trials value to data_mat
            if run{r} == '01'
                data_mat(s,2) = prop_missed;
            else
                data_mat(s,3) = prop_missed;
            end
            
            % Print message for prop missed trials >.20
            if prop_missed > .2
                excl_message = ['Meets exclusion criteria: ', num2str(subs(s)), ' ', run{r}];
                disp(excl_message);
            else
                good_message = ['Good sub: ', num2str(subs(s)), ' ', run{r}];
                disp(good_message);
            end
            
        else
            % Print message if file is missing
            missing_message = ['File not found: ', num2str(subs(s)), ' ', run{r}];
            disp(missing_message);
        end
    end
end
