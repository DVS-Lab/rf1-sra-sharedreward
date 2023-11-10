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

setwd("C:/Users/tup54227/Documents/GitHub/rf1-sra-sharedreward/derivatives")
maindir <- getwd()

behavior <- read_csv("df_behavior_sfn.csv")


FvSreg <- lm(`win-lose-diff-FS` ~ age_demeaned + oafem_total + `ios_f-s` + ageXoafem	+	`ageXios_f-s`	+ `oafemXios_f-s` +	`ageXoafemXios_f-s`, data=behavior)
summary(FvSreg)
crModel <- crPlots(FvSreg,
                   smooth=FALSE,
                   pch=21, #shape of dot
                   col='black', #dot outline color
                   bg='grey', #unclear
                   col.lines='black', #trend line color
                   lwd=1,
                   grid=FALSE)


FvCreg <- lm(`win-lose-diff-FC` ~ age_demeaned + oafem_total + `ios_f-c` + ageXoafem	+	`ageXios_f-c`	+ `oafemXios_f-c` +	`ageXoafemXios_f-c`, data=behavior)
summary(FvCreg)
crModel <- crPlots(FvCreg,
                   smooth=FALSE,
                   pch=21, #shape of dot
                   col='black', #dot outline color
                   bg='grey', #unclear
                   col.lines='black', #trend line color
                   lwd=1,
                   grid=FALSE)



scatter <- ggplot(data = behavior, aes(x=age_demeaned,
                                               y=`win-lose-diff-FC`))+
  geom_smooth(method=lm, level = 0.99, 
              se=TRUE, fullrange=TRUE, color="black")+
  geom_point(shape=1,color="black")
scatter + scale_color_grey() + theme(panel.grid.major = element_blank(), 
                                     panel.grid.minor = element_blank(), 
                                     panel.background = element_blank(), 
                                     axis.line =  element_line(colour="black"))
ggsave(
  "../derivatives/Figures/RS_behavioral_win_friendcomp.svg",
  plot = scatter, bg = "white")