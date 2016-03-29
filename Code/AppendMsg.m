function AppendMsg(obj,msg)
    oldmsg=get(obj,'String');
    appmsg=[datestr(now,'HH:MM - '),msg];
    if isempty(oldmsg)
        newmsg=appmsg;
    else
        newmsg=[appmsg,char(13),oldmsg];
    end
    set(obj,'String',newmsg);
    drawnow; % Refresh GUI
end