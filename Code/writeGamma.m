function writeGamma(filename, data, freq)

    fid=fopen(filename,'Wt');
    L=length(freq);
    % Slow method
    for f = 1:L
        fprintf(fid,'%10.8e   %5.8e   %5.8e\n', freq(f), abs(data(f)), ang(data(f)));
    end
    fclose(fid);
end

