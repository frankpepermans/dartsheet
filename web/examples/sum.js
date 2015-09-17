Cell(C:D, 1:3)
.subscribe(x => onvalue(x.reduce((p, c) => Number(p) + Number(c))))