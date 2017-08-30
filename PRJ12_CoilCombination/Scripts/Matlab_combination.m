
%%%%%%%%%%% USER PARAMETERS %%%%%%%%%%%
addpath('/Users/huberl/Documents/MATLAB/NIfTI_20140122/');



data_dir = '/Users/huberl/Dropbox/NIH/Matlab_coil_combine/uncombined_data' ;
result_dir = '/Users/huberl/Dropbox/NIH/Matlab_coil_combine/matlab_results' ;

for ic=1:31
    read_name_c(ic) = '1.nii' ;
end;

 read_name = '1.nii' ;
%%%%%%%%%%% END OF USER PARAMETERS %%%%%%%%%%%

read_file = fullfile(data_dir,read_name) ;
read_nii = load_untouch_nii(read_file) ;

% get dimensions
[phase_dim,read_dim,slice_dim,t_dim]=size(read_nii.img)


read_nii = double(read_nii.img(:,:,:));

     for ix=1:phase_dim
          for iy=1:read_dim
              for islice = 1:slice_dim
                  if (read_nii(ix,iy,islice,1)<0)
                    read_nii(ix,iy,islice,1) = 0 ;
                  end; 
              end   
          end
      end;


write_nii = make_nii(read_nii) ;
write_file = fullfile(result_dir, 'output_file.nii') ;
save_nii(write_nii, write_file) ;





