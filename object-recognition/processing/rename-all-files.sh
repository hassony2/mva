for dir in /mnt/d/Cours-MVA/ObjRecProjet/ArrowDataAll/*/ 
do
	dir=${dir%*/}	    
	echo ${dir##*/}
	rename ${dir}/im0000 ${dir}/image_ ${dir}/im0000*
	cd ${dir}
	pwd
	rename .jpeg .jpg *.jpeg
	cd ..
done
