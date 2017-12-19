module Series2::Visual

import IO;

import vis::Figure;
import vis::Render;
import vis::KeySym;

import util::Math;
import util::Editors;
import util::ValueUI;

import DateTime;
import Set;
import List;
import Type;
import String;
import Map;

import Series2::Main;

private set[lrel[loc,int]] duplicationLines = {};
private int volume = 0;
private list[str] biggestClone = [];

public void setVolume (int vol) {
	volume = vol;
}

public void handleClick(str project, list[bool] settings, list[str] gapThresh) 
{
	datetime begin = now();
	
	println("Configuration:");
	println("-----");
	println("Project <project>");
	if (gapThresh[0] != "0") {
		println("Type-3 clone detection with gap size <gapThresh[0]>");
	} else {
		if (settings[0] || settings[1] || settings[2] || settings[3]) {
			println("Type-2 with differences allowed in: ");
			if(settings[0]){ println("- variable identifiers ");}
			if(settings[1]){ println("- method identifiers ");}
			if(settings[2]){ println("- literals ");}
			if(settings[3]){ println("- data types ");}
		} else {
			println("Type-1 clone detection");
		}
	}
	println("Clone threshold: <gapThresh[1]> lines");
	
	map[list[str], set[lrel[loc,int]]] result = ();
	loc dir;
	
	if (project == "test") {
		dir = |project://Software-Evolution/test/benchmarkFiles/duplication|;
	} else if (project == "smallsql") {
		dir = |project://smallsql0.21_src|;
	} else if (project == "hsqldb") {
		dir = |project://hsqldb|;
	}
	
	result = run(dir, settings[0], settings[1], settings[2], settings[3],
				 toInt(gapThresh[1]), toInt(gapThresh[0]));
	
	println("-----");
	println("Number of clones: <countClones(result)>");
	println("Number of clone classes: <size(result)>");
	
	lrel[loc,int]location = getOneFrom(result[biggestClone]);
	println("Biggest clone found (<size(biggestClone)> lines long) is located in <head(location)[0]>:");
	println(biggestClone);
	println("-----");
	
	
	int dupLines = getNumberDupLines(duplicationLines);
	println("Total duplication: <dupLines> of <volume> lines of code (<percent(dupLines, volume)>%)");
	Duration time = (now()-begin);
	println("Time taken: <time.hours> hours, <time.minutes> minutes, <time.seconds> seconds, <time.milliseconds> milliseconds");
		
	text(result); 
	showResult(project, persistData(result));

	
	
}
public int getNumberDupLines (set[lrel[loc,int]] dups) {
	list[lrel[loc,int]] lineList = toList(dups);
	set[tuple[loc,int]] lines = {};
	for(int i <- index(lineList)) {
		lines += toSet(lineList[i]);
	}
	return size(lines);
}

public int countClones (map[list[str], set[lrel[loc,int]]] cloneClasses) {
	duplicationLines = {};
	int n = 0;
	list[str] biggestClone = [];
	tuple[list[str], set[lrel[loc,int]]] biggestClass = <[],{}>;
	set[lrel[loc,int]] dupLines = {};
	
	cloneClassesList = toList(cloneClasses);
	for(int i <- index(cloneClassesList)) {
		n += size(cloneClassesList[i][1]);
		dupLines = dupLines + cloneClassesList[i][1];
	
		if (size(cloneClassesList[i][0]) > size(biggestClone)) {
			biggestClone = cloneClassesList[i][0];
		}
		
		if(size(cloneClassesList[i][1]) > size(biggestClass[1])) {
			biggestClass = cloneClassesList[i];
		}
	}
	setBiggestClone(biggestClone);
	printBiggestClass(biggestClass);
	duplicationLines = dupLines;
	return n;
}

public void setBiggestClone(list[str] clone) {
	biggestClone = clone;
}

public void printBiggestClass(tuple[list[str], set[lrel[loc,int]]] cloneClass) {
	println("Biggest clone class:");
	iprintln(cloneClass);
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
		int duplicatedLines = size(dup(file[2]));
		str message = file[0].file + "has a total of <duplicatedLines> duplicated lines, "
			+ "\nwhich is <percent(duplicatedLines, file[1])>% of the file.";
		
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
	
  	return grid([ 	
  		[text("Clone detection settings", fontSize(16), left())],							
       	[text("Clone size threshold: ", left())],
        	[combo(["6", "3", "4", "5", "6", "7", "8", "9", "10"], 	void(str t){ gapThresh[1] = t; }, left())],
        	[text("Project: ", fontSize(14), left())], 
        	[combo(["smallsql", "hsqldb", "test"], 				void(str s){ selProject = s; }, left())],
			    [text("")],            										
  		[text("Type-1: Exact copy", fontSize(16), left())],
  		[text("Ignoring whitespace and comments, formatted brackets (included by default)", left())],
				[text("")],            										
	  	[text("Type-2: Syntactical copy", fontSize(16), left())],
	  	[text("Type-1 + options to allow certain differences", left())],
	 	[text("Ignore:", fontSize(14), left())], 	
		[checkbox("Variable identifiers", 		void(bool s){ settings[0] = s; }, left())],
		[checkbox("Method identifiers",			void(bool s){ settings[1] = s; }, left())],
		[checkbox("Literals", 					void(bool s){ settings[2] = s; }, left())],
		[checkbox("Data types", 					void(bool s){ settings[3] = s; }, left())],
			    [text("")],            										
  	  	[text("Type-3: Copy with differences", fontSize(16), left())],	
	  	[text("Type-1 + optional Type-2 settings. Allow changed, removed or added lines", left())],				
		[text("Number of different lines: ", fontSize(14), left())], 
		[combo(["0", "1", "2", "3", "4", "5"], 				void(str g){ gapThresh[0] = g; }, left())],
        	[button("Analyse project", 				void(){ handleClick(selProject, settings, gapThresh); }, 
			hsize(200), resizable(false, false))]
  	], resizable(false, false), gap(5), left());


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
