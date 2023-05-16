#!/bin/bash

cd ../derivatives/fsl

for sub in 1001 1002 1003 1004 1006 1007 1009 1010 1011 1012 1013 1015 1016 1019 1021 1242 1243 1244 1248 1249 1251 1253 1255 1276 1282 1286 1294 1300 1301 1302 1303 3101 3116 3122 3125 3140 3143 3152 3164 3166 3167 3170 3173 3175 3176 3186 3189 3190 3199 3200 3206 3210 3212 3218 3220; do
	mv sub-${sub}/L1_task-sharedreward_model-2_type-ppi_seed-VS_thr5_run-1_sm-6.feat sub-${sub}/L1_task-sharedreward_model-3_type-ppi_seed-VS_thr5_run-1_sm-6.feat
	mv sub-${sub}/L1_task-sharedreward_model-2_type-ppi_seed-VS_thr5_run-2_sm-6.feat sub-${sub}/L1_task-sharedreward_model-3_type-ppi_seed-VS_thr5_run-2_sm-6.feat
done