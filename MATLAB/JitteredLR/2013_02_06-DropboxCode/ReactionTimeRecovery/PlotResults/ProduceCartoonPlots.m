% ProduceCartoonPlots.m
%
% Created 10/3/12 by DJ.

foo = load('AllSubjects_ExGaussianFit.mat');
mu = foo.R(1);
sigma = foo.R(2);
tau = foo.R(3);
t = -500:500;
prior = exgausspdf(mu,sigma,tau,t); % produce
prior = fliplr(prior); % flip
prior = prior/sum(prior); % normalize

y = zeros(size(t));
y(300:350) = -3;
y(400:450) = 3;
y(500:550) = -1;


nully_mu = 0;
nully_sigma = 1;
nully_sigmamultiplier = 5;

clf

subplot(3,3,2); cla;
plot(t,y,'k');
xlabel('t_i')
ylabel(sprintf('v^TX(t_i)'))
title('spatial filter of data')
ylim([-5 5])

subplot(3,3,1); cla;
foo = -10:.1:10;
yfoo = 1-normpdf(foo,nully_mu,nully_sigma*nully_sigmamultiplier)/max(normpdf(foo,nully_mu,nully_sigma*nully_sigmamultiplier));
plot(foo,yfoo,'k');
xlabel('v^TX')
ylabel(sprintf('f(v^TX)'))
title('noise distribution')
ylim([0 1])

subplot(3,3,3); cla; hold on;
foo = -10:.1:10;
plot(foo, bernoull(zeros(size(foo)),foo),'k:'); 
plot(foo, bernoull(ones(size(foo)),foo),'k');
xlabel('v^TX')
ylabel(sprintf('f(v^TX)'))
legend('c_i=0','c_i=1')
box on
title('bernoulli')


subplot(3,3,4); cla;
rel_y = 1-normpdf(y,nully_mu,nully_sigma*nully_sigmamultiplier)/max(normpdf(foo,nully_mu,nully_sigma*nully_sigmamultiplier));
plot(t,rel_y,'k');
xlabel('t_i')
ylabel(sprintf('P(X(t_i) | v)'))
title('relevance of X')

subplot(3,3,5); cla;
plot(t,prior,'k');
xlabel('t_i')
ylabel(sprintf('P(t_i)'))
title('prior')

subplot(3,3,7); cla;
condprior = prior.*rel_y;
condprior = condprior/sum(condprior);
plot(t,condprior,'k');
xlabel('t_i')
ylabel(sprintf('P(t_i | v)'))
title('conditioned prior')
ylim([0 0.02])

subplot(3,3,6); cla; hold on;
likelihood = bernoull(ones(size(y)),y);
plot(t,1-likelihood,'k:');
plot(t,likelihood,'k');
xlabel('t_i')
ylabel(sprintf('P(X(t_i) | v, c_i)'))
legend('c_i=0','c_i=1')
box on
title('likelihood')


subplot(3,3,8); cla; hold on;
joint0 = condprior.*(1-likelihood);
p0 = sum(joint0);
joint1 = condprior.*likelihood;
p1 = sum(joint1);
% post1 = post1/sum(post1);
plot(t,joint0,'k:');
plot(t,joint1,'k');
xlabel('t_i')
ylabel(sprintf('P(t_i, c_i | v)'))
legend('c_i=0','c_i=1')
box on
title('joint distribution')
ylim([0 0.02])

subplot(3,3,9); cla;
post = joint0 + joint1;
plot(t,post,'k');
xlabel('t_i')
ylabel(sprintf('P(t_i | v)'))
title('posterior')
% title(sprintf('posterior: P(c=0)=%.2f, P(c=1)=%.2f',p0,p1))
ylim([0 0.02])

for i=1:9
    subplot(3,3,i)
    set(gca,'xtick',[],'ytick',[])
end