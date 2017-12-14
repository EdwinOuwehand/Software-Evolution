module Series2::Visual

import IO;

import vis::Figure;
import vis::Render;
import vis::KeySym;

import util::Math;
import util::Editors;

import Set;
import List;
import Type;

import Series2::Main;


public void handleClick(str project, list[bool] settings) 
{
	println(project);
	map[list[str], set[lrel[loc,int]]] result = ();
	
	result 
		= run(|project://Software-Evolution/test/benchmarkFiles/duplication|, settings[0], settings[1], settings[2], settings[3], settings[4], 6, 0);
	
	//result = (
	//["abc","def"] : { [<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 5>],
	//[<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 6>] }, 
	//["abd","dgf"] : { [<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 7>],
	//[<|project://Software-Evolution/test/benchmarkFiles/filtered/Strings.java|, 8>] });

	
	showResult(project, persistData(result));
}

public void showResult(str title, list[tuple[loc, int, list[int]]] filesAndData) 
{
	outls = [];
	for (file <- filesAndData) {
		loc tmp = file[0];
		FProperty onClickEvent = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) { 
			edit(tmp);
			return true; 
		});
		str message = file[0].file + "has a total of <size(file[2])> duplicated lines, "
			+ "\nwhich is <percent(size(file[2]), file[1])>% of the file.";
		
		FProperty popup = mouseOver(box(text(message), fillColor("lightyellow"), grow(1.2),resizable(false)));
		warns = [ warning(line, "Duplicated Line") | line <- file[2] ];
		num height = (file[1] > 200) ? 200 : file[1];
		
		outls = outls + grid([ [outline(warns, file[1], [size(50, height), onClickEvent, popup, shadow(true)])], [text(file[0].file)] ]);
	}
	render("Result: " + title, pack(outls, std(gap(20))));
}

public Figure paramSelection() 
{
	str selProject = "smallsql";
	list[bool] settings = [false, false, false, false, false];
	
  	return vcat([ 	combo(["Type-1", "Type-2", "Type-3"], 	void(str s){ println(s); }),
  					checkbox("Variable identifiers", 		void(bool s){ settings[0] = s; }),
  					checkbox("Method identifiers", 			void(bool s){ settings[1] = s; }),
  					checkbox("Literals", 					void(bool s){ settings[2] = s; }),
  					checkbox("Data types", 					void(bool s){ settings[3] = s; }),
  					text("Gap Size"),
  					combo(["6", "7", "8"], 					void(str g){ println(g); }),
                	combo(["smallsql", "hsqldb"], 			void(str s){ selProject = s; }),
                	button("Analyse Project", 				void(){ handleClick(selProject, settings); }, 
                											hsize(200), resizable(false, false))
              ], resizable(false, false), gap(20));
}

public list[tuple[loc, int, list[int]]] persistData (map[list[str], set[lrel[loc,int]]] scanResult)
{
	list[tuple[loc, int, list[int]]] res = [];
	
	resAsList = [ *toList(scanResult[el]) | el <- scanResult ];
	list[tuple[loc, int, list[int]]] uFiles = dup([ <el[0][0], 0, []>| el <- resAsList ]);
	uFiles = [ <f[0], size(readFileLines(f[0])), f[2]> | f <- uFiles ];
		
	for (block <- resAsList, line <- block, i <- index(uFiles)) {
		if(uFiles[i][0] == line[0]) {
			uFiles[i][2] = uFiles[i][2] + line[1];
		}
	}
	return uFiles;
}

public void main() { render("Menu", paramSelection()); }
