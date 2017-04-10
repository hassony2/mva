#include <iostream>
#include <list>

#include "Features.h"

using namespace std;

extern "C" {
#include "vl/sift.h"
}

namespace Imagine {

	Array<SIFT> SIFTDetector::run(const Image<byte>& I) const {
		
		int w=I.width(),h=I.height();
		Image<float,2> If(I);

		VlSiftFilt *filt=vl_sift_new (w,h,numOctaves,numScales,firstOctave);
		if (edgeThresh >= 0)
            vl_sift_set_edge_thresh (filt, edgeThresh) ;
		if (peakThresh >= 0)
            vl_sift_set_peak_thresh (filt, 255*peakThresh/numScales) ;

		list<SIFT> L;
        vl_sift_process_first_octave (filt, If.data());
		while (true) {
			vl_sift_detect (filt) ;

			VlSiftKeypoint const *keys  = vl_sift_get_keypoints     (filt) ;
			int nkeys = vl_sift_get_nkeypoints (filt) ;
			for (int i=0;i<nkeys;++i) {
				double angles [4];
				int	nangles=vl_sift_calc_keypoint_orientations(filt,angles,keys+i) ;

				for (int q=0 ; q < nangles ; ++q) {
					vl_sift_pix descr[128] ;
					vl_sift_calc_keypoint_descriptor(filt,descr, keys+i, angles [q]) ;
					SIFT fp;
					fp.pos=FloatPoint2(keys[i].x,keys[i].y);
					fp.scale=keys[i].sigma;
					fp.angle=float(angles[q]);
					for (int k=0;k<128;k++)
						fp.desc[k]=byte(512*descr[k]);
					L.push_back(fp);
				}
			}
			if (vl_sift_process_next_octave(filt))
				break; // Last octave
		}
		vl_sift_delete(filt);
		return(Array<SIFT>(L));
	}


}
