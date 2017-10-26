function mouseID = makeMouseID_virmen(vr)

mouseID = [getMousePrefix(eval(vr.exper.variables.prefix)) sprintf('%03i', eval(vr.exper.variables.mouseID))];