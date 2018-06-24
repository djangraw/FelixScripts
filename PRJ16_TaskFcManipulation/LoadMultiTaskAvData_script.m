% LoadMultiTaskAvData_script.m
% Created 7/14/17 by DJ.

filename = '/Users/jangrawdc/Documents/Python/PsychoPyParadigms/BasicExperiments/MultiTaskAv-1-17-Jul_13_1359.log';
params = PsychoPy_ParseParams(filename);
types = {'block','soundset','soundstart','key','display'};
events = PsychoPy_ParseEvents(filename,types);