function writeSP(filename, data, freq)

    fid=fopen(filename,'Wt');
    fprintf(fid,'! Multiline TRL de-embedded results \n');
    fprintf(fid,'! Powered by MTRL v0.1 based on Matlab. Written by Simon.\n');
    fprintf(fid,[ '! ',datestr(now,'dd-mmm-yyyy HH:MM:SS') '\n']);
    fprintf(fid,'# hz S ma R 50\n');
    L=length(freq);
    % Slow method
    for f = 1:L
        %disp(['Handling S-parameters ' int2str(f)])
        S=data(:,:,f); % Modified from S=data(:,:,f).' by Simon, 2015.3.9
        fprintf(fid,'%9.0f   ', freq(f));
        for i=1:numel(S)
            if mod(i-1,4)==0  && i~=1
                fprintf(fid, '                    '); 
            end
            fprintf(fid,'%10.8e    %10.8e    ',abs(S(i)),phase(S(i))/pi*180);
            if mod(i,4)==0 
                fprintf(fid,'\n'); 
            end
        end
    end
    fclose(fid);
end

