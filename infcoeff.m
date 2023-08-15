function [a,b,nor]=infcoeff(x,y,z,aoa)
n=size(x,1)-1;
m=(size(x,2)-1)/2;
for i=1:n
for j=1:2*m
    if(i~=n)
    h(i,:,j)=[x(i,j)+(x(i+1,j)-x(i,j))/4 y(i,j)+(y(i+1,j)-y(i,j))/4 z(i,j)+(z(i+1,j)-z(i,j))/4];
    h(i+1,:,j)=[x(i+1,j)+(x(i+2,j)-x(i+1,j))/4 y(i+1,j)+(y(i+2,j)-y(i+1,j))/4 z(i+1,j)+(z(i+2,j)-z(i+1,j))/4];
    h(i,:,j+1)=[x(i,j+1)+(x(i+1,j+1)-x(i,j+1))/4 y(i,j+1)+(y(i+1,j+1)-y(i,j+1))/4 z(i,j+1)+(z(i+1,j+1)-z(i,j+1))/4];
    h(i+1,:,j+1)=[x(i+1,j+1)+(x(i+2,j+1)-x(i+1,j+1))/4 y(i+1,j+1)+(y(i+2,j+1)-y(i+1,j+1))/4 z(i+1,j+1)+(z(i+2,j+1)-z(i+1,j+1))/4];
    h32=h(i,:,j+1)-h(i+1,:,j);
    h41=h(i+1,:,j+1)-h(i,:,j);
    coll(i,:,j)=(h(i,:,j)+h(i+1,:,j+1)+h(i+1,:,j)+h(i,:,j+1))/4;
    nor(i,:,j)=cross(h41,h32)/norm(cross(h41,h32));
    else
    h(n+1,:,j)=[x(n+1,j)+(x(n+1,j)-x(n,j))/4 y(n+1,j)+(y(n+1,j)-y(n,j))/4 z(n+1,j)+(z(n+1,j)-z(n,j))/4];
    h(n+1,:,j+1)=[x(n+1,j+1)+(x(n+1,j+1)-x(n,j+1))/4 y(n+1,j+1)+(y(n+1,j+1)-y(n,j+1))/4 z(n+1,j+1)+(z(n+1,j+1)-z(n,j+1))/4];
    h32=h(n,:,j+1)-h(n+1,:,j);
    h41=h(n+1,:,j+1)-h(n,:,j);
    coll(i,:,j)=(h(n,:,j)+h(n+1,:,j+1)+h(n,:,j+1)+h(n+1,:,j))/4;
    nor(i,:,j)=cross(h41,h32)/norm(cross(h41,h32));
    end
end
end
for i=1:n
for j=1:2*m
    for k=1:n
    for l=1:2*m
        if(k~=n)
        [v,vw]=vortring(h(k,1,l),h(k,2,l),h(k,3,l),h(k+1,1,l),h(k+1,2,l),h(k+1,3,l),h(k+1,1,l+1),h(k+1,2,l+1),h(k+1,3,l+1),h(k,1,l+1),h(k,2,l+1),h(k,3,l+1),coll(i,1,j),coll(i,2,j),coll(i,3,j),1);
        else
        const=10^100;
        [v,vw]=vortring(h(k,1,l),h(k,2,l),h(k,3,l),h(k+1,1,l),h(k+1,2,l),h(k+1,3,l),h(k+1,1,l+1),h(k+1,2,l+1),h(k+1,3,l+1),h(k,1,l+1),h(k,2,l+1),h(k,3,l+1),coll(i,1,j),coll(i,2,j),coll(i,3,j),1);
        vw1=vw;
        v1=v;
        [v,vw]=vortring(h(k+1,1,l),h(k+1,2,l),h(k+1,3,l),h(k+1,1,l)+const,h(k+1,2,l),h(k+1,3,l)+const*tan(aoa),h(k+1,1,l+1)+const,h(k+1,2,l+1),h(k+1,3,l+1)+const*tan(aoa),h(k+1,1,l+1),h(k+1,2,l+1),h(k+1,3,l+1),coll(i,1,j),coll(i,2,j),coll(i,3,j),1);
        v=v+v1;
        vw=vw+vw1;
        end
        a(2*m*(i-1)+j,2*m*(k-1)+l)=dot(v,nor(i,:,j));
        b(2*m*(i-1)+j,2*m*(k-1)+l)=dot(vw,nor(i,:,j));
    end
    end
end
end