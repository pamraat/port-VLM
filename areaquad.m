function [ar]=areaquad(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4)
r(1,:)=[x1 y1 z1];
r(2,:)=[x2 y2 z2];
r(3,:)=[x3 y3 z3];
r(4,:)=[x4 y4 z4];
r(5,:)=r(1,:);

s=0;
for i=1:4
    a(i)=norm(r(i+1,:)-r(i,:));
    s=s+a(i);
end
s=s/2;
ar=1;
for i=1:4
ar=ar*(s-a(i));
end
ar=sqrt(ar);