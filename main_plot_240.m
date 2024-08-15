clc;clear;

%% read simulation results
dataT = readtable('emt_x.csv');
dataTibr = readtable('emt_xibr.csv');
dataTld = readtable('emt_x_load.csv');
dataTbus = readtable('emt_x_bus.csv');
dataT_voltage = readtable('emt_3phaseV.csv');

tend = 10;
dr = 5;
ts = dr*50e-6;

bus_n = 243;
bus_odr = 6;
load_n = 137;
load_odr = 4;
        
gen_genrou_odr = 18;
gen_genrou_n = 111;
exc_sexs_odr = 2;
exc_sexs_n = 111;
gov_tgov1_odr = 3;
gov_tgov1_n = 37;
gov_hygov_odr = 5;
gov_hygov_n = 25;
gov_gast_odr = 4;
gov_gast_n = 49;
pss_ieeest_odr = 10;
pss_ieeest_n = 10;

ibr_n = 91;
regca_odr = 8;
reecb_odr = 12;
repca_odr = 18;
pll_odr = 3;
ibr_odr = regca_odr + reecb_odr + repca_odr + pll_odr;

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

% 3phase voltage
Va   = table2array(dataT_voltage(:,1:bus_n));
Vb   = table2array(dataT_voltage(:,bus_n+1:2*bus_n));
Vc   = table2array(dataT_voltage(:,2*bus_n+1:end));

load_PL = table2array(dataTld(:,3:load_odr:(load_odr*load_n)));
load_QL = table2array(dataTld(:,4:load_odr:(load_odr*load_n)));

st = 0;
regca_s0 = table2array(dataTibr(:,st+1:ibr_odr:(st+ibr_odr*ibr_n)));
regca_s1 = table2array(dataTibr(:,st+2:ibr_odr:(st+ibr_odr*ibr_n)));
regca_s2 = table2array(dataTibr(:,st+3:ibr_odr:(st+ibr_odr*ibr_n)));
regca_Vmp = table2array(dataTibr(:,st+4:ibr_odr:(st+ibr_odr*ibr_n)));
regca_Vap = table2array(dataTibr(:,st+5:ibr_odr:(st+ibr_odr*ibr_n)));
regca_i1 = table2array(dataTibr(:,st+6:ibr_odr:(st+ibr_odr*ibr_n)));
regca_i2 = table2array(dataTibr(:,st+7:ibr_odr:(st+ibr_odr*ibr_n)));
regca_ip2rr = table2array(dataTibr(:,st+8:ibr_odr:(st+ibr_odr*ibr_n)));
    
reecb_s0 = table2array(dataTibr(:,st+9:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_s1 = table2array(dataTibr(:,st+10:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_s2 = table2array(dataTibr(:,st+11:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_s3 = table2array(dataTibr(:,st+12:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_s4 = table2array(dataTibr(:,st+13:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_s5 = table2array(dataTibr(:,st+14:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_Ipcmd = table2array(dataTibr(:,st+15:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_Iqcmd = table2array(dataTibr(:,st+16:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_Pref = table2array(dataTibr(:,st+17:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_Qref = table2array(dataTibr(:,st+18:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_q2vPI = table2array(dataTibr(:,st+19:ibr_odr:(st+ibr_odr*ibr_n)));
reecb_v2iPI = table2array(dataTibr(:,st+20:ibr_odr:(st+ibr_odr*ibr_n)));
    
repca_s0 = table2array(dataTibr(:,st+21:ibr_odr:(st+ibr_odr*ibr_n)));
repca_s1 = table2array(dataTibr(:,st+22:ibr_odr:(st+ibr_odr*ibr_n)));
repca_s2 = table2array(dataTibr(:,st+23:ibr_odr:(st+ibr_odr*ibr_n)));
repca_s3 = table2array(dataTibr(:,st+24:ibr_odr:(st+ibr_odr*ibr_n)));
repca_s4 = table2array(dataTibr(:,st+25:ibr_odr:(st+ibr_odr*ibr_n)));
repca_s5 = table2array(dataTibr(:,st+26:ibr_odr:(st+ibr_odr*ibr_n)));
repca_s6 = table2array(dataTibr(:,st+27:ibr_odr:(st+ibr_odr*ibr_n)));
repca_Vref = table2array(dataTibr(:,st+28:ibr_odr:(st+ibr_odr*ibr_n)));
repca_Qref = table2array(dataTibr(:,st+29:ibr_odr:(st+ibr_odr*ibr_n)));
repca_Freq_ref = table2array(dataTibr(:,st+30:ibr_odr:(st+ibr_odr*ibr_n)));
repca_Plant_pref = table2array(dataTibr(:,st+31:ibr_odr:(st+ibr_odr*ibr_n)));
repca_LineMW = table2array(dataTibr(:,st+32:ibr_odr:(st+ibr_odr*ibr_n)));
repca_LineMvar = table2array(dataTibr(:,st+33:ibr_odr:(st+ibr_odr*ibr_n)));
repca_LineMVA = table2array(dataTibr(:,st+34:ibr_odr:(st+ibr_odr*ibr_n)));
repca_QVdbout = table2array(dataTibr(:,st+35:ibr_odr:(st+ibr_odr*ibr_n)));
repca_fdbout = table2array(dataTibr(:,st+36:ibr_odr:(st+ibr_odr*ibr_n)));
repca_vq2qPI = table2array(dataTibr(:,st+37:ibr_odr:(st+ibr_odr*ibr_n)));
repca_p2pPI = table2array(dataTibr(:,st+38:ibr_odr:(st+ibr_odr*ibr_n)));
repca_Vf = table2array(dataTibr(:,st+39:ibr_odr:(st+ibr_odr*ibr_n)));
repca_Pe = table2array(dataTibr(:,st+40:ibr_odr:(st+ibr_odr*ibr_n)));
repca_Qe = table2array(dataTibr(:,st+41:ibr_odr:(st+ibr_odr*ibr_n)));

%% plot
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

figure(7)
set(gcf, 'Position',  [950, 450, 400, 200])
plot(t,hygov_pm)
box on;
title('Pm HYGOV')
xlim([0 tend])

figure(8)
clf;hold on;
set(gcf, 'Position',  [1400, 450, 400, 200])
plot(t,gast_pm)
box on;
title('Pm GAST')
xlim([0 tend])

figure(9)
set(gcf, 'Position',  [50, 150, 400, 200])
plot(t,ieeest_vs)
box on;
title('Vs IEEEST')
xlim([0 tend])

% Generic IBR states
figure(10)
clf;hold on;
set(gcf, 'Position',  [500, 150, 400, 200])
plot(t,regca_s0.*regca_i2,t,reecb_Ipcmd,'--')
legend('ip','Ipcmd')
box on;
title('ip')

figure(11)
clf;hold on;
set(gcf, 'Position',  [950, 150, 400, 200])
plot(t,regca_s1 + regca_i1,t,reecb_Iqcmd,'--')
legend('iq','Iqcmd')
box on;
title('iq')

figure(12)
clf;hold on;
set(gcf, 'Position',  [1400, 150, 400, 200])
plot(t,repca_Pe, t, repca_Plant_pref,'--')
legend('Pe','Pref')
box on;
title('P')

figure(13)
clf;hold on;
set(gcf, 'Position',  [300, 600, 400, 200])
plot(t,repca_Qe, t, repca_Qref,'--')
legend('Qe','Qref')
box on;
title('Q')

figure(14)
clf;hold on;
set(gcf, 'Position',  [750, 600, 400, 200])
plot(t,bus_pll_we*60)
box on;
title('\omega PLL')

% Three phase bus voltages
figure(15)
k=1;
plot(t,Va(:,k))
hold on
plot(t,Vb(:,k))
hold on
plot(t,Vc(:,k))
set(gcf, 'Position',  [300, 300, 400, 200])
xlabel('time (s)')
title(sprintf('three phase volatge at bus %d',k))

% bus voltage magnitude
figure(16)
set(gcf, 'Position',  [750, 300, 400, 200])
plot(t,bus_vtm)
title('Bus voltage mag')
xlim([0 tend])
