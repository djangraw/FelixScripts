# LoadMultiSiteEprimeFile.py

def LoadMultiSiteEprimeFile(inFile,encoding="utf-8"):
    # dfEprime = LoadMultiSiteEprimeFile(inFile)
    # -Reads in an EPrime data file from a Multi-Site ("Wisconsin") task, removing irrelevant lines.
    #
    # INPUTS:
    # -inFile is a string indicating an EPrime data file in the current path, or a list, or a glob (with * character).
    # -encoding is a string indicating the encoding of the text files to be read in. If 'utf-16' doesn't work, try 'utf-8'.
    #
    # OUTPUTS:
    # -dfEprime is a pandas dataframe containing the relevant information.
    # 
    # Created 9/13/18 by DJ based on LoadPrrEprimeFile.
    # Updated 10/11/18 by DJ - switched to new exported data format (csv file with 1 header line), allow list or glob inputs
    
    # Import packages
    import pandas as pd
    import io
    import time
    import glob
    
    # Set up
#     print('Reading E-Prime file %s...'%inFile)
    t = time.time()
    
    if "*" in inFile:
        inFile = glob.glob(inFile)
        inFile.sort()
        
    if isinstance(inFile, (list,)):
        print('Reading E-Prime file %s...'%inFile[0])
        dfEprime = pd.read_csv(inFile[0],header=1,delimiter="\t") # load first file
        for i in range(1,len(inFile)): # add all the others
            print('Appending E-Prime file %s...'%inFile[i])
            dfEprime = dfEprime.append(pd.read_csv(inFile[i],header=1,delimiter="\t"),ignore_index=True);
    else:    # Read single csv file
        print('Reading E-Prime file %s...'%inFile)
        dfEprime = pd.read_csv(inFile,header=1,delimiter="\t");
    
#     dfEprime = pd.read_excel(inFile) # the old way, with excel-style formatting
    
    print('Done! Took %f seconds.'%(time.time()-t))
   
    # return resulting dataframe
    return dfEprime
