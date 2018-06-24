function plotValence(datasetNr)

load KatrinKoe
gca;hold on
switch datasetNr
    case 1
 %       t=0:0.5:13.5;
        plot(Aro1,'r--');
        plot(Val1,'b--');
      %  xlim([0 14])
    case 2
 %       t=14:0.5:35;
        plot(Aro2,'r--');
        plot(Val2,'b--');
      %  xlim([14 35])
end
legend('Valence','Arousal');
%xlabel('Aika (min)');
%ylabel('Valenssiaste');
%grid on
hold off