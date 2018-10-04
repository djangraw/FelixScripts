# MakeMultiSiteTimingFiles.py

def MakeTimingFiles(eprimeFile,outputFolder,subtractVal=0):
    # MakeTimingFiles(eprimeFile,outputFolder)
    # -Reads in an EPrime data file from a Multi-site ("Wisconsin") experiment and produces .1D files for stimulus and
    #  cue timing of various trial types.
    # 
    # INPUTS:
    # -eprimeFile is a string indicating an EPrime data file in the current path.
    # -outputFolder is a string indicating the path where the resulting timing files should be saved.
    # -subtractVal is an integer indicating the time in seconds that should be subtracted from each time.
    #
    # Created 9/13/18 by DJ based on MakePrrTimingFiles.py.
    # Updated 9/27/18 by DJ - added O#pics, X#pics, cue#pics, and missedHouse 1D file options.
    # Updated 10/3/18 by DJ - added PostCue# 1D file options, consolidated code for options with #s
    
    # Import packages
    from LoadMultiSiteEprimeFile import LoadMultiSiteEprimeFile
    import pandas as pd
    import numpy as np
    import time
    import os
    
    # Get start time
    t = time.time()
    
    # Declare trial types to serve as output files
    blocks = ['Rew','Pun']
    phases = ['Acq','Rev']
    displays = ['stim','feedback']
    types = [['correct','incorrect',''],['pos','neg','']]
    
    # Read in to pandas data frame
    dfEprime = LoadMultiSiteEprimeFile(eprimeFile)

    # Get runs/trials
    nRows = dfEprime.shape[0]
    isNewTrial = np.not_equal(dfEprime.loc[1:,'Trial'].values, dfEprime.loc[:nRows-2,'Trial'].values)
    isNewTrial = np.insert(isNewTrial,0,True)
    isNewRun = np.less(dfEprime.loc[1:,'Trial'].values, dfEprime.loc[:nRows-2,'Trial'].values)
    isNewRun = np.insert(isNewRun,0,True)
    iRun = np.cumsum(isNewRun)
    nRuns = iRun[-1]

    # Add run column to dfEprime and reindex
    dfEprime['Run'] = iRun
    # Set index keys to be run and trial (careful, there are >1 row with each key!)
    dfEprime = dfEprime.set_index(['Run','Trial'])

    # Initialize timing dataframe
    dfTimes = pd.DataFrame()
    dfTimes['cueType'] = dfEprime.loc[isNewTrial,'Cue']
    dfTimes['cueTime'] = dfEprime.loc[isNewTrial,'warning.OnsetTime'] - dfEprime.loc[isNewTrial,'WaitforTTL.RTTime']

    # Get times of - and + faces
    dfTimes['negFaceTime'] = dfEprime.loc[isNewTrial,'negFace.OnsetTime'] - dfEprime.loc[isNewTrial,'WaitforTTL.RTTime']
    dfTimes['posFaceTime'] = dfEprime.loc[isNewTrial,'posFace.OnsetTime'] - dfEprime.loc[isNewTrial,'WaitforTTL.RTTime']

    # Get times of Houses
    isOkRow = pd.notnull(dfEprime['house.OnsetTime'])
    dfTimes['houseTime'] = dfEprime.loc[isOkRow,'house.OnsetTime'] - dfEprime.loc[isOkRow,'WaitforTTL.RTTime']
    dfTimes['houseResp'] = dfEprime.loc[isOkRow,'house.RESP'] 
    
    # Get times and durations of ITI1
    dfTimes['Iti1Time'] = dfEprime.loc[isNewTrial,'ITI1.OnsetTime'] - dfEprime.loc[isNewTrial,'WaitforTTL.RTTime']
    dfTimes['Iti1Dur'] = dfEprime.loc[isNewTrial,'ITI1.OnsetToOnsetTime'] 
    # OnsetToOnsetTime is better than offset-onset, which subtracts preRelease, and duration, which is a parameter and not a record.
    
    # convert times from ms to s
    dfTimes.loc[:,'cueTime':] = dfTimes.loc[:,'cueTime':]/1000
    
    
    # Nested Loops for each trial type
    types = ['AllOpics.1D','AllXpics.1D','O_UnExp.1D','X_UnExp.1D','House.1D',
             'Ambiguity.1D','Certainty.1D','Threat.1D',
             'O0pics.1D','O25pics.1D','O50pics.1D','O75pics.1D',
             'X25pics.1D','X50pics.1D','X75pics.1D','X100pics.1D',
             'cue0.1D','cue25.1D','cue50.1D','cue75.1D','cue100.1D',
             'PostCue0.1D','PostCue25.1D','PostCue50.1D','PostCue75.1D','PostCue100.1D']
    for trialType in types:
        print(trialType)
        # Declare output filename
        outFile = trialType
        
        # Narrow down trials
        useDur = False # False for all except ITI1
        useAmp = False
        if trialType=='AllOpics.1D':
            times = dfTimes['posFaceTime']
            isOkTrial = pd.notnull(times)
        elif trialType == 'AllXpics.1D':
            times = dfTimes['negFaceTime']
            isOkTrial = pd.notnull(times)
        elif trialType=='House.1D':
            times = dfTimes['houseTime']
            isOkTrial = pd.notnull(times)
        elif trialType=='O_UnExp.1D': 
            times = dfTimes['posFaceTime']
            amps = dfTimes['cueType']/25
            isOkTrial = pd.notnull(times) & (dfTimes['cueType']>0)
            useAmp = True
        elif trialType=='X_UnExp.1D': 
            times = dfTimes['negFaceTime']
            amps = (100-dfTimes['cueType'])/25
            isOkTrial = pd.notnull(times) & (dfTimes['cueType']<100)
            useAmp = True
        elif trialType=='Ambiguity.1D': 
            times = dfTimes['cueTime']
            amps = (50-np.abs(dfTimes['cueType']-50))/25
            isOkTrial = (dfTimes['cueType']>0) & (dfTimes['cueType']<100)
            useAmp = True
        elif trialType=='Certainty.1D': 
            times = dfTimes['cueTime']
            isOkTrial = (dfTimes['cueType']==0) | (dfTimes['cueType']==100)
        elif trialType=='Threat.1D': 
            times = dfTimes['cueTime']
            amps = dfTimes['cueType']/25
            isOkTrial = (dfTimes['cueType']>0)
            useAmp = True
        elif trialType=='MissedHouse.1D':
            times = dfTimes['houseTime']
            isOkTrial = pd.notnull(times) & (dfTimes['houseResp']=="")
        elif trialType.startswith('O'):
            cueNum = int(trialType[len('O'):-len('pics.1D')]);
            times = dfTimes['posFaceTime']
            isOkTrial = pd.notnull(times) & (dfTimes['cueType']==cueNum)
        elif trialType.startswith('X'):
            cueNum = int(trialType[len('X'):-len('pics.1D')]);
            times = dfTimes['negFaceTime']
            isOkTrial = pd.notnull(times) & (dfTimes['cueType']==cueNum)
        elif trialType.startswith('cue'):
            cueNum = int(trialType[len('cue'):-len('.1D')]);
            times = dfTimes['cueTime']
            isOkTrial = pd.notnull(times) & (dfTimes['cueType']==cueNum)
        elif trialType.startswith('PostCue'):
            cueNum = int(trialType[len('PostCue'):-len('.1D')]);
            times = dfTimes['Iti1Time']
            durs = dfTimes['Iti1Dur']
            isOkTrial = pd.notnull(times) & (dfTimes['cueType']==cueNum)
            useDur = True
            
        # Write to file
        print("Writing %s..."%outFile)
        f = open('%s/%s'%(outputFolder,outFile),'w')
        trialRun = dfTimes.index.labels[0]
        for run in range(nRuns):
            # Extract relevant values from timing dataframe (with value subtracted)
            tOnset = times[isOkTrial & (trialRun==run)].values - subtractVal
            # Make line
            if len(tOnset)==0:  # write * for empty row
                print('%s: run %d has no trials - writing empty line.'%(outFile,run)) # warn user of missing values
                lineToWrite = '*'
            elif useAmp:
                amps_run = amps[isOkTrial & (trialRun==run)].values
                if useDur:     # both durations and amplitudes
                    durs_run = durs[isOkTrial & (trialRun==run)].values
                    lineToWrite = ' '.join(['%.3f*%d:%.3f'%(tOnset[i],amps_run[i],durs_run[i]) for i in range(len(tOnset))])
                else:          # amplitudes only
                    lineToWrite = ' '.join(['%.3f*%d'%(tOnset[i],amps_run[i]) for i in range(len(tOnset))])
            elif useDur:       # durations only
                durs_run = durs[isOkTrial & (trialRun==run)].values
                lineToWrite = ' '.join(['%.3f:%.3f'%(tOnset[i],durs_run[i]) for i in range(len(tOnset))])
            else:
                # write events to a single string
                lineToWrite = ' '.join(['%.3f'% num for num in tOnset])
            # Add line to file
            f.write(lineToWrite + '\n')
        # Finalize and close file
        f.close
    print('Done! Took %.1f seconds.'%(time.time()-t))
