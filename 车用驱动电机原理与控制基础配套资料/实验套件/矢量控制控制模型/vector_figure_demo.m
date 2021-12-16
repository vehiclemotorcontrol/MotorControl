%% 数据导入
clear;clc;close all;
load('open_Loop_Uabc_Iabc.mat');
currentA = Iabc_Uabc_data(:,1);
currentB = Iabc_Uabc_data(:,2);
currentC = 0-currentA-currentB;

voltageA = Iabc_Uabc_data(:,3);
voltageB = Iabc_Uabc_data(:,4);
voltageC = Iabc_Uabc_data(:,5);

X=0; Y=0; U=0; V=0;
%% 坐标系初始化
figure;
hold on;
xlabel('\alpha');
ylabel('\beta');
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
grid on;
grid minor;
plot([0,5],[0 0],'--','LineWidth',1);
text(5,-0.5,'A');
plot([-5,0],[5*sqrt(3) 0],'--','LineWidth',1);
text(-3,4,'B');
plot([0,-5],[0 -5*sqrt(3)],'--','LineWidth',1);
text(-3,-4,'C');
axis([-5 5 -5 5]);
stop = uicontrol('style','toggle','string','stop', ...
    'background','white');

%% 定义矢量
Ia = quiver(X,Y,U,V,0,'b','LineWidth',2);
Ib = quiver(X,Y,U,V,0,'b','LineWidth',2);
Ic = quiver(X,Y,U,V,0,'b','LineWidth',2);
Is = quiver(X,Y,U,V,0,'r','LineWidth',2);

Ua = quiver(X,Y,U,V,0,'m','LineWidth',2);
Ub = quiver(X,Y,U,V,0,'m','LineWidth',2);
Uc = quiver(X,Y,U,V,0,'m','LineWidth',2);
Us = quiver(X,Y,U,V,0,'g','LineWidth',2);

is = text(0,0,'is');
us = text(0,0,'us');

%% 循环更新
for i = 1:length(Iabc_Uabc_data)
    Ia.UData = currentA(i);
    Ib.XData = currentA(i);
    Ib.UData = currentB(i)*(-0.5);
    Ib.VData = currentB(i)*(sqrt(3)/2);
    Ic.XData = currentA(i)+currentB(i)*(-0.5);
    Ic.YData = currentB(i)*(sqrt(3)/2);
    Ic.UData = currentC(i)*(-0.5);
    Ic.VData = currentC(i)*(-sqrt(3)/2);
    Is.UData = currentA(i)+currentB(i)*(-0.5)+currentC(i)*(-0.5);
    Is.VData = currentB(i)*(sqrt(3)/2)+currentC(i)*(-sqrt(3)/2);
    is.Position = [currentA(i)+currentB(i)*(-0.5)+currentC(i)*(-0.5),currentB(i)*(sqrt(3)/2)+currentC(i)*(-sqrt(3)/2)];
    
    Ua.UData = voltageA(i);
    Ub.XData = voltageA(i);
    Ub.UData = voltageB(i)*(-0.5);
    Ub.VData = voltageB(i)*(sqrt(3)/2);
    Uc.XData = voltageA(i)+voltageB(i)*(-0.5);
    Uc.YData = voltageB(i)*(sqrt(3)/2);
    Uc.UData = voltageC(i)*(-0.5);
    Uc.VData = voltageC(i)*(-sqrt(3)/2);
    Us.UData = voltageA(i)+voltageB(i)*(-0.5)+voltageC(i)*(-0.5);
    Us.VData = voltageB(i)*(sqrt(3)/2)+voltageC(i)*(-sqrt(3)/2);
    us.Position = [voltageA(i)+voltageB(i)*(-0.5)+voltageC(i)*(-0.5),voltageB(i)*(sqrt(3)/2)+voltageC(i)*(-sqrt(3)/2)];
    
    drawnow;
    if get(stop,'value')==1
        break; 
    end
end

