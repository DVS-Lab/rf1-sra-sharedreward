function plot_sharedreward(name, roidir, rois, models, R_Friend, R_Stranger, R_Computer, P_Friend, P_Stranger, P_Computer, type)
    
% This function plots results in the ISTART ugdg task. It employs DVS
% plotting tool barweb_dvs2.m. This code generates the inputs to make the
% plots and scatter plots for this project.

% Daniel Sahin
% 03/31/2022
% Temple University
% DVS Lab

close all
clc

% import mlreportgen.ppt.* 
% 
% ppt = Presentation(name '.pptx');
% titleSlide = add(ppt, 'Title Slide');
% replace(titleslide, 'Title', name);
% pictureslide = add(ppt, 'Title and Picture');

    output = [roidir '/results/' name];
    
    if exist(output) == 7
        rmdir(output, 's');
        mkdir(output);
    else 
        mkdir(output); % set name
    end
    
    % Make a file for test results
    outputdir = [roidir '/results/' name '/'];
    file = ([roidir '/results/' name '/' name]);
    [L] = isfile(file);
    if L == 1
        delete(file)
    end
    
    diary(file)
    
    % loop through rois
  
    diary on
    
    for r = 1:length(rois)
        roi = rois{r};
        
        for m = 1:length(models)
            model = models{m};
            
            R_F = load(strjoin([roidir,roi,model,R_Friend], ''));
            R_S = load(strjoin([roidir,roi,model,R_Stranger], ''));
            R_C = load(strjoin([roidir,roi,model,R_Computer], ''));
            P_F = load(strjoin([roidir,roi,model,P_Friend], ''));
            P_S = load(strjoin([roidir,roi,model,P_Stranger], ''));
            P_C = load(strjoin([roidir,roi,model,P_Computer], ''));
            
            reward = [R_F R_S R_C];
            punish = [P_F P_S P_C];
            figure, barweb_dvs2([mean(reward); mean(punish)],[std(reward)/sqrt(length(reward)); std(punish)/sqrt(length(punish)) ])
            xlabel('Task Condition');
            xticks([0.63, 0.92, 1.21, 1.69, 1.98, 2.27]);
            xticklabels({'R_F','R_S','R_C','P_F','P_S','P_C'});
            ylabel('BOLD Response');
            %legend({'DGP', 'UGP', 'UGR'},'Location','northeast');
            axis square;
            title([roi type]);
            outname = fullfile([outputdir roi model]);
            cmd = ['print -depsc ' outname];
            eval(cmd);
            saveas(gca, fullfile(outname), 'svg');
            
            % Two factor ANOVA on reward and punishment vs friend,
            % stranger, and computer
            Reward = [R_F, R_S, R_C]
            Punishment = [P_F, P_S, P_C]
            sample = 45
            disp([roi ' R_F, R_S, and R_C difference?'])
            matrix = [Reward; Punishment]
            [~,~,stats]=anova2(matrix, sample)
            [p,tb1,stats]=anova1([R_F,R_S,R_C])

            % different from zero?
%             disp([roi ' Reward with Friend different from zero?'])
%             [h,p,ci,stats] = ttest(R_F)
%             disp([roi ' Reward with Stranger different from zero?'])
%             [h,p,ci,stats] = ttest(R_S)
%             disp([roi ' Reward with Computer different from zero?'])
%             [h,p,ci,stats] = ttest(R_C)
%             
%             % Different from each other (R_F and R_S only)?
%             disp([roi ' Reward with Friend > Reward with Stranger?'])
%             [h,p,ci,stats] = ttest(R_F, R_S)
%             
%              % Different from each other (R_F and R_C only)?
%             disp([roi ' Reward with Friend > Reward with Computer?'])
%             [h,p,ci,stats] = ttest(R_F, R_C)
%             

            % Multiple regression
            %tb1 = [R_F,R_S,R_C,P_F,P_S,P_C];
            %md1 = fitlm(tb1,'')
            
        end  
    end
    
diary off
end

