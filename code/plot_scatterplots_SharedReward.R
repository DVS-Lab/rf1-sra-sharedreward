# set working directory
library("here")

# load packages
library("readxl")
library("ggplot2")
library("ggpubr")
library("reshape2")
library("emmeans")
library("hrbrthemes")
library("umx")
library("interactions")
library("car")
library("dplyr")

library (tidyverse)
library(rstatix)
library(reshape)
library(datarium)

setwd("C:/Users/tup54227/Documents/GitHub/istart-sharedreward/derivatives/")
maindir <- getwd()
datadir <- file.path("../derivatives/")

# import data
#here()
sharedreward <- read_excel("ppi_wholebrain_scatterplot.xls")
behavioral <- read_excel("ISTART-ALL-Combined-042122.xlsx")
postscan_ratings <- read.csv("df_psr.csv")
df_TPJ <- read_excel("df_TPJ.xlsx")
df_VS_ROI <- read_excel("VS_ROI_activation.xlsx")
df_VS_TPJ_ROI <- read_excel("VS-TPJ_ROI_connectivity.xlsx")
total <- inner_join(sharedreward, df_TPJ, by = "sub")
#srpr <- read.csv("../../istart/Shared_Reward/Behavioral_Analysis/SharedRewardPeerRatingsLongform.csv")


#Behavioral ratings and personality factors plot
Win_F_C <- lm(`Win_F_C` ~ RS + RS_square + SU + SUxRS + SUxRS_sq, data=postscan_ratings)
summary(Win_F_C)
scatter <- ggplot(data = postscan_ratings, aes(x=RS,
                                    y=`Win_F_C`))+
  geom_smooth(method=lm, formula = y ~ poly(x,2), level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed")+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))



# Shared Reward Model 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VS_substance_F_C <- lm(`VS_seed_F_C` ~ tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(VS_substance_F_C)
crModel <- crPlots(VS_substance_F_C,
                   smooth=FALSE,
                   pch=21, #shape of dot
                   col='black', #dot outline color
                   bg='blue', #unclear
                   col.lines='yellow', #trend line color
                   lwd=1,
                   grid=FALSE)

VS_substance_F_S <- lm(`VS_seed_F_S` ~ tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(VS_substance_F_S)
crPlots(VS_substance_F_S, smooth=FALSE)

# Friend v Computer, zstat 8 cluster (SU-neg) Ventral Striatum ppi seed
model1 <- lm(`ppi_c9_F-C_sub-neg_type-ppi_seed-VS_thr5_cope-09` ~ tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
summary(model1)
crPlots(model1, smooth=FALSE)

# Friend + Stranger v Computer, Cluster zstat 8 cluster 1 (SU-neg) Ventral Striatum ppi seed
model2 <- lm(`ppi_C10_FS-C_z8_sub-neg_cluster1_type-ppi_seed-VS_thr5_cope-10` ~ tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model2
crPlots(model2, smooth=FALSE)

# Friend + Stranger v Computer, zstat 8 cluster 2 (SU-neg) Ventral Striatum ppi seed
model3 <- lm(`ppi_C10_FS-C_z8_sub-neg_cluster2_type-ppi_seed-VS_thr5_cope-10` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model3
crPlots(model3, smooth=FALSE)

# Reward v Punishment with Friend v Computer, zstat 1 cluster (main effect) Ventral Striatum ppi seed
model4 <- lm(`ppi_C13_rew-pun_F-C_z1_main-effect_type-ppi_seed-VS_thr5_cope-13` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model4
summary(model4)
crPlots(model4, smooth=FALSE)

# Reward v Punishment with Friend v Computer, zstat 12 cluster 1 (SUxRS_square-neg) Ventral Striatum ppi seed
model5 <- lm(`ppi_C13_rew-pun_F-C_z12_su-rs2-neg_cluster1_type-ppi_seed-VS_thr5_cope-13` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model5
summary(model5)
crPlots(model5, smooth=FALSE)

# IMPORTANT -- VS-FFA Connectivity: Reward with Friend v Computer, zstat 1 cluster 1 (main effect) Ventral Striatum ppi seed
model6 <- lm(`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-16` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model6

scatter <- ggplot(data = total, aes(x=RS,
                                    y=`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-16`))+
  geom_smooth(method=lm, level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed",)+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))

#scatter <- ggplot(data = total, aes(x=SU,
#                                    y=`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-16`))+
#  geom_smooth(method=lm, level = 0.99, 
#              se=FALSE, fullrange=TRUE, linetype="dashed",)+
#  geom_point(shape=1,color="black")
#scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
#                                     panel.grid.minor = element_blank(), 
#                                     panel.background = element_blank(), 
#                                     axis.line =  element_line(colour="black"))

summary(model6)
      
      #checking if result exists in stranger v computer as well
model6b <- lm(`ppi_C16_rew_F-C_z1_main-effect_cluster1_type-ppi_seed-VS_thr5_cope-15_rew_S-C` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model6b
summary(model6b)

# Reward with Friend v Computer, zstat 1 cluster 2 (main effect) Ventral Striatum ppi seed
model7 <- lm(`ppi_C16_rew_F-C_z1_main-effect_cluster2_type-ppi_seed-VS_thr5_cope-16` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model7
crPlots(model7, smooth=FALSE)

# Reward with Friend v Stranger + Computer, zstat 1 cluster (main effect) Ventral Striatum ppi seed
model8 <- lm(`ppi_C21_rew_F-SC_z1_main-effect_type-ppi_seed-VS_thr5_cope-21` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model8
crPlots(model8, smooth=FALSE)

# IMPORANT -- Reward with Friend v Stranger + Computer, zstat 12 cluster (SUxRS_square-neg) Ventral Striatum ppi seed
model9 <- lm(`ppi_C23_rew-pun_F-SC_z12_su-rs2-neg_cluster3_type-ppi_seed-VS_thr5_cope-23` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model9
total$SU_qualifier <- cut(sharedreward$SU,
                          breaks = c(-2, 0, 6),
                          labels = c("low","high"))
total$SU_qualifier

  #VS-STS Rew-Pun for Friend v Str + Comp, moderated by SUxRS^2 interaction
scatter <- ggplot(data = total, aes(x=RS,
                                    y=`ppi_C23_rew-pun_F-SC_z12_su-rs2-neg_cluster3_type-ppi_seed-VS_thr5_cope-23`, 
                                    col = SU_qualifier))+
  geom_smooth(method=lm, formula = y ~ poly(x,2), level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed")+
  geom_point(shape=1,color="black")+
  scale_x_continuous(breaks = seq(-6, 6, by = 2))
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))

summary(model9)

# Reward with Friend v Computer, zstat 2 cluster 1 (substance use) activation model exploratory result
model10 <- lm(`act_C16_rew_F-C_z2_sub_cluster1_type-act_cope-16` ~
               tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model10
crPlots(model10, smooth=FALSE)

# Reward with Friend v Computer, zstat 2 cluster 1 (substance use) activation model exploratory result
model11 <- lm(`act_C16_rew_F-C_z2_sub_cluster2_type-act_cope-16` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model11
crPlots(model11, smooth=FALSE)

# Reward with Friend v Computer, zstat 2 cluster 1 (substance use) activation model exploratory result
model12 <- lm(`act_C16_rew_F-C_z2_sub_cluster3_type-act_cope-16` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model12
crPlots(model12, smooth=FALSE)


# Reward with Friend v Stranger, zstat 9 cluster 1 (reward sensitivity) activation model exploratory result
model13 <- lm(`act_C13_rew-pun_F-C_z9_rs-neg_cluster1_type-act_cope-13` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model13
crPlots(model13, smooth=FALSE)

# Reward with Friend v Stranger, zstat 9 cluster 2 (reward sensitivity) activation model exploratory result
model14 <- lm(`act_C13_rew-pun_F-C_z9_rs-neg_cluster2_type-act_cope-13` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model14
crPlots(model14, smooth=FALSE)

# Reward with Friend v Stranger, zstat 10 (reward sensitivity squared) activation model exploratory result
model15 <- lm(`act_C13_rew-pun_F-C_z10_rs2-neg_type-act_cope-13` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model15
crPlots(model15, smooth=FALSE)

# IMPORTANT - Reward with Friend v Stranger, zstat 2 (substance use) activation model exploratory result
model16 <- lm(`act_C14_rew_F-S_z2_sub_type-act_cope-14` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model16
summary(model16)

scatter <- ggplot(data = total, aes(x=SU,
                                    y=`act_C14_rew_F-S_z2_sub_type-act_cope-14`))+
  geom_smooth(method=lm, level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed",)+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))



ggplot(data = sharedreward, aes(x=SU,y=`ppi_C13_rew-pun_F-C_z12_su-rs2-neg_cluster1_type-ppi_seed-VS_thr5_cope-13`))+
  geom_smooth(aes(group = quant, color = quant), method = "lm", se = F)+geom_point()

ggplot(data = total, aes(x=SU,y=`pTPJ_R-P_F-S`))+
  geom_smooth(aes(group = quant, color = quant), method = "lm", se = F)+geom_point()

ggplot(data = total, aes(x=SU,y=`aTPJ_R-P_F-S`))+
  geom_smooth(aes(group = quant, color = quant), method = "lm", se = F)+geom_point()


model17 = lm(Rating ~ Trait * Partner, data=sharedreward)


#TPJ ROI multiple regressions

model18 <- lm(`aTPJ_R-P_F-C` ~
                          tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=total)
model18
crPlots(model18, smooth=FALSE)
summary(model18)

model19 <- lm(`aTPJ_R-P_F-S` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=total)
model19
crPlots(model19, smooth=FALSE)
summary(model19)

model20 <- lm(`pTPJ_R_F_S` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=total)
model20
crPlots(model20, smooth=FALSE)
summary(model20)

model21 <- lm(`pTPJ_R_P_F_S` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=total)
model21
scatter <- ggplot(data = total, aes(x=SU,
                                    y=`pTPJ_R_P_F_S`))+
  geom_smooth(method=lm, level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed",)+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))
summary(model21)
#reward vs punishment in social closeness condition is significant - t = 2.482, p = 0.0177


#VS exploratory results

#VS wholebrain finding F-S
model22 <- lm(`act_c14_VS-wholebrain_rew-F-S_zstat1_cluster1` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model22
summary(model22)

model23 <- lm(`act_VS-seed_11-rew-pun_F-S` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model23
summary(model23)
crPlots(model23, smooth=FALSE, grid=FALSE)
                #difference in VS activity for rew vs pun in friends vs strangers went down as reward sensitivity went up - p = 0.04717, t = -2.053
scatter <- ggplot(data = total, aes(x=RS,
                                    y=`act_VS-seed_11-rew-pun_F-S`))+
  geom_smooth(method=lm, level = 0.99, 
              se=FALSE, fullrange=TRUE, linetype="dashed",)+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))


model24 <- lm(`act_VS-seed_13-rew-pun_F-C` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model24
summary(model24)
crPlots(model24, smooth=FALSE, grid=FALSE)
                #difference in VS activity for rew vs pun in friends vs computers went down as substance use went up - p = 0.0271, t = -2.301

model25 <- lm(`act_VS-seed_14-rew_F-S` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model25
summary(model25)


model26 <- lm(`act_VS-seed_16-rew_F-C` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model26
summary(model26)

model27 <- lm(`act_VS-seed_21-rew_F-SC` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model27
summary(model27)

model28 <- lm(`act_VS-seed_23-rew-pun_F-SC` ~
                tsnr + fd_mean + RS + RS_square + SU + SUxRS + SUxRS_sq, data=sharedreward)
model28
summary(model28)
                 #difference in VS activity for rew vs pun in friends vs strangers & computers went down as substance use went up - p = 0.04945, t = -2.031


#ANOVA for VS_ROI - repeated measures
#model29 <- aov(Betas2 ~ Partner2, data = df_VS_ROI)
#summary(model29)

res.aov <- anova_test(
  data = df_VS_ROI, dv = Betas, wid = sub,
  within = c(Partner, Outcome)
)
get_anova_table(res.aov)

pair<-df_VS_ROI %>% 
  pairwise_t_test(Betas~Partner2,paired=TRUE, p.adjust.method = "bonferroni" ) 
data.frame(pair)

#ANOVA for VS_TPJ_ROI - repeated measures
#model30 <- aov(Betas ~ Partner + Outcome, data = df_VS_TPJ_ROI)
res.aov <- anova_test(
  data = df_VS_TPJ_ROI, dv = Betas, wid = sub,
  within = c(Partner, Outcome)
)
get_anova_table(res.aov)

pwc <- df_VS_TPJ_ROI %>%
  group_by(Outcome) %>%
  pairwise_t_test(
    Betas ~ Partner, paired = TRUE,
    p.adjust.method = "bonferroni"
  )
data.frame(pwc)