function WriteFcToSumaFiles(FC,atlas,outPrefix,convertDset)

% Created 10/19/16 by DJ.




if convertDset
% cmd1 = 'ConvertDset -i M.1D -o_niml_asc -prefix M_mat -add_node_index -graph_named_nodelist_txt ../../ALL.CA3.MNI.SUMAnames ''../../ALL.CATLAS0100/CATLAS0100_rALL_sL18S3.MNI.SUMAnodes[1,2,3]'' -graphizeTLAS0100/CATLAS0100_rALL_sL18S';
% system(cmd1);
end

% cmd2 = 'suma -spec /data/SFIMJGC/Apps/SumaSufraces/suma_MNI_N27/MNI_N27_both.spec -sv /data/SFIMJGC/Apps/SumaSufraces/suma_MNI_N27/MNI_N27_SurfVol.nii -input M_mat.niml.dset'; 
% system(cmd2);



