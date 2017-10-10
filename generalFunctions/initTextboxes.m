function vr = initTextboxes(vr,nTextBoxes)

cmap = repmat([1 1 0],nTextBoxes,1);%lines(nTextBoxes);
for k = 1:nTextBoxes
%initialize text boxes
vr.text(k).string = '';
vr.text(k).position = [0.8 1-(k*0.1)];
vr.text(k).size = .04;
vr.text(k).color = cmap(k,:);
end