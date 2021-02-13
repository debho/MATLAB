
# BORIS-Ephys Tools
[BORIS User Guide](https://boris.readthedocs.io/en/latest/)

### Exporting from BORIS:
1. Use "as behaviors binary table"
2. Use 1-second intervals for now
3. Export as .csv

*Always include the date in filenames as YYYYMMDD

**Extracting Binary Behaviors**

`[behNames,behTime,behExtract,extractedLabels,binBeh] = extractBinaryBehaviors(filename,true);`

* If second parameter `doPlot` is true, it will plot an overview figure and save it as a PNG.

---
### Stuff I figured out:
- How to extract data by type
- Creating power spectrum and spectrogram

### Open Issues:
- I'm not sure if I plotted the power spectra correctly
- Can't seem to work spectrogram code --> I think this is where I need help getting the data into 5-sec bins
