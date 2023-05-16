clear all
close all
clc

% This code generates a composite reward sensitivity score using BAS and SR
% data. This code also generates a composite substance use score for AUDIT
% and DUDIT.
%% Inputs
currentdir = pwd;
output_path = currentdir; % Set output path if you would like.% 
input = '/data/projects/istart-sharedreward/derivatives/ISTART-ALL-Combined-042122.xlsx'; % input file  %  
data = readtable(input);
Composite_raw = [data.('ID'), data.('BISBAS_BAS'), data.('SPSRWD')];
AUDIT_raw = [data.('ID'), data.('audit_standard_score')];
DUDIT_raw = [data.('ID'), data.('dudit_standard_score')];

make_reward = 0;
make_substance = 1;


if make_reward == 1
   
% Subjects reflect N=49.
    subjects = [1001, 1002, 1003, 1004, 1006, 1007, 1009, 1010, 1011, 1012, 1013, 1015, 1016, 1019, 1021, 1242, 1243, 1244, 1248, 1249, 1251, 1255, 1276, 1282, 1286, 1294, 1301, 1302, 1303, 3116, 3122, 3125, 3140, 3143, 3152, 3166, 3167, 3170, 3173, 3176, 3186, 3189, 3190, 3199, 3200, 3206, 3210, 3212, 3218, 3220];

end

% AUDIT_missing =
% 
%         1001
%         1002
%         1007
%         1013
%         3140
%         3170

% DUDIT_missing =
%         1002
%         1007
%         1251

if make_substance == 1
    subjects = [1001, 1003, 1004, 1006, 1009, 1010, 1011, 1012, 1013, 1015, 1016, 1019, 1021, 1242, 1243, 1244, 1248, 1249, 1251, 1255, 1276, 1282, 1286, 1294, 1301, 1302, 1303, 3116, 3122, 3125, 3140, 3143, 3152, 3166, 3167, 3170, 3173, 3176, 3186, 3189, 3190, 3199, 3200, 3206, 3210, 3212, 3218, 3220];
end

%% Collate data to reflect desired subjects for reward sensitivity

% This code can help with debugging. Check "composite missing" to see which
% subjects need to be eliminated.

if make_reward == 1 
    
% Eliminate Nans

eliminate_rows = any(isnan(Composite_raw),2);
Reward_temp = [];

for ii = 1:length(Composite_raw)
    keep = [];
    row = Composite_raw(ii,:);
    if eliminate_rows(ii) == 0
        keep = row;
    end
    Reward_temp = [Reward_temp; keep];
end

Composite_missing = [];
Composite_final = [];
for ii = 1:length(subjects)
    subj = subjects(ii);
    subj_row = find(Reward_temp==subj);
    if subj_row > 0
        test = Reward_temp(subj_row,:);
        if test(2) < 100 % Tests for 999s in the data
            Composite_final = [Composite_final;test];
        else
            Composite_missing = [Composite_missing; subjects(ii)];
        end
    end
    
end

%% Perform z-scoring.

compRS = zscore(Composite_final(:,2)) + zscore(Composite_final(:,3)); % combine measures for your final data

figure, hist(compRS,50); title('Composite') % look at your data
figure, hist(compRS.^2,50); title('Composite Squared') % look at your data squared

normedRS = zeros(length(compRS),1); % create empty array for storing data
deciles = prctile(compRS,[10 20 30 40 50 60 70 80 90]); % identify quintiles

% place data into the appropriate quintiles
normedRS(compRS < deciles(1),1) = 1;
normedRS(compRS >= deciles(1) & compRS < deciles(2),1) = 2;
normedRS(compRS >= deciles(2) & compRS < deciles(3),1) = 3;
normedRS(compRS >= deciles(3) & compRS < deciles(4),1) = 4;
normedRS(compRS >= deciles(4) & compRS < deciles(5),1) = 5;
normedRS(compRS >= deciles(5) & compRS < deciles(6),1) = 6;
normedRS(compRS >= deciles(6) & compRS < deciles(7),1) = 7;
normedRS(compRS >= deciles(7) & compRS < deciles(8),1) = 8;
normedRS(compRS >= deciles(8) & compRS < deciles(9),1) = 9;
normedRS(compRS >= deciles(9),1) = 10;
%% 

figure, hist(normedRS,50); title('Normed Composite') % look at your data
figure, hist(normedRS.^2,50); title('Normed Composite Squared') % look at your data squared

%% Output results.

Combined = [Composite_final(:,1), normedRS, normedRS.^2]; % Pairs subject numbers with RS scores. 
Composite_final_output = array2table(Combined(1:end,:),'VariableNames', {'Subject', 'Composite_Reward', 'Composite_Reward_Squared'});

name = ('\Composite_Reward.xlsx');
fileoutput = [output_path, name];
writetable(Composite_final_output, fileoutput); % Save as csv file

end

%% Make substance use

if make_substance == 1

% This code can help with debugging. Check "composite missing" to see which
% subjects need to be eliminated.

  
% Eliminate Nans

eliminate_rows = any(isnan(AUDIT_raw),2);
Substance_temp = [];

for ii = 1:length(AUDIT_raw)
    keep = [];
    row = AUDIT_raw(ii,:);
    if eliminate_rows(ii) == 0
        keep = row;
    end
    Substance_temp = [Substance_temp; keep];
end

AUDIT_missing = [];
AUDIT_final = [];

for ii = 1:length(subjects)
    subj = subjects(ii);
    subj_row = find(Substance_temp==subj);
    if subj_row > 0
        test = Substance_temp(subj_row(1),:);
        if test(2) < 100 % Tests for 999s in the data
            AUDIT_final = [AUDIT_final;test];
        else
            AUDIT_missing = [AUDIT_missing; subjects(ii)];
        end
    end
    
end

eliminate_rows = any(isnan(DUDIT_raw),2);
Substance_temp = [];

for ii = 1:length(AUDIT_raw)
    keep = [];
    row = DUDIT_raw(ii,:);
    if eliminate_rows(ii) == 0
        keep = row;
    end
    Substance_temp = [Substance_temp; keep];
end

DUDIT_missing = [];
DUDIT_final = [];
for ii = 1:length(subjects)
    subj = subjects(ii);
    subj_row = find(Substance_temp==subj);
    if subj_row > 0
        test = Substance_temp(subj_row,:);
        if test(2) < 100 % Tests for 999s in the data
            DUDIT_final = [DUDIT_final;test];
        else
            DUDIT_missing = [DUDIT_missing; subjects(ii)];
        end
    end
    
end


%% Perform z-scoring.

compRS = zscore(AUDIT_final(:,2)) + zscore(DUDIT_final(:,2)); % combine measures for your final data

figure, hist(compRS,50); title('Composite') % look at your data
figure, hist(compRS.^2,50); title('Composite Squared') % look at your data squared

normedRS = zeros(length(compRS),1); % create empty array for storing data
deciles = prctile(compRS,[10 20 30 40 50 60 70 80 90]); % identify quintiles

% place data into the appropriate quintiles
normedRS(compRS < deciles(1),1) = 1;
normedRS(compRS >= deciles(1) & compRS < deciles(2),1) = 2;
normedRS(compRS >= deciles(2) & compRS < deciles(3),1) = 3;
normedRS(compRS >= deciles(3) & compRS < deciles(4),1) = 4;
normedRS(compRS >= deciles(4) & compRS < deciles(5),1) = 5;
normedRS(compRS >= deciles(5) & compRS < deciles(6),1) = 6;
normedRS(compRS >= deciles(6) & compRS < deciles(7),1) = 7;
normedRS(compRS >= deciles(7) & compRS < deciles(8),1) = 8;
normedRS(compRS >= deciles(8) & compRS < deciles(9),1) = 9;
normedRS(compRS >= deciles(9),1) = 10;
%% 

figure, hist(normedRS,50); title('Normed Composite') % look at your data
figure, hist(normedRS.^2,50); title('Normed Composite Squared') % look at your data squared

%% Output results.

Combined = [AUDIT_final(:,1), normedRS, normedRS.^2]; % Pairs subject numbers with RS scores. 
Composite_final_output = array2table(Combined(1:end,:),'VariableNames', {'Subject', 'Composite_Substance', 'Composite_Substance_Squared' });

name = ('Composite_Substance.xlsx');
fileoutput = [output_path, name];
writetable(Composite_final_output, fileoutput); % Save as csv file

end