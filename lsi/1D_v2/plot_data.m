clear
clc
close all
%% Input
base = 'solution8/out_line_';
%base = 'Expansion/Argonne/LSI/1D_run1/out_line_';
skip = 1;
id = 1:skip:30000;

%plotid = [200, 400, 1200, 2000, 3600]./skip;
plotid = [1, 20, 100, 300, 408];
col = {'k','b','r','m',[0.4660 0.6740 0.1880],[0.9290 0.6940 0.1250]};

% variable
index = [2,3,5,7,4,1,8]; %alpha, asource, h, d, Deff, P, x
alpha = [];
asource = [];
h = [];
d = [];
Deff = [];
x = [];

oL = 1.2*10^(-5);
phi0 = 0.5;
M = 0.576;

%% Main
for i = 1:size(id,2)
    fname = append(base,num2str(id(i),'%04.f'),'.csv');
    if isfile(fname)
        dat = readcell(fname,'NumHeaderLines',1);
        dat = cell2mat(dat);
        alpha(:,i) = dat(:,index(1));
        asource(:,i) = dat(:,index(2));
        h(:,i) = dat(:,index(3));
        d(:,i) = dat(:,index(4));
        Deff(:,i) = dat(:,index(5));
        P(:,i) = dat(:,index(6));
        x(:,i) = dat(:,index(7));
    else
        break;
    end
end

%% Additional variables
hL = oL*alpha./(sqrt(phi0)-M*d.^2).^2;
r1 = sqrt(phi0) - M*d.^2;
alphamax = r1.^2/oL;

%% Plot
set(figure(1),'color','w');
tiledlayout('Tilespacing','tight')
for i = 1:size(plotid,2)
    nexttile(1)
    plot(x(:,plotid(i)),alpha(:,plotid(i)),'-','linewidth',1,'color',col{i});
    hold on
    plot(x(:,plotid(i)),alphamax(:,plotid(i)),'--','linewidth',1,'color',col{i});
    ylabel('\alpha')
    
    nexttile(2)
    plot(x(:,plotid(i)),asource(:,plotid(i)),'-','linewidth',1,'color',col{i})
    ylabel('\alpha^{dot}_{source}')
    hold on
    
    nexttile(3)
    % plot(x(:,plotid(i)+1),h(:,plotid(i)+1),'-','linewidth',1,'color',col{i})
    hold on
    % plot(x(:,plotid(i)),hL(:,plotid(i)),'--','linewidth',1,'color',col{i})
    % ylabel('h')
    plot(x(:,plotid(i)),Deff(:,plotid(i)),'-','linewidth',1,'color',col{i})
    ylabel('D_{eff}')
    % legend('h_P','h_L','box','off')
    
    nexttile(4)
    plot(x(:,plotid(i)),d(:,plotid(i)).^2,'-','linewidth',1,'color',col{i})
    ylabel('\delta_P')
    hold on
    plot(x(:,plotid(i)),r1(:,plotid(i)),'--','linewidth',1,'color',col{i})

    nexttile(5)
    plot(x(:,plotid(i)),P(:,plotid(i)),'-','linewidth',1,'color',col{i})
    ylabel('P')
    hold on
end

for t = 1:4
    nexttile(t)
    set(gca,"FontSize",11)
    if t == 3 || t == 4
        xlabel('x')
    end
    if t == 2
        legend('t0','t1','t2','t3','t4','t5','box','off','fontsize',8)
    end
end

%% Time Plot
set(figure(2),'color','w');
tiledlayout('Tilespacing','tight')
loc = [5];
for i = 1:size(loc,2)
    nexttile(1)
    plot(alpha(loc(i), :),'-','linewidth',1,'color',col{i})
    ylabel('\alpha_L')
    hold on
    
    nexttile(2)
    plot(asource(loc(i), :),'-','linewidth',1,'color',col{i})
    ylabel('\alpha^{dot}_{source}')
    hold on
    
    nexttile(3)
    %plot(h(loc(i), :),'-','linewidth',1,'color',col{i})
    hold on
    % plot(hL(loc(i), :),'--','linewidth',1,'color',col{i})
    % ylabel('h')
    plot(Deff(loc(i),:),'-','linewidth',1,'color',col{i})
    ylabel('D_{eff}')
    legend('h_P','h_L','box','off')
    
    nexttile(4)
    plot(d(loc(i), :).^2,'-','linewidth',1,'color',col{i})
    ylabel('\delta_P')
    hold on
end

for t = 1:4
    nexttile(t)
    set(gca,"FontSize",11)
    if t == 3 || t == 4
        xlabel('tstep')
    end
end