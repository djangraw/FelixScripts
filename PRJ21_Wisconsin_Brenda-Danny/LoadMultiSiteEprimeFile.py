# LoadMultiSiteEprimeFile.py

def LoadMultiSiteEprimeFile(inFile,encoding="utf-8"):
    # dfEprime = LoadMultiSiteEprimeFile(inFile)
    # -Reads in an EPrime data file from a Multi-Site ("Wisconsin") task, removing irrelevant lines.
    #
    # INPUTS:
    # -inFile is a string indicating an EPrime data file in the current path.
    # -encoding is a string indicating the encoding of the text files to be read in. If 'utf-16' doesn't work, try 'utf-8'.
    #
    # OUTPUTS:
    # -dfEprime is a pandas dataframe containing the relevant information.
    # 
    # Created 9/13/18 by DJ based on LoadPrrEprimeFile.
    
    # Import packages
    import pandas as pd
    import io
    import time
    
    # Set up
    print('Reading E-Prime file %s...'%inFile)
    t = time.time()
    
    # Read simple excel file
    dfEprime = pd.read_excel(inFile)
    
#     # Find header line (sometimes there's a comment line first)
#     iLine = -1
#     with io.open(inFile,encoding=encoding) as f:
#         line = ''
#         while 'ExperimentName' not in line:
#             iLine = iLine+1
#             line = f.readline()        
#     print('Header found in line %d.'%iLine) 
#     # Read in to pandas data frame
#     dfEprime = pd.read_table(inFile,encoding=encoding,skiprows=iLine-1,header=iLine)

#     # Crop to real trials
#     if "Procedure" in dfEprime.columns:
#         isRealTrial = dfEprime["Procedure"] == "ScanProc"
#     else:
#         isRealTrial = dfEprime["Procedure[ScanRun]"] == "ScanProc"
#     dfEprime = dfEprime[isRealTrial]
#     dfEprime = dfEprime.reset_index() # reset indices to match trial numbers
#     print('Cropped to %d trial lines.'%dfEprime.shape[0])
    print('Done! Took %f seconds.'%(time.time()-t))
   
    # return resulting dataframe
    return dfEprime
