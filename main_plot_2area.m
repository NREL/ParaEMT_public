clc;clear;
close all

%% read simulation results
dataT = readtable('emt_x.csv');
dataTibr = readtable('emt_xibr.csv');
dataTld = readtable('emt_x_load.csv');
dataTbus = readtable('emt_x_bus.csv');

tend = 2;
dr = 30;
ts = dr*50e-6;


        bus_n = 11;
        bus_odr = 6;
        load_n = 2;
        load_odr = 4;
        
        gen_genrou_odr = 18;
        gen_genrou_n = 4;  % original is 4, because 1 is IBR, change it
        exc_sexs_odr = 2;
        exc_sexs_n = 4;  % original is 4,
        gov_tgov1_odr = 3;
        gov_tgov1_n = 4;   % original is 4,
        gov_hygov_odr = 5;
        gov_hygov_n = 0;
        gov_gast_odr = 4;
        gov_gast_n = 0;
        pss_ieeest_odr = 10;
        pss_ieeest_n = 0;
        
        ibr_n = 0;
        regca_odr = 8;
        reecb_odr = 12;
        repca_odr = 21;
        pll_odr = 3;
        ibr_odr = regca_odr + reecb_odr + repca_odr + pll_odr;


clc;
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


bus_pll_ze = table2array(dataTbus(2:end,1:bus_odr:(bus_odr*bus_n)));
bus_pll_de = table2array(dataTbus(2:end,2:bus_odr:(bus_odr*bus_n)));
bus_pll_we = table2array(dataTbus(2:end,3:bus_odr:(bus_odr*bus_n)));
bus_vt = table2array(dataTbus(2:end,4:bus_odr:(bus_odr*bus_n)));
bus_vtm = table2array(dataTbus(2:end,5:bus_odr:(bus_odr*bus_n)));
bus_dvtm = table2array(dataTbus(2:end,6:bus_odr:(bus_odr*bus_n)));

% load_PL = table2array(dataTld(:,3:load_odr:(load_odr*load_n)));
% load_QL = table2array(dataTld(:,4:load_odr:(load_odr*load_n)));

% plot
close all;
flag_sg = 1;
dev_flag = 0;
flag_ibr = 1 - flag_sg;
if flag_sg == 1
    figure(1)
    clf;hold on;
    set(gcf, 'Position',  [50+xshift, 750+yshift, 400, 200])
    plot(t,mac_dt(:,emt_idx_gen))
    box on;
%     ylim([59.7 60.08])
    xlim([0 tend])
    title('\delta')
    
    figure(2)
    clf;hold on;
    set(gcf, 'Position',  [500+xshift, 750+yshift, 400, 200])
%     plot(t,(mac_w - mac_w(:,1)*ones(1,length(mac_w(1,:))))/2/pi/60)  % relative rotor speed (ref:gen 1)
%     plot(t,mac_w/2/pi/60-1) % rotor speed deviation, pu
    plot(t,mac_w(:,emt_idx_gen)/2/pi)
    box on;
%     ylim([59.4 60])
    xlim([0 tend])
    title('\omega')
    
    figure(3)
    clf;hold on;
    set(gcf, 'Position',  [950+xshift, 750+yshift, 400, 200])
    if systemN==5
        plot(t,mac_te(:,emt_idx_gen) .*(ones(length(t),1)*mvabase(emt_idx_gen)')/100)
    else
        plot(t,(mac_te(:,emt_idx_gen) - dev_flag*ones(length(t),1)*mac_te(1,emt_idx_gen))*900)
    end
    
    box on;
%     ylim([700 900])
    xlim([0 tend])
    title('pe')
    
%     figure(4)
%     clf;hold on;
%     set(gcf, 'Position',  [1400+xshift, 750+yshift, 400, 200])
%     plot(t,(mac_qe - dev_flag*ones(length(t),1)*mac_qe(1,:))*555)
%     box on;
% %     ylim([59 61])
% %     xlim([0 20])
%     title('qe')
    
    
    figure(5)
    clf;hold on;
    set(gcf, 'Position',  [500+xshift, 450+yshift, 400, 200])
    plot(t,sexs_EFD(:,emt_idx_gen) - dev_flag*ones(length(t),1)*sexs_EFD(1,emt_idx_gen))
    box on;
    title('EFD')
%     ylim([1.9 2.4])
    xlim([0 tend])
    
    figure(6)
    clf;hold on;
    set(gcf, 'Position',  [950+xshift, 450+yshift, 400, 200])
    plot(t,tgov1_pm(:,emt_idx_gen) - dev_flag*ones(length(t),1)*tgov1_pm(1,emt_idx_gen))
    box on;
    title('Pm TGOV1')
%     ylim([0.75 0.95])
    xlim([0 tend])
    
%     figure(7)
%     clf;hold on;
%     set(gcf, 'Position',  [950+xshift, 450+yshift, 400, 200])
%     plot(t,hygov_pm - dev_flag*ones(length(t),1)*hygov_pm(1,:))
%     box on;
%     title('Pm HYGOV')
    
%     figure(8)
%     clf;hold on;
%     set(gcf, 'Position',  [1400+xshift, 450+yshift, 400, 200])
%     plot(t,gast_pm - dev_flag*ones(length(t),1)*gast_pm(1,:))
%     box on;
%     title('Pm GAST')
    
%     figure(9)
%     clf;hold on;
%     set(gcf, 'Position',  [50+xshift, 150+yshift, 400, 200])
%     plot(t,ieeest_vs)
%     box on;
%     title('Vs IEEEST')
end

if flag_ibr == 1
    figure(1)
    clf;hold on;
    set(gcf, 'Position',  [50+xshift, 750+yshift, 400, 200])
    plot(t,ibr_epri_Ea,t,ibr_epri_Eb,t,ibr_epri_Ec)
    legend('Ea','Eb','Ec')
    box on;
    title('Eabc')
    
    
    figure(2)
    clf;hold on;
    set(gcf, 'Position',  [500+xshift, 750+yshift, 400, 200])
    plot(t,ibr_epri_Idref,t,ibr_epri_Id)
    legend('Idref','Id')
    box on;
    title('Id')
    
    
    figure(3)
    clf;hold on;
    set(gcf, 'Position',  [950+xshift, 750+yshift, 400, 200])
    plot(t,ibr_epri_Iqref,t,ibr_epri_Iq)
    legend('Iqref','Iq')
    box on;
    title('Iq')
    
    
    figure(4)
    clf;hold on;
    set(gcf, 'Position',  [50+xshift, 450+yshift, 400, 200])
    plot(t,ibr_epri_fpll)
    box on;
    title('fpll')
    
    figure(5)
    clf;hold on;
    set(gcf, 'Position',  [500+xshift, 450+yshift, 400, 200])
    plot(t,ibr_epri_Vpoi)
    box on;
    title('V')
    
    figure(6)
    clf;hold on;
    set(gcf, 'Position',  [950+xshift, 450+yshift, 400, 200])
    plot(t,ibr_epri_Pe,t,ibr_epri_Qe)
    legend('Pe','Qe')
    box on;
    title('PQ')
    
    

%     figure(1)
%     clf;hold on;
%     set(gcf, 'Position',  [50+xshift, 750+yshift, 400, 200])
%     plot(t,regca_s0.*regca_i2,t,reecb_Ipcmd,'--')
%     legend('ip','Ipcmd')
%     box on;
%     title('ip')
% 
% 
%     figure(2)
%     clf;hold on;
%     set(gcf, 'Position',  [500+xshift, 750+yshift, 400, 200])
%     plot(t,regca_s1 + regca_i1,t,reecb_Iqcmd,'--')
%     legend('iq','Iqcmd')
%     box on;
%     title('iq')
%     
%     
%     figure(3)
%     clf;hold on;
%     set(gcf, 'Position',  [950+xshift, 750+yshift, 400, 200])
%     plot(t,repca_Pe, t, repca_Plant_pref,'--')
%     legend('Pe','Pref')
%     box on;
%     title('P')
%     
%     
%     figure(4)
%     clf;hold on;
%     set(gcf, 'Position',  [1400+xshift, 750+yshift, 400, 200])
%     plot(t,repca_Qe, t, repca_Qref,'--')
%     legend('Qe','Qref')
%     box on;
%     title('Q')
%     
%     
%     figure(5)
%     clf;hold on;
%     set(gcf, 'Position',  [50+xshift, 450+yshift, 400, 200])
%     plot(t,pll_we*60)
%     box on;
%     title('\omega PLL')

end

figure(4)
clf;hold on;
set(gcf, 'Position',  [50+xshift, 450+yshift, 400, 200])
plot(t,bus_vtm(:,emt_idx_bus))
box on;
if dev_flag==1
    title('Bus voltage mag deviation')
else
    title('Bus voltage mag')
end
% ylim([0.88 1.18])
% ylim([0.96 1.04])
xlim([0 tend])

% figure(101)
% clf;hold on;
% set(gcf, 'Position',  [1400+xshift, 290+yshift, 400, 200])
% % plot(po.t,po.PL,'k','linewidth',2)
% plot(t,load_PL*100,'r')
% box on;
% title('PL')
% xlim([0 tend])
% % ylim([0 15000])
% 
% 
% figure(102)
% clf;hold on;
% set(gcf, 'Position',  [1400+xshift, 500+yshift, 400, 200])
% % plot(po.t,po.QL,'k','linewidth',2)
% plot(t,load_QL*100,'r')
% box on;
% title('QL')
% xlim([0 tend])
% % ylim([-1000 3000])
