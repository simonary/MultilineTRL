# MultilineTRL
A tool for performing multiline TRL calibration, based on Matlab and with GUI.

# Screenshoot
![alt tag](https://raw.githubusercontent.com/simonary/MultilineTRL/master/MatlabApp/screenshot.png)

# Usage
1. Run .\MatlabApp\MultiLineTRL.mlappinstall to install it as an application in Matlab, or
2. Run .\code\main.m directly.

# Note
0. Tested on Matlab R2013a.
1. Check .\CalKit_example to see how to write the configuration files.
2. For the present only OPEN or SHORT type REFLECT standard is supported.
3. Click the 'Ref. Plane Shift' button if you want to shift the reference planes of the calibration results. A positve/negative distance indicates an inward/outward shift.
4. In .\Verification an example is provided for the verification of this tool. All the results are simulated by HFSS and a 'virtual' de-embedding can be performed.

# Reference
[1] R. B. Marks, “A multiline method of network analyzer calibration,” IEEE Trans. Microw. Theory Techn., vol. 39, no. 7, pp. 1205–1215, Jul. 1991.