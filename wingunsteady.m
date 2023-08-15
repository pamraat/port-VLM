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
% aoa=input('Please enter the angle of attack:');
% aoa=aoa*pi/180;
% vinf=[vinf*cos(aoa) 0 vinf*sin(aoa)];

rho=input('Please enter the density of fluid:');

tottime=input('Please enter the total simulation run time:');
delt=input('Please enter the time step:');

n=0;        %initializing variable for chordwise points
m=0;        %initializing variable for spanwise points
fprintf('Please choose type of Grid:\n 1. Coarse\n 2. Medium\n 3. Fine\n 4. Super fine\n');
i=0;
while(i==0)
    grid=input('Please enter your choice:');   %choosing grid quality

    switch(grid)
        case 1
           n=5;
           m=13;
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
        z(i,1)=M*(2*P*x(i,1)/(n*delx1)-(x(i,1)/(n*delx1))^2)/P^2;         
    else
        z(i,1)=M*(1-2*P+2*P*x(i,1)/(n*delx1)-(x(i,1)/(n*delx1))^2)/(1-P)^2;
    end
    x(i,m+1)=a+(i-1)*delx2; % defining coordinates of wing tip
    y(i,m+1)=b+(i-1)*dely;
    z(i,m+1)=y(i,m+1)*sin(dih);
    if(sqrt((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)<P*sqrt((c-a)^2+(d-b)^2))                %for giving camber on tip
        z(i,m+1)=y(i,m+1)*sin(dih)+M*(2*P*sqrt((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/sqrt((c-a)^2+(d-b)^2)-((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/((c-a)^2+(d-b)^2))/P^2;
    else
        z(i,m+1)=y(i,m+1)*sin(dih)+M*(1-2*P+2*P*sqrt((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/sqrt((c-a)^2+(d-b)^2)-((x(i,m+1)-a)^2+(y(i,m+1)-b)^2)/((c-a)^2+(d-b)^2))/(1-P)^2;
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



%Aspect ratio
wingar=2*(areaquad(x(1,1),y(1,1),z(1,1),x(n+1,1),y(n+1,1),z(n+1,1),x(1,m+1),y(1,m+1),z(1,m+1),x(n+1,m+1),y(n+1,m+1),z(n+1,m+1))+areaquad(x(1,m+1),y(1,m+1),z(1,m+1),x(n+1,m+1),y(n+1,m+1),z(n+1,m+1),x(1,2*m+1),y(1,2*m+1),z(1,2*m+1),x(n+1,2*m+1),y(n+1,2*m+1),z(n+1,2*m+1)));
AR=aspectratio(wingar,b,d);

xun=x(n+1,1:2*m+1);
yun=y(n+1,1:2*m+1);
zun=z(n+1,1:2*m+1);

figure(1)
mesh(x,y,z);
videofr(1)=getframe;

%Influence coefficient calculation
[a,b,nor,coll]=infcoeffunsteady(x,y,z);

stepno=1;
for tstp=0:delt:tottime   
    
    %Time based Grid   
    clearvars gamaw xunt yunt zunt;
    for i=1:stepno-1
        gamaw((stepno-i-1)*2*m+1:(stepno-i)*2*m)=gama((n-1)*2*m+1:2*m*n,i);
    end
    xunt=x(n+1,1:2*m+1);
    yunt=y(n+1,1:2*m+1);
    zunt=z(n+1,1:2*m+1);
    if(stepno>1)
        for j=1:2*m+1
            for i=stepno:-1:2
                localv=locvelo(xun(i-1,j),yun(i-1,j),zun(i-1,j),tstp,vinf);
                localvww=velt(xun(i-1,j),yun(i-1,j),zun(i-1,j),x,y,z,gama(:,stepno-1),1);
                localvw=velt(xun(i-1,j),yun(i-1,j),zun(i-1,j),xun(1:stepno-1,:),yun(1:stepno-1,:),zun(1:stepno-1,:),gamaw,0);
                xunt(i,j)=xun(i-1,j)+(localv(1))*delt+localvww(1)+localvw(1))*delt;
                yunt(i,j)=yun(i-1,j)+(localv(2))*delt+localvww(2)+localvw(2))*delt;
                zunt(i,j)=zun(i-1,j)+(localv(3))*delt+localvww(3)+localvw(3))*delt;
            end
        end
    end
    clearvars xun yun zun;
    xun=xunt;
    yun=yunt;
    zun=zunt;
    

    
    %Calculation of RHS
    for i=1:n
        for j=1:2*m
            if(stepno>1)
                rhs(2*m*(i-1)+j)=-dot(locvelo(coll(i,1,j),coll(i,2,j),coll(i,3,j),tstp,vinf)+velt(coll(i,1,j),coll(i,2,j),coll(i,3,j),xun,yun,zun,gamaw,0),nor(i,:,j));
            else
                rhs(2*m*(i-1)+j)=-dot(locvelo(coll(i,1,j),coll(i,2,j),coll(i,3,j),tstp,vinf),nor(i,:,j));
            end
        end
    end
    if(stepno==1)
        rhs=rhs';
    end



    %Calculation of gama
    gama(:,stepno)=a\rhs;


    
    %Calculation of wind
    wind(:,stepno)=b*gama(:,stepno);



    %Lift and Pressure different calculation
    L(stepno)=0;
    
    if(stepno>1)
        for i=1:n
            for j=1:2*m
                if(i==1&&j~=1)
                    L(stepno)=L(stepno)+(rho*(dot(locvelo(coll(i,1,j),coll(i,2,j),coll(i,3,j),tstp,vinf)+velt(coll(i,1,j),coll(i,2,j),coll(i,3,j),xun,yun,zun,gamaw,0),([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno))/(norm([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)]))+([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j-1,stepno))/norm([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)]))+(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j,stepno-1))/delt))*areaquad(x(i,j),y(i,j),z(i,j),x(i+1,j),y(i+1,j),z(i+1,j),x(i+1,j+1),y(i+1,j+1),z(i+1,j+1),x(i,j+1),y(i,j+1),z(i,j+1));
                    continue;
                end
                if(j==1&&i~=1)
                    L(stepno)=L(stepno)+(rho*(dot(locvelo(coll(i,1,j),coll(i,2,j),coll(i,3,j),tstp,vinf)+velt(coll(i,1,j),coll(i,2,j),coll(i,3,j),xun,yun,zun,gamaw,0),([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-2)+j,stepno))/(norm([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)]))+([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno))/norm([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)]))+(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j,stepno-1))/delt))*areaquad(x(i,j),y(i,j),z(i,j),x(i+1,j),y(i+1,j),z(i+1,j),x(i+1,j+1),y(i+1,j+1),z(i+1,j+1),x(i,j+1),y(i,j+1),z(i,j+1));
                    continue;
                end 
                if(i==1&&j==1)
                    L(stepno)=L(stepno)+(rho*(dot(locvelo(coll(i,1,j),coll(i,2,j),coll(i,3,j),tstp,vinf)+velt(coll(i,1,j),coll(i,2,j),coll(i,3,j),xun,yun,zun,gamaw,0),([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno))/(norm([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)]))+([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno))/norm([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)]))+(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j,stepno-1))/delt))*areaquad(x(i,j),y(i,j),z(i,j),x(i+1,j),y(i+1,j),z(i+1,j),x(i+1,j+1),y(i+1,j+1),z(i+1,j+1),x(i,j+1),y(i,j+1),z(i,j+1));
                    continue;
                end
                L(stepno)=L(stepno)+(rho*(dot(locvelo(coll(i,1,j),coll(i,2,j),coll(i,3,j),tstp,vinf)+velt(coll(i,1,j),coll(i,2,j),coll(i,3,j),xun,yun,zun,gamaw,0),([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-2)+j,stepno))/(norm([x(i+1,j),y(i+1,j),z(i+1,j)]-[x(i,j),y(i,j),z(i,j)]))+([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)])*(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j-1,stepno))/norm([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)]))+(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j,stepno-1))/delt))*areaquad(x(i,j),y(i,j),z(i,j),x(i+1,j),y(i+1,j),z(i+1,j),x(i+1,j+1),y(i+1,j+1),z(i+1,j+1),x(i,j+1),y(i,j+1),z(i,j+1));
            end
        end
    else
        for i=1:n
            for j=1:2*m
                if(i==1)
                L(stepno)=L(stepno)+rho*norm(vinf)*gama(2*m*(i-1)+j,stepno)*(y(i,j+1)-y(i,j));
                else
                L(stepno)=L(stepno)+rho*norm(vinf)*(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-2)+j,stepno))*(y(i,j+1)-y(i,j));
                end
            end
        end
    end
    

 
    cl(stepno)=L(stepno)/(0.5*rho*norm(vinf)*wingar);


    %Drag Calculation
    D(stepno)=0;
    
    if(stepno>1)
        for i=1:n
            for j=1:2*m
                if(i==1)
                    ww=velt(coll(i,1,j),coll(i,2,j),coll(i,3,j),xun,yun,zun,gamaw,0);
                    D(stepno)=D(stepno)+rho*((wind(2*m*(i-1)+j)+ww(3))*gama(2*m*(i-1)+j,stepno)*norm([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)])+(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j,stepno-1))/delt*areaquad(x(i,j),y(i,j),z(i,j),x(i+1,j),y(i+1,j),z(i+1,j),x(i+1,j+1),y(i+1,j+1),z(i+1,j+1),x(i,j+1),y(i,j+1),z(i,j+1))*nor(i,3,j)/nor(i,1,j));
                else
                    D(stepno)=D(stepno)+rho*((wind(2*m*(i-1)+j)+ww(3))*(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-2)+j,stepno))*norm([x(i,j+1),y(i,j+1),z(i,j+1)]-[x(i,j),y(i,j),z(i,j)])+(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-1)+j,stepno-1))/delt*areaquad(x(i,j),y(i,j),z(i,j),x(i+1,j),y(i+1,j),z(i+1,j),x(i+1,j+1),y(i+1,j+1),z(i+1,j+1),x(i,j+1),y(i,j+1),z(i,j+1))*nor(i,3,j)/nor(i,1,j));
                end
            end
        end  
    else
        for i=1:n
            for j=1:2*m
                if(i==1)
                    D(stepno)=D(stepno)-rho*wind(2*m*(i-1)+j)*gama(2*m*(i-1)+j,stepno)*(y(i,j+1)-y(i,j));
                else
                    D(stepno)=D(stepno)-rho*wind(2*m*(i-1)+j)*(gama(2*m*(i-1)+j,stepno)-gama(2*m*(i-2)+j,stepno))*(y(i,j+1)-y(i,j));
                end
            end
        end
    end

    cd(stepno)=D(stepno)/(0.5*rho*norm(vinf)*wingar);
    
    if(stepno>1)
        x11=[x;xun];
        y11=[y;yun];
        z11=[z;zun];
        figure(stepno);
        mesh(x11,y11,z11);
        videofr(stepno)=getframe;
        clearvars x11 y11 z11;
    end
    stepno=stepno+1;    
end