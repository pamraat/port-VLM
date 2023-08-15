clear
syms t1
t=0:0.001:0.1;
rho=1;
U=30;
b=0.09;
f=10;
w=2*pi*f;
k=w*b/U;
alp=10*sin(w*t1);
alpd=diff(alp,t1);
alpdd=diff(alpd,t1);
a=-0.5;
C=besselh(1,2,k)/(besselh(1,2,k)+1i*besselh(0,2,k));
for i=1:length(t)
    L(i)=pi*rho*b^2*(U*double(subs(alpd,t1,t(i)))-b*a*double(subs(alpdd,t1,t(i))))+2*pi*rho*U*b*C*(U*double(subs(alp,t1,t(i)))+b*double(subs(alpd,t1,t(i)))*(0.5-a));
    abL(i)=pi*rho*b^2*(U*double(subs(alpd,t1,t(i)))-b*a*double(subs(alpdd,t1,t(i))))+2*pi*rho*U*b*abs(C)*(U*double(subs(alp,t1,t(i)))+b*double(subs(alpd,t1,t(i)))*(0.5-a));
end
figure(1);
hold on
xlabel('time(s)');
ylabel('Lift');
plot(t,real(L));
plot(t,imag(L));
plot(t,abL);
hold off
legend('Non-Circulatory','Circulatory','Total');