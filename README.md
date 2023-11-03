# Sandra_Segura_Bayona_Diana
Todd Fallesen, CALM Facility, April 27 2022
 Diana colocolization project

This is a project to do segmentation and colocalization using FIJI.
To run the segmentation script, you need to have CSBDeep and StarDist plugins installed on FIJI. 
To run the coloc_script you need to have CSBDeep, 3D Imagining Suite and Diana installed on your computer.

The Diana paper can be found at : https://pubmed.ncbi.nlm.nih.gov/27890650/

The Diana_1.49b.jar needs to be installed in the plugins directory, it can be got from:
https://imagej.net/plugins/distance-analysis
or from this repo

# Usage
Run Sandra_Segmentation.ijm first. This script is to find the nuclei in each image in the dapi channel, and save a crop of each nuclei into a folder. Upon running the script, a dialog box will pop up asking you to specify the input directory where the inital images are, an output directory where you will save the segmented nuclei, the suffix of the file (can be any bioformats openable image) and the DAPI Channel.  This script uses stardist to do the segmentation. If the nuceli are too broken up, you may have to adjust the size of the stardist parameters on line 50.

Run __Sandra_Coloc.ijm__ second. Upon running, you will get a dialog box which will ask for an input directory, which is the output directory from the previous script. You will then be asked to specify which channel is your DAPI, which channel is your Teleomeres, and then up to two more channels. You do not have to have all marker channels, you can specify "none".
The output of this will be saved into the "Results folder" you specify in the dialog box.
