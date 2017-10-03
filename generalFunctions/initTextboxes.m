function vr = initTextboxes(vr,nTextBoxes)

cmap = lines(nTextBoxes);
for k = 1:nTextBoxes
%initialize text boxes
vr.text(k).string = '';
vr.text(k).position = [1 1-(k*0.1)];
vr.text(k).size = .03;
vr.text(k).color = cmap(k,:);
end