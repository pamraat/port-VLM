function v=velt(x0,y0,z0,x,y,z,gama,che)

n=size(x,1)-1;
m=(size(x,2)-1)/2;
if(che==1)
    for i=1:n
    for j=1:2*m
        if(i~=n)
        h(i,:,j)=[x(i,j)+(x(i+1,j)-x(i,j))/4 y(i,j)+(y(i+1,j)-y(i,j))/4 z(i,j)+(z(i+1,j)-z(i,j))/4];
        h(i+1,:,j)=[x(i+1,j)+(x(i+2,j)-x(i+1,j))/4 y(i+1,j)+(y(i+2,j)-y(i+1,j))/4 z(i+1,j)+(z(i+2,j)-z(i+1,j))/4];
        h(i,:,j+1)=[x(i,j+1)+(x(i+1,j+1)-x(i,j+1))/4 y(i,j+1)+(y(i+1,j+1)-y(i,j+1))/4 z(i,j+1)+(z(i+1,j+1)-z(i,j+1))/4];
        h(i+1,:,j+1)=[x(i+1,j+1)+(x(i+2,j+1)-x(i+1,j+1))/4 y(i+1,j+1)+(y(i+2,j+1)-y(i+1,j+1))/4 z(i+1,j+1)+(z(i+2,j+1)-z(i+1,j+1))/4];
        else
        h(n+1,:,j)=[x(n+1,j)+(x(n+1,j)-x(n,j))/4 y(n+1,j)+(y(n+1,j)-y(n,j))/4 z(n+1,j)+(z(n+1,j)-z(n,j))/4];
        h(n+1,:,j+1)=[x(n+1,j+1)+(x(n+1,j+1)-x(n,j+1))/4 y(n+1,j+1)+(y(n+1,j+1)-y(n,j+1))/4 z(n+1,j+1)+(z(n+1,j+1)-z(n,j+1))/4];
        end
    end
    end
    v=[0 0 0];
    for k=1:n
    for l=1:2*m
        v=v+vortring(h(k,1,l),h(k,2,l),h(k,3,l),h(k+1,1,l),h(k+1,2,l),h(k+1,3,l),h(k+1,1,l+1),h(k+1,2,l+1),h(k+1,3,l+1),h(k,1,l+1),h(k,2,l+1),h(k,3,l+1),x0,y0,z0,gama(l+(k-1)*2*m));
    end
    end
else
    v=[0 0 0];
    for k=1:n
    for l=1:2*m      
        v=v+vortring(x(k,l),y(k,l),z(k,l),x(k+1,l),y(k+1,l),z(k+1,l),x(k+1,l+1),y(k+1,l+1),z(k+1,l+1),x(k,l+1),y(k,l+1),z(k,l+1),x0,y0,z0,gama(l+(k-1)*2*m));
    end
    end
end