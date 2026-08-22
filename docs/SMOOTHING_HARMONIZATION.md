# Smoothness harmonization

Historical 5- and 6-mm FEAT settings are not the production target. Phase 0 measures the exact unsmoothed analysis inputs and evaluates feasible common targets before any target is selected.

`3dFWHMx -ShowMeClassicFWHM -detrend -acf NULL` records both classic Gaussian axis/combined values and ACF model parameters/effective FWHM. `3dBlurToFWHM -FWHM` targets the classic 3D resolution-element metric, stopping when `cbrt(FWHMx * FWHMy * FWHMz)` reaches the requested value. Therefore candidate feasibility, blur targeting, and achieved-target verification use `classic_fwhm_combined`. ACF effective FWHM is recorded as a complementary description and must not be substituted silently.

Every AFNI invocation runs in a unique `mktemp` work directory. This prevents parallel jobs from colliding on default `3dFWHMx.1D*` artifacts. `AFNI_OMP_NUM_THREADS` defaults to 4 so an outer batch runner, rather than each AFNI command, controls total machine use.

Workflow:

1. audit the RF1 grid and create the zero-valued reference resource;
2. measure RF1 pre-blur BOLD smoothness;
3. modern-preprocess ds003745, then measure it before and after RF1-grid resampling;
4. use `propose_smoothing_targets.py` to report distributions and infeasible runs;
5. pilot several candidates on a balanced subset;
6. compare achieved classic and ACF estimates, tSNR, coverage, and runtime;
7. recommend a target, stop, and obtain explicit approval;
8. export `TARGET_FWHM_MM` only after approval.

The utilities never overwrite their input. Output filenames must encode the requested target. FEAT templates use `fmri(smooth) = 0` to avoid double smoothing.

Reference: [AFNI `3dBlurToFWHM` program help](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dBlurToFWHM.html) and [AFNI `3dFWHMx` program help](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dFWHMx.html).
