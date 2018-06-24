cd /home/kauppij/Matlabkoodit/fMRI_iiro

Ctype{1} = 'A';
Ctype{2} = 'D';
fieldN = {'nmi','cor','ken','ssi','cor_abs','det'};
polku = '/share/sig_pic/kauppij/fMRI_iiro/'
alipolku = 'results/'
%polku = 'D:\Tutkimus\fMRI\data\Ikkunointi\';

for q = 1:2
    disp(['Dataset: ' num2str(q)])
    for m = 1:2
        for n = 1:5
            vName = ['meanset' num2str(q) 'win' Ctype{m} num2str(n)]
            if ~( m == 2 && n == 1 )
                disp(['Level: ' num2str(n)])
                clear S
                S = load([polku vName]);
                S.meanData.([Ctype{m} 'Sig_SWT']) = maskData(S.meanData.([Ctype{m} 'Sig_SWT']));
                
                Wnmi = S.meanData.([Ctype{m} 'Sig_SWT']).(fieldN{1});
                Wcor = S.meanData.([Ctype{m} 'Sig_SWT']).(fieldN{2});
                Wken = S.meanData.([Ctype{m} 'Sig_SWT']).(fieldN{3});
                Wssi = S.meanData.([Ctype{m} 'Sig_SWT']).(fieldN{4});
                Wcor_abs = S.meanData.([Ctype{m} 'Sig_SWT']).(fieldN{5});
                Wdet = S.meanData.([Ctype{m} 'Sig_SWT']).(fieldN{6}); 
                save([polku alipolku 'X' vName],'Wnmi','Wcor','Wken','Wssi','Wcor_abs','Wdet')
            end
        end
    end
end