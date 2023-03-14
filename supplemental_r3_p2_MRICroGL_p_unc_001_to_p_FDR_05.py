import gl
HOMEDIR='/p01-hdd/dsa/baprei-srv/Documents/RDC_3011204_MVPA/analyses/secondlevel_supplemental_MVPA_task_crossnobis_cv';
gl.loadimage(HOMEDIR+'/'+'ch2bet.nii')
gl.minmax(0, 45, 120)
gl.backcolor(255, 255,255)

gl.overlayloadsmooth(0)
gl.overlayload(HOMEDIR+'/'+'SnPM_thresholded_p_unc_001.nii')
gl.minmax(1, 4, 5.3)
gl.colorname (1,"surface")
gl.opacity(1,90)

