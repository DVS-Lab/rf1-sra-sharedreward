# Smoothness harmonization

The production target is **6 mm total measured classic FWHM**, approved on 2026-08-23 after complete RF1/ds003745 characterization. This decision does not inherit the historical nominal FEAT kernels, and it does not apply an additional 6-mm Gaussian kernel.

`3dFWHMx -ShowMeClassicFWHM -detrend -acf NULL` records both classic Gaussian axis/combined values and ACF model parameters/effective FWHM. `3dBlurToFWHM -FWHM` targets the classic 3D resolution-element metric, stopping when `cbrt(FWHMx * FWHMy * FWHMz)` reaches the requested value. Therefore candidate feasibility, blur targeting, and achieved-target verification use `classic_fwhm_combined`. ACF effective FWHM is recorded as a complementary description and must not be substituted silently.

Every AFNI invocation runs in a unique `mktemp` work directory. This prevents parallel jobs from colliding on default `3dFWHMx.1D*` artifacts. `AFNI_OMP_NUM_THREADS` defaults to 4 so an outer batch runner, rather than each AFNI command, controls total machine use.

Decision evidence:

1. all 865 baseline characterization units were complete;
2. the 100 ds003745 runs were placed on the RF1 grid with identity-transform `wsinc5` interpolation;
3. analysis-ready classic-FWHM means were 3.727 mm for ds003745 and 3.546 mm for RF1;
4. the maximum classic FWHM was 4.019 mm for ds003745 and 4.619 mm for RF1, so all 765 analysis-ready runs can be blurred upward to 6 mm;
5. 6 mm is approximately twice the 2.7–2.97 mm voxel dimensions and provides a common target despite expected anatomical heterogeneity across younger and older adults;
6. the target stays at the upper acceptable bound to protect spatial specificity in small regions such as ventral striatum.

Production workflow:

1. smooth each run to 6 mm inside its corresponding fMRIPrep whole-brain mask;
2. measure achieved classic and ACF smoothness for every output;
3. require complete outputs and review achieved-target deviations before FEAT;
4. keep FEAT spatial smoothing disabled.

The utilities never overwrite their input. Output filenames must encode the requested target. FEAT templates use `fmri(smooth) = 0` to avoid double smoothing.

Reference: [AFNI `3dBlurToFWHM` program help](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dBlurToFWHM.html) and [AFNI `3dFWHMx` program help](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dFWHMx.html).
