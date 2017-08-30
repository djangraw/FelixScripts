Purpose
-------
This code demonstrates an example workflow for running parallel computing jobs on the NIH biowulf cluster from within matlab.  

What’s the point?
-----------------
Let's just assume we want to use an algorithm to process some images.  Our algorithm loads an image, does some calculations, and saves a modified image.  (A great number of analysis jobs can be broken down into loading analyzing and saving files, so this example should be applicable to a large number of users' needs.)  Anyway, let’s assume it takes about 1 minute to analyze each image and we have 300 images to process.  If we programmed this task to run in a loop on a single machine it would take around 5 hours.  That’s inconvenient.  Now if we assume instead that we had 3,600 images (a 2 minute movie sampled at 30 frames per second) it would take 2.5 days to complete.  That’s most inconvenient.  The code will run… as long as the power doesn’t go out, or our computer doesn’t install updates and reboot, or our code is bug-free.  But if any of these conditions are not met we might have to wait another few days.  And if we have to debug our code or choose new parameters for our algorithm it might take weeks to analyze our data.  

If we needed to analyze all the frames from a feature length film (2 hours, 216,000 frames) our algorithm will take around 5 months to finish.  In this scenario our code had better be bug-free the first time we run it.  

The point is that parallel computing is not just a convenience.  In some cases it’s a necessity.  Parallel computing enables calculations that would otherwise be impossible.  And once you start using it, you will start to think of new analyses that you never would have dreamed of attempting previously.  

But why matlab?
---------------
If you are a longtime matlab programmer you already know the answer to this question.  Matlab has a very powerful gui (i.e. the java virtual machine) that helps users rapidly develop and debug code.  In fact "debug mode" is often used to turn a matlab script into an interactive program, allowing the user to pause and flexibly analyze and visualize data on the fly.  Matlab has many, many algorithms and analyses built right in, or available in toolboxes so you almost never have to program things up from scratch.  Data visualization with matlab is powerful and efficient.  And finally, user's tend to build a large collection of recyclable functions and scripts allowing them to use matlab more efficiently over time.  

Matlab users often do not want to throw years of work away and start from scratch in a new language.  They might not feel very comfortable stepping out onto the command line, or writing bash scripts.  In labs where matlab is heavily used they might want to pass their code to other lab mates.  The examples here are designed to help matlab users get up and running fully fledged, unlicensed, parallel matlab jobs on the NIH Biowulf cluster without investing a lot of time learning another scripting language.  Code like this can also be passed on to labmates or colleagues with virtually no experience on the Biowulf cluster, allowing them to pre-packaged parallel jobs with ease.  

To use this example
-------------------
First, copy this directory to your personal space.  (This example assumes your data directory.)

>> cp -r /data/classes/matlab/swarm_example/ /data/$USER/

Now open an interactive matlab session.  These examples display figures, so be sure you are running in an X11 enabled environment.  Allocate the following licenses.

>> sinteractive --license=matlab,matlab-compiler,matlab-image,matlab-stat

>> module load matlab

>> matlab&

Now cd to the directory that you copied in step one.

>> cd ~/swarm_example/ 

Detailed description of the problem
-----------------------------------
In this example, we have a matlab function called kmeans_image.m that uses a k-means clustering algorithm to group pixels based on their position in three-dimensional color space.  Type the following for a usage summary.  

>> help kmeans_image

To get a feel for what the code is doing, analyze an image called Penguins.jpg from the few-images directory.

>> kmeans_image('./few-images','Penguins.jpg')

You should see the original image compared to one that has been downsampled to 3 colors.  We can increase the number of colors to 6 by increasing the k in the kmeans clustering algorithm like so.

>> kmeans_image('./few-images','Penguins.jpg',6)

Run this 5 or 6 times and notice 2 things.  First, the algorithm is not very efficient, so it takes a long time to run.  Second, kmeans is an iterative fitting procedure that can converge on different local minima depending on the random starting position.  In other words, it is not very reliable across runs.  With 6 clusters, you will sometimes see the algorithm identifying yellow around the penguins’ throat as a principle color while other times it does not.  

To make the algorithm more reliable, we can increase the number of repetitions.

>>  kmeans_image('./few-images','Penguins.jpg',6,15) 

This increases reliability but it slows the code substantially.  

Now to round out the example, you can play with the other images in the few-images directory and try different values of kclusters and reps.  Also notice that the code will save a copy of the analyzed image in the format of our choice if we give it the right input.  For instance:

>> kmeans_image('./few-images','GeneralTso.jpg',10,1,'.','new-image.png','png')

Saves a grayish image of my dog (named General Tso) in the current directory.  You can view the .png image in a web browser by issuing a system command from matlab with the bang (!) like so.

>> !xdg-open new-image.png&

If you haven’t already seen this trick, take note.  It comes in quite handy, 
and you will see that it is used extensively in the code.

Now the problem.  As you may have guessed we have lots of images in the lots-o-images folder and we want to use kmeans clustering to group the pixels in color space.  And we want to do so with some degree of reliability, so we want to increase reps to at least 10 or 15.  Furthermore, we may need to analyze the images more than once because we don’t know how many colors we want to specify.  So we want to run this as a parallel job on the biowulf cluster.  

The solution
------------
After developing and debugging some matlab code, the steps for running it in parallel on the biowulf cluster follow:
1) compile the code (using the mcc2 command)
2) generate a swarm file that will be used in conjunction with the swarm program to submit jobs to the scheduler (SLURM)
3) invoke swarm (with sensible arguments) pointing it the swarm file you created in step 2.
4) monitor the jobs as they are spawned and run to completion

Using a few tricks like invoking system commands with the bang (mentioned above) and writing and parsing text, we can do all of that quite nicely from within matlab.  To see how type:

>> edit par_kmeans_image.m

The top of this script sets up a bunch of parameters.  Some are variables that are passed to kmeans_image.m.  Others are arguments that get passed to SLURM through a program called swarm.  Read the comments get more details.

The next part of the script goes through all 4 steps listed above.  (Note that you can omit step 1 by setting recompile_code flag to false at the top of the script.  This is useful if you have already compiled your code and haven’t made any changes to it.)

Note that step 2 calls another function generate_swarm_kmeans_image.m.  This is the function that writes the swarm file for use with the swarm command.  As before you can see info about its usage with:

>> help generate_swarm_kmeans_image

But you really probably just want to edit it and step through it because you will want to write functions like this yourself to run your own code.  You can start with it as a template and modify it to suit your needs.

But before getting too far ahead, why not just try running the script and seeing what happens?

>> par_kmeans_image

Provided that the compiler license is free, you should see the following.  First you will see several new directories created in the current location and the standard matlab copyright info will be displayed at the command prompt.  This is because matlab is spawning a sub-instance of itself to compile your code.  When it is finished it will exit back to the main matlab process and release the compiler license.  Next you will see a message with the job id that was spawned on your behalf by matlab through swarm.  Then a few tables will start to be displayed in the command prompt with info about your queued and running jobs.  They will refresh every 5 seconds.  (Note that the first job is your interactive matlab session.)  As your jobs move from the queued to the running state, these tables will lengthen.  Depending on the current cluster load, this may happen very quickly or it might take a little longer.  As your jobs finish executing, the tables will shorten.  A few of your jobs might linger in the running state longer than others due to the somewhat random nature of the kmeans algorithm and the state of the nodes that the jobs run on.  When the jobs complete, the command prompt will be returned to you.  You should see a new directory called analyzed-images.  It contains just what you think.  You should also see an new directory called swarm_output.  In it you will find .o (standard out) and .e files (standard error).  If any of you jobs did not finish executing properly, this is where to start looking for error info.  

By stepping through this code you should be able to get a good idea of how it works.  

