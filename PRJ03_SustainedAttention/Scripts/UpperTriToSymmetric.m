function FC_sym = UpperTriToSymmetric(FC)

% Created 3/9/17 by DJ.

FC_sym = UnvectorizeFc(VectorizeFc(FC),0,true);