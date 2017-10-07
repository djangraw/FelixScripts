function CopyRawSrttDataToPrcsData(subjects)

for i=1:numel(subjects)
    subjstr = sprintf('tb%04d',subjects(i));
    
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/anat',subjstr));
    
end