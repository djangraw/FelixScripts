function monitorjobs(jobid)

if nargin < 1, jobid = '='; end % always there

user = deblank(evalc('!whoami'));

sjobs = evalc('!sjobs');

while ~isempty(regexp(sjobs,jobid,'once'))
    
    sjobs = evalc('!sjobs');
    jl = evalc(sprintf('!jobload -u %s',user));
    
    clc
    fprintf('%s\n\n',sjobs)
    disp(jl)
    
    pause(5)
    
end

clc
