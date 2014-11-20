This code implements our baseline algorithm for RGBD tracking benchmark. 
Project website: http://rgbdtrack.csail.mit.edu/

Platform:

	We have only tested our code on Linux 64-bit with MATLAB R2011a.

Citation:

	Please cite our paper if you use this code:

	Shuran Song and Jianxiong Xiao. Tracking Revisited using RGBD Camera: Baseline and Benchmark. 2013.

Demo:

	Just run runRGBDtracker.m in Matlab.

Test on a new sequence:

	1. set the source.directory to the folder contains rgbd image data. 
	(e.g './data/', for more data and detailed description can be find here:http://rgbdtracker.csail.mit.edu/dataset ) 
	2. Initialize the position in the first frame in ./data/init.txt; if init.txt is not found in ./data, user is required to defined the bounding box by clicking at the first frame.
	The setup has the format  [x y width height]  where x,y are the coordinate of left top point of the rectangle.
	3. run runRGBDtracker.m

Parameters:

	1. The parameters in the function runRGBDtracker.m can be tuned as follows
	 
	control.detectionMode:   different feature type for detection 'rgb' or 'd' or 'rgbd' 
	control.enableRecenter   whether to enable target bounding box using recenter
	control.occlusionhandle: whether to enable occlusion handling 
	control.enableLearning:  whether to enable on-line target model updating
	control.enableOF:        whether to enable optical flow 
	 
	2. Display and output 
	 
	control.showtarlist: whether to display the target candidate list when occlusion happen
	control.showResult:  whether to display the final tracking result 
	control.debug:       whether to display segmentation result and histogram
	control.filterRGB:   whether to display the rgb image after segmentation by depth
	 
	 
	control.savevideo:     whether to save the tracking result as .avi 
	outputpath: the path to save tracking result
	seqence_name.txt format: one line for one frame starting from first frame [x1,y1,x2,y2,state]
	seqence_name.mat contains: resultBBs (result bounding box), resultState , resultConfs, resultOccBBs (bounding box for occluder), control (user inputs)
	 
	More details about output format and evaluation methods can be found here: http://rgbdtrack.csail.mit.edu/eval


Libraries:
 
	Our software uses code from the code that are publicly available from the following websites. For the easy installation, we also include their code in our package. Please refer to the original packages for their copyright and license agreement. 

	1. HOG feature:
	P. Felzenszwalb, D. McAllester, D. Ramanan, A Discriminatively Trained, Multiscale, Deformable Part Model
	http://people.cs.uchicago.edu/~rbg/latent/
	 
	2. Optical flow:
	Thomas Brox, J. Malik, Large displacement optical flow: descriptor matching in variational motion estimation
	http://lmb.informatik.uni-freiburg.de/Publications/2011/Bro11a/
	 
	3. SVM: 
	O. Chapelle, Training a Support Vector Machine in the Primal, Neural Computation, in press.
	http://olivier.chapelle.cc/primal/

License:

	This software is under Open Source MIT License.

	The MIT License (MIT)
	Copyright (c) 2013 Shuran Song and Jianxiong Xiao

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
