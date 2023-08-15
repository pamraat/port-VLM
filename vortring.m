function [v,vw]=vortring(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4,x,y,z,gama)
r(1,:)=[x1 y1 z1];      %Position vector of corner
r(2,:)=[x2 y2 z2];     
r(3,:)=[x3 y3 z3];     
r(4,:)=[x4 y4 z4];     
a=[x y z];              %Position vector of concerned point

for i=1:4      
r(i,:)=a-r(i,:);        %Changing coordinate system to line frame
end
r(5,:)=r(1,:);

for i=1:4               
l(i,:)=r(i+1,:)-r(i,:); %Generating length vector
end

v=0;
vw=0;

for i=1:4               %Finding velocity using Biot Svart Law
if(norm(cross(r(i,:),r(i+1,:)))<1e-6)
    continue;
end
b(i,:)=cross(r(i,:),r(i+1,:))*dot(l(i,:),(r(i,:)/norm(r(i,:))-r(i+1,:)/norm(r(i+1,:))))/(4*pi*(norm(cross(r(i,:),r(i+1,:))))^2);
v=v+b(i,:);
if(i==1||i==3)
bw(i,:)=cross(r(i,:),r(i+1,:))*dot(l(i,:),(r(i,:)/norm(r(i,:))-r(i+1,:)/norm(r(i+1,:))))/(4*pi*(norm(cross(r(i,:),r(i+1,:))))^2);
vw=vw+bw(i,:);
end
end

v=gama*v;
vw=gama*vw;

