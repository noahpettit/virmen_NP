function [vr, hash] = getGitHash(vr)

P = mfilename('fullpath');
[~,hash] = system(['git -C ' P ' rev-parse HEAD']);

vr.session.hash = hash;






