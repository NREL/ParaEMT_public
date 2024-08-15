clc;clear;
close all

%% read simulation results
dataT = readtable('emt_x.csv');
dataTld = readtable('emt_x_load.csv');
dataTbus = readtable('emt_x_bus.csv');
dataT_voltage = readtable('emt_3phaseV.csv');

tend = 10;
dr = 5;
ts = dr*50e-6;

bus_n = 11;
bus_odr = 6;
load_n = 2;
load_odr = 4;

gen_genrou_odr = 18;
gen_genrou_n = 4;  
exc_sexs_odr = 2;
exc_sexs_n = 4; 
gov_tgov1_odr = 3;
gov_tgov1_n = 4; 
gov_hygov_odr = 5;
gov_hygov_n = 0;
gov_gast_odr = 4;
gov_gast_n = 0;
pss_ieeest_odr = 10;
pss_ieeest_n = 0;
        
t = table2array(dataT(:,1));
st = 1;
mac_dt = table2array(dataT(:,st+1:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_w = table2array(dataT(:,st+2:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_id = table2array(dataT(:,st+3:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_iq = table2array(dataT(:,st+4:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_ifd = table2array(dataT(:,st+5:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_i1d = table2array(dataT(:,st+6:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_i1q = table2array(dataT(:,st+7:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_i2q = table2array(dataT(:,st+8:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_ed = table2array(dataT(:,st+9:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_eq = table2array(dataT(:,st+10:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_psyd = table2array(dataT(:,st+11:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_psyq = table2array(dataT(:,st+12:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_psyfd = table2array(dataT(:,st+13:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_psy1q = table2array(dataT(:,st+14:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_psy1d = table2array(dataT(:,st+15:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_psy2q = table2array(dataT(:,st+16:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_te = table2array(dataT(:,st+17:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));
mac_qe = table2array(dataT(:,st+18:gen_genrou_odr:(st+gen_genrou_odr*gen_genrou_n)));

st = 1 + gen_genrou_odr*gen_genrou_n;
sexs_v1 = table2array(dataT(:,st+1:exc_sexs_odr:(st+exc_sexs_odr*exc_sexs_n)));
sexs_EFD = table2array(dataT(:,st+2:exc_sexs_odr:(st+exc_sexs_odr*exc_sexs_n)));

st = 1 + gen_genrou_odr*gen_genrou_n + exc_sexs_odr*exc_sexs_n;
tgov1_p1 = table2array(dataT(:,st+1:gov_tgov1_odr:(st+gov_tgov1_odr*gov_tgov1_n)));
tgov1_p2 = table2array(dataT(:,st+2:gov_tgov1_odr:(st+gov_tgov1_odr*gov_tgov1_n)));
tgov1_pm = table2array(dataT(:,st+3:gov_tgov1_odr:(st+gov_tgov1_odr*gov_tgov1_n)));

st = 1 + gen_genrou_odr*gen_genrou_n + exc_sexs_odr*exc_sexs_n + gov_tgov1_odr*gov_tgov1_n;
hygov_xe = table2array(dataT(:,st+1:gov_hygov_odr:(st+gov_hygov_odr*gov_hygov_n)));
hygov_xc = table2array(dataT(:,st+2:gov_hygov_odr:(st+gov_hygov_odr*gov_hygov_n)));
hygov_xg = table2array(dataT(:,st+3:gov_hygov_odr:(st+gov_hygov_odr*gov_hygov_n)));
hygov_xq = table2array(dataT(:,st+4:gov_hygov_odr:(st+gov_hygov_odr*gov_hygov_n)));
hygov_pm = table2array(dataT(:,st+5:gov_hygov_odr:(st+gov_hygov_odr*gov_hygov_n)));

st = 1 + gen_genrou_odr*gen_genrou_n + exc_sexs_odr*exc_sexs_n + gov_tgov1_odr*gov_tgov1_n +gov_hygov_odr*gov_hygov_n;
gast_p1 = table2array(dataT(:,st+1:gov_gast_odr:(st+gov_gast_odr*gov_gast_n)));
gast_p2 = table2array(dataT(:,st+2:gov_gast_odr:(st+gov_gast_odr*gov_gast_n)));
gast_p3 = table2array(dataT(:,st+3:gov_gast_odr:(st+gov_gast_odr*gov_gast_n)));
gast_pm = table2array(dataT(:,st+4:gov_gast_odr:(st+gov_gast_odr*gov_gast_n)));

st = 1 + gen_genrou_odr*gen_genrou_n + exc_sexs_odr*exc_sexs_n + gov_tgov1_odr*gov_tgov1_n +gov_hygov_odr*gov_hygov_n +gov_gast_odr*gov_gast_n;
ieeest_y1 = table2array(dataT(:,st+1:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_y2 = table2array(dataT(:,st+2:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_y3 = table2array(dataT(:,st+3:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_y4 = table2array(dataT(:,st+4:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_y5 = table2array(dataT(:,st+5:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_y6 = table2array(dataT(:,st+6:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_y7 = table2array(dataT(:,st+7:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_x1 = table2array(dataT(:,st+8:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_x2 = table2array(dataT(:,st+9:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));
ieeest_vs = table2array(dataT(:,st+10:pss_ieeest_odr:(st+pss_ieeest_odr*pss_ieeest_n)));

bus_pll_ze = table2array(dataTbus(:,1:bus_odr:(bus_odr*bus_n)));
bus_pll_de = table2array(dataTbus(:,2:bus_odr:(bus_odr*bus_n)));
bus_pll_we = table2array(dataTbus(:,3:bus_odr:(bus_odr*bus_n)));
bus_vt = table2array(dataTbus(:,4:bus_odr:(bus_odr*bus_n)));
bus_vtm = table2array(dataTbus(:,5:bus_odr:(bus_odr*bus_n)));
bus_dvtm = table2array(dataTbus(:,6:bus_odr:(bus_odr*bus_n)));

load_PL = table2array(dataTld(:,3:load_odr:(load_odr*load_n)));
load_QL = table2array(dataTld(:,4:load_odr:(load_odr*load_n)));

Va   = table2array(dataT_voltage(:,1:bus_n));
Vb   = table2array(dataT_voltage(:,bus_n+1:2*bus_n));
Vc   = table2array(dataT_voltage(:,2*bus_n+1:end));

%%  plot
close all;

% Generator states
figure(1)
set(gcf, 'Position',  [50, 750, 400, 200])
plot(t,mac_dt-mac_dt(:,1))
xlim([0 tend])
title('\delta')
    
figure(2)
set(gcf, 'Position',  [500, 750, 400, 200])
plot(t,mac_w/2/pi)
xlim([0 tend])
title('\omega')
    
figure(3)
set(gcf, 'Position',  [950, 750, 400, 200])
plot(t,mac_te)
xlim([0 tend])
title('pe')
    
figure(4)
set(gcf, 'Position',  [1400, 750, 400, 200])
plot(t,(mac_qe))
xlim([0 tend])
title('qe')
     
figure(5)
set(gcf, 'Position',  [50, 450, 400, 200])
plot(t,sexs_EFD)
title('EFD')
xlim([0 tend])
    
figure(6)
set(gcf, 'Position',  [500, 450, 400, 200])
plot(t,tgov1_pm)
title('Pm TGOV1')
xlim([0 tend])

% Load PQ
figure(7)
set(gcf, 'Position',  [950, 450, 400, 200])
plot(t,load_PL*100,'r')
title('PL')
xlim([0 tend])

figure(8)
set(gcf, 'Position',  [1400, 450, 400, 200])
plot(t,load_QL*100,'r')
title('QL')
xlim([0 tend])

% Three phase bus voltages
figure(9)
k=1;
plot(t,Va(:,k))
hold on
plot(t,Vb(:,k))
hold on
plot(t,Vc(:,k))
set(gcf, 'Position',  [50, 150, 400, 200])
xlabel('time (s)')
title(sprintf('three phase volatge at bus %d',k))

% bus voltage magnitude
figure(10)
set(gcf, 'Position',  [500, 150, 400, 200])
plot(t,bus_vtm)
title('Bus voltage mag')
xlim([0 tend])






