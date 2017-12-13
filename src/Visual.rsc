module Visual

import vis::Figure;
import vis::Render;
import IO;
import util::Math;
import vis::KeySym;
import Set;
import List;
import Type;
import util::Editors;


public void handleClick(str algType, str project) 
{
	println(algType);
	println(project);
	
	showResult(project, persistData(result));
}

public void showResult(str title, list[tuple[loc, int, list[int]]] filesAndData) 
{
	outls = [];
	for (file <- filesAndData) {
		onClickEvent = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { 
			edit(file[0]);
			return true; 
		});
		warns = [ warning(line, "Duplicated Line") | line <- file[2] ];
		println(file[1]);
		num height = (file[1] > 200) ? 200 : file[1];
		outls = outls + outline(warns, file[1], size(50, height), onClickEvent);
	}
	render("Result: " + title, pack(outls, std(gap(20))));
}

public Figure paramSelection() 
{
	str algType = "Type-1";
	str selProject = "smallsql";
	
  	return vcat([ 	combo(["Type-1", "Type-2", "Type-3"], 	void(str s){ algType = s; }),
  					checkbox("Variable identifiers", 		void(bool s){ println(s); }),
  					checkbox("Method identifiers", 			void(bool s){ println(s); }),
  					checkbox("Literals", 					void(bool s){ println(s); }),
  					checkbox("Data types", 					void(bool s){ println(s); }),
  					text("Gap Size"),
  					combo(["6", "7", "8"], void(str g){ println(g); }),
  					
                	combo(["smallsql", "hsqldb"], 			void(str s){ selProject = s; }),
                	button("Analyse Project", 				void(){ handleClick(algType, selProject); }, 
                											hsize(200), resizable(false, false))
              ], resizable(false, false), gap(20));
}

public list[tuple[loc file, int totalLines, list[int] dupLines]] persistData (map[list[str], set[lrel[loc,int]]] scanResult)
{
	list[tuple[loc file, int totalLines, list[int] dupLines]] res = [];
	
	resAsList = [ *toList(scanResult[el]) | el <- scanResult ];
	list[tuple[loc, int, list[int]]] uFiles = dup([ <el[0][0], 0, []>| el <- resAsList ]);
	uFiles = [ <f[0], size(readFileLines(f[0])), f[2]> | f <- uFiles ];
	
	for (block <- resAsList) {
		for (line <- block) {
			for(i <- index(uFiles)) {
				if(uFiles[i][0] == line[0]) {
					uFiles[i][2] = uFiles[i][2] + line[1];
				}
			}
		}
	}

	return uFiles;
}

public void main()
{
	result = (
	["abc","def"] : { [<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 5>],
	[<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 6>] }, 
	["abd","dgf"] : { [<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 7>],
	[<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 8>] });
	
	render("Menu", paramSelection());
}

private map[list[str], set[lrel[loc,int]]] result; 

