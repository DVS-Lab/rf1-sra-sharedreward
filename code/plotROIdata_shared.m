clear
close all;
clc

% Ori Zaff
% Adapted from D.Smith's code in r21-cardgame
% ISTART
% 03/23/21
% DVS Lab
% Temple University

% This code plots ROIs for the Shared Reward task.

% set up dirs

codedir = '/ZPOOL/data/projects/rf1-sra-sharedreward/code'; % Run code from this path.
addpath(codedir)
maindir = '/ZPOOL/data/projects/rf1-sra-sharedreward';
roidir = '/ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/imaging_plots/'; % Results from extractROI script.
resultsdir = '/ZPOOL/data/projects/rf1-sra-sharedreward/derivatives/imaging_plots/results/'; % Output where results will be saved.

rois =  {'mask81017'}; %{'seed-VS_thr5'}; %{'act_C14_rew_F-S_z2_sub'} %{'resampled_pTPJ-thr50-2mm'}; %{'act_C14_rew_F-S_z1_main_cluster2'}; %{'resampled_aTPJ-thr50-2mm' 'resampled_pTPJ-thr50-2mm'}; % 'target-pcc_bin' 'target-vmPFC_bin'}; %'seed-VS_thr5' 'seed-vmPFC-5mm-thr' 'seed-mPFC-thr' %'ppi_C10_FS-C_z8_sub-neg_cluster1' 'ppi_C23_rew-pun_F-SC_z12_sub-neg_cluster3'} 
models = {'_type-act_'}; %{'_type-act_'};%

% Test hypotheses:

H1 = 1; 

%% H1

if H1 == 1

name = 'Act_Result';%'Act_Result'; %
mean_use = {'cope-30.txt'};
plot_sharedreward_simple(name,roidir, rois, models,mean_use)  ;


end


% if H3 == 1
% 
%         name = 'PPI_Result';%'Act_Result'; %
%         R_Friend = {'cope-04.txt'};
%         R_Stranger = {'cope-06.txt'};
%         R_Computer = {'cope-02.txt'};
%         P_Friend = {'cope-03.txt'};
%         P_Stranger = {'cope-05.txt'};
%         P_Computer = {'cope-01.txt'};
% 
% 
%         type= ' ppi';%' act';
%         plot_sharedreward(name, roidir, rois, models, R_Friend, R_Stranger, R_Computer, P_Friend, P_Stranger, P_Computer, type)  
% end