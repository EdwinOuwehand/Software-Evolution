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
import String;

import Series2::Main;


public void handleClick(str project, list[bool] settings, list[str] gapThresh) 
{
	println(project);
	map[list[str], set[lrel[loc,int]]] result = ();
	loc dir;
	
	if (project == "test") {
		dir = |project://Software-Evolution/test/benchmarkFiles/duplication|;
	} else if (project == "smallsql") {
		dir = |project://smallsql0.21_src|;
	} else if (project == "hsqldb") {
		dir = |project://hsqldb-2.3.1|;
	}
	
	result = run(dir, settings[0], settings[1], settings[2], settings[3],
		(toInt(gapThresh[0]) != 0), toInt(gapThresh[1]), toInt(gapThresh[0]));
	
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
	list[str] gapThresh = ["0", "6"];
	list[bool] settings = [false, false, false, false];
	
  	return grid([ 	[text("Type-1: Gap size 0 and no other settings checked.", left())],
				  	[text("Type-2: Gap size 0 and one ore more settings checked.left()", left())],
				  	[text("Type-3: Gap size greater than 0.", left())],
  					[checkbox("Variable identifiers", 		void(bool s){ settings[0] = s; })],
  					[checkbox("Method identifiers", 		void(bool s){ settings[1] = s; })],
  					[checkbox("Literals", 					void(bool s){ settings[2] = s; })],
  					[checkbox("Data types", 				void(bool s){ settings[3] = s; })],
  					[text("Gap Size: "), combo(["0", "1", "2", "3", "4", "5"], 				void(str g){ gapThresh[0] = g; })],
                	[text("Threshold: "), combo(["3", "4", "5", "6", "7", "8", "9", "10"], 	void(str t){ gapThresh[1] = t; })],
                	[text("Project: "), combo(["smallsql", "hsqldb", "test"], 				void(str s){ selProject = s; })],
                	[button("Analyse Project", 				void(){ handleClick(selProject, settings, gapThresh); }, 
                											hsize(200), resizable(false, false))]
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
