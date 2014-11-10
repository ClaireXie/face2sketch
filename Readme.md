This code is the matlab implementation of the following paper:
X Wang, X Tang, "Face photo-sketch synthesis and recognition", T-PAMI 2009

How to Use the Code
==================================================
1. To run the code, you need to first download the face sketch database in
http://mmlab.ie.cuhk.edu.hk/archive/facesketch.html. In the dataset, for each face, there is a sketch drawn by an artist based on a photo with pre-computed landmark information. 

2. After you collect the dataset, change the parameters in the beginning according to your folder structure.

3. Simple run p2s.m script and it will perform the photo2sketch synhtesis for all the images in the dataset.

==================================================
It should be noted, that the code is a generalization of the MRF framework. The code can be slightly modified to any algorithm that uses the 2-D MRF framework as optimization. 

If you have any questions, please feel free to contact xjsjtu88@gmail.com