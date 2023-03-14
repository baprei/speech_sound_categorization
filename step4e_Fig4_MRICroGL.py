import gl
HOMEDIR='/p01-hdd/dsa/baprei-srv/Documents/RDC_3011204_MVPA/analyses/secondlevel_MVPA_task_crossnobis_xclass_cv';
gl.loadimage(HOMEDIR+'/'+'ch2bet.nii')
gl.minmax(0, 45, 120)
gl.backcolor(255, 255,255)

gl.overlayloadsmooth(0)
gl.overlayload(HOMEDIR+'/'+'auditory_peaks_task_FDR_05_binarized.nii')
gl.minmax(1, 0, 1)
gl.colorname (1,"3blue")
gl.opacity(1,50)

gl.overlayloadsmooth(0)
gl.overlayload(HOMEDIR+'/'+'auditory_peaks_listening_FDR_05_binarized.nii')
gl.minmax(2, 0, 1)
gl.colorname (2,"7cool")
gl.opacity(2,65)

gl.overlayloadsmooth(0)
gl.overlayload(HOMEDIR+'/'+'MASK_INTERSECT_AUDIO_TASK.nii')
gl.minmax(3, 0, 1)
gl.colorname (3,"1red")
gl.opacity(3,80)

gl.overlayloadsmooth(0)
gl.overlayload(HOMEDIR+'/'+'MASK_INTERSECT_AUDIO_LISTENING.nii')
gl.minmax(4, 0, 1)
gl.colorname (4,"8redyell")
gl.opacity(4,85)