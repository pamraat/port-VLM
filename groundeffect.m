%code for symmetric wing
clear
clc
fprintf('Wing is Assumed Symmetric and thin.\n Origin is on leading tip midline of wing.\n X axis along chord, Y axis along span, right handed system.\n');
for i=2:4     %Taking input for wing geometry.(3 corners)
    fprintf('Please enter the value of x(%d)', i);
    x(i)=input(':');
    if(i==2)
        y(i)=0;
        continue;
    end
    fprintf('Please enter the value of y(%d)', i);
    y(i)=input(':');
end

dih=input('Please enter the value of wing dihedral:');
dih=dih*pi/180;

P=input('Please enter position of maximum camber of airfoil(in fraction of chord):');
M=input('Please enter thickness of airfoil(in fraction of chord):');

vinf=input('Please enter magnitude of free stream velocity:');
aoa=input('Please enter the angle of attack:');
aoa=aoa*pi/180;
vinf=[vinf*cos(aoa) 0 vinf*sin(aoa)];

rho=input('Please enter the density of fluid:');

h=input('Height from ground:');

n=0;        %initializing variable for chordwise points
m=0;        %initializing variable for spanwise points
fprintf('Please choose type of Grid:\n 1. Coarse\n 2. Medium\n 3. Fine\n 4. Super fine\n');
i=0;
while(i==0)
grid=input('Please enter your choice:');   %choosing grid quality

switch(grid)
    case 1
       n=5;
       m=8;
       i=1;
    case 2
       n=20;
       m=35;
       i=1;
    case 3
       n=50;
       m=80;
       i=1;
    case 4
       n=150;
       m=250;
       i=1;
    otherwise
    disp('Re-enter proper choice');
    i=0;
end
end
delx1=x(2)/n;               % step in mid line
delx2=(x(4)-x(3))/n;        % Step on wing tip
a=x(3);
b=y(3);
c=x(4);
d=y(4);
dely=(y(4)-y(3))/n;
for i=1:(n+1)
    x(i,1)=(i-1)*delx1;     % defining coordinates of midline points
    y(i,1)=0;
    z(i,1)=0;
    if(x(i,1)<P*n*delx1)                             %for giving camber on midline
    z(i,1)=h+M*(2*P*x(i,1)/(n*delx1)-(x(i,1)/(n*delx1))^2)/P^2;         
    else
    z(i,1)=h+M*(1-2*P+2*P*x(i,1)/(n*delx1)-(x(i,1)/(n*delx1))^2)/(1-P)^2;
    end
    x(i,m+1)=a+(i-1)*delx2; % defining coordinates of wing tip
    y(i,m+1)=b+(i-1)*dely;
    if(sqrt((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)<P*sqrt((c-a)^2+(d-b)^2))                %for giving camber on tip
    z(i,m+1)=h+y(i,m+1)*sin(dih)+M*(2*P*sqrt((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/sqrt((c-a)^2+(d-b)^2)-((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/((c-a)^2+(d-b)^2))/P^2;
    else
    z(i,m+1)=h+y(i,m+1)*sin(dih)+M*(1-2*P+2*P*sqrt((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/sqrt((c-a)^2+(d-b)^2)-((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/((c-a)^2+(d-b)^2))/(1-P)^2;
    end
    for j=1:(m+1)
        x(i,j)=x(i,1)+(j-1)*(x(i,m+1)-x(i,1))/m;        %defining coordinates of points spanwise
        y(i,j)=y(i,1)+(j-1)*(y(i,m+1)-y(i,1))/m;
        z(i,j)=z(i,1)+(z(i,m+1)-z(i,1))*(j-1)/m;
    end
end

for j=1:m                                       %Increasing columns of matrix to 2m+1
for i=1:n+1                                     
    x(i,j+m+1)=x(i,j+1);                        %Giving values of 2nd column column to m+2 column
    y(i,j+m+1)=y(i,j+1);
    z(i,j+m+1)=z(i,j+1);
end
end
for i=1:n+1
    x(i,m+1)=x(i,1);                            %Giving mid line values to centre column(m+1 column)
    y(i,m+1)=y(i,1);
    z(i,m+1)=z(i,1);
end
for i=1:n+1                                     
for j=1:m+1
    x(i,j)=x(i,2*m+2-j);                        %Mirroring all columns from 1st through mth column
    y(i,j)=-y(i,2*m+2-j);
    z(i,j)=z(i,2*m+2-j);
end
end
for j=1:2*m+1                                      %Giving 3rd dimension to matrix for accomodating ground distance
for i=1:n+1                                     
    x(i,j,2)=x(i,j,1);                        
    y(i,j,2)=y(i,j,1);
    z(i,j,2)=-z(i,j,1);
end
end

%Influence coefficient calculation
[a,b,nor]=infcoeffgr(x,y,z,aoa);
k=size(a,1);



%Calculation of RHS
for g=1:2
for i=1:n
for j=1:2*m
    rhs(2*m*(i-1)+j+(g-1)*2*m*n)=-dot(vinf,nor(i,:,j,g));
end
end
end
rhs=transpose(rhs);



%Calculation of gama
gama=a\rhs;


%Calculation of wind
wind=b*gama;



%Lift and Pressure different calculation
L=0;

for i=1:n
for j=1:2*m
    if(i==1)
    L=L+rho*norm(vinf)*gama(2*m*(i-1)+j)*(y(i,j+1)-y(i,j));
    else
    L=L+rho*norm(vinf)*(gama(2*m*(i-1)+j)-gama(2*m*(i-2)+j))*(y(i,j+1)-y(i,j));
    delp(i,j)=rho*norm(vinf)*(gama(2*m*(i-1)+j)-gama(2*m*(i-2)+j))*(y(i+1,j)-y(i,j))/(areaquad(x(i,j),y(i,j),z(i,j),x(i+1,j),y(i+1,j),z(i+1,j),x(i,j+1),y(i,j+1),z(i,j+1),x(i+1,j+1),y(i+1,j+1),z(i+1,j+1)));
    end
end
end

fprintf('Lift is %f\n', L);
cl=L/(0.5*rho*norm(vinf)^2*(areaquad(x(1,1),y(1,1),z(1,1),x(n+1,1),y(n+1,1),z(n+1,1),x(1,m+1),y(1,m+1),z(1,m+1),x(n+1,m+1),y(n+1,m+1),z(n+1,m+1))+areaquad(x(1,m+1),y(1,m+1),z(1,m+1),x(n+1,m+1),y(n+1,m+1),z(n+1,m+1),x(1,2*m+1),y(1,2*m+1),z(1,2*m+1),x(n+1,2*m+1),y(n+1,2*m+1),z(n+1,2*m+1))));
fprintf('Cl is %f\n', cl);



%Drag Calculation
D=0;

for i=1:n
for j=1:2*m
    if(i==1)
    D=D-rho*wind(2*m*(i-1)+j)*gama(2*m*(i-1)+j)*(y(i,j+1)-y(i,j));
    else
    D=D-rho*wind(2*m*(i-1)+j)*(gama(2*m*(i-1)+j)-gama(2*m*(i-2)+j))*(y(i,j+1)-y(i,j));
    end
end
end

fprintf('Drag is %f\n', D);
cd=D/(0.5*rho*norm(vinf)^2*(areaquad(x(1,1),y(1,1),z(1,1),x(n+1,1),y(n+1,1),z(n+1,1),x(1,m+1),y(1,m+1),z(1,m+1),x(n+1,m+1),y(n+1,m+1),z(n+1,m+1))+areaquad(x(1,m+1),y(1,m+1),z(1,m+1),x(n+1,m+1),y(n+1,m+1),z(n+1,m+1),x(1,2*m+1),y(1,2*m+1),z(1,2*m+1),x(n+1,2*m+1),y(n+1,2*m+1),z(n+1,2*m+1))));
fprintf('Cd is %f\n', cd);