function out=mysqrt(in)

    a=real(in);
    b=imag(in);
    
    y=((-a+abs(in))/2)^0.5;
    x=b/(2*y);
    
    out=x+1i*y;

end