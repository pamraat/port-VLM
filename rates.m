function [x0, y0, z0, x0dot, y0dot, z0dot, phi, theta, psi, p, q, r]=rates(vinf,t)


syms tm;

fx0=-vinf*tm;
fy0=0;
fz0=0;
fphi=0;
ftheta=10*sin(20*pi*tm);
fpsi=0;

x0=double(vpa(subs(fx0,t)));
y0=double(vpa(subs(fy0,t)));
z0=double(vpa(subs(fz0,t)));
phi=double(vpa(subs(fphi,t)));
theta=double(vpa(subs(ftheta,t)));
psi=double(vpa(subs(fpsi,t)));

fx0dot=diff(fx0,tm);
fy0dot=diff(fy0,tm);
fz0dot=diff(fz0,tm);
fphidot=diff(fphi,tm);
fthetadot=diff(ftheta,tm);
fpsidot=diff(fpsi,tm);

x0dot=double(vpa(subs(fx0dot,t)));
y0dot=double(vpa(subs(fy0dot,t)));
z0dot=double(vpa(subs(fz0dot,t)));
phidot=double(vpa(subs(fphidot,t)));
thetadot=double(vpa(subs(fthetadot,t)));
psidot=double(vpa(subs(fpsidot,t)));

A = [1 0 -sin(theta);0 cos(phi) sin(phi)*cos(theta);0 -sin(phi) cos(phi)*cos(theta)]*[phidot; thetadot; psidot];

p=A(1);
q=A(2);
r=A(3);

end
     

