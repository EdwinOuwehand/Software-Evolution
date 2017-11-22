module UnitAnalysis

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import ParseTree;
import util::Math;

import List;
import Exception;
import util::FileSystem;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import Type;

import Volume;

private list[list[int]] scale = [[50, 20, 10, 0], [60, 40, 20, 0]]; // cc, size
private list[tuple[int, int]] analysedList;
private int UNIT_SIZE = 1;
private int UNIT_COMP = 0;

// Source: http://www.rascal-mpl.org/#_Metrics
public list[tuple[int, int]] analyseProject(loc project) {
	lrel[int cc, int uLoc] mapCC(loc file) 
		= [<cyclomaticComplexity(m), size(filterLines(readFileLines(m@\loc)))-1> | m <- allMethods(file)];
	// Subtract 1 from uloc, for function header.
	analysedList = [*mapCC(f) | /file(f) <- crawl(project), f.extension == "java"];
	
	return analysedList;
}

public list [int] mapScale (int volume, int s) {
	if(analysedList == []) throw "You must first analyse the project";

	list [int] result = [0,0,0,0];
	for (t <- analysedList) {
		for(i <- index(scale[s])) {
			if(t[s] > scale[s][i]){
				result[i] += t[1];
				break;
			}
		}
	}
	return reverse([percent(uloc, volume) | uloc <- result]);
}

public list [int] unitComplexity (int volume) {
	return mapScale(volume, UNIT_COMP);
}

public list [int] unitSize (int volume) {
	return mapScale(volume, UNIT_SIZE);
}

// Source: http://www.rascal-mpl.org/#_Metrics
public set[MethodDec] allMethods(loc file) = {m | /MethodDec m := parse(#start[CompilationUnit], file, allowAmbiguity=true)};

/**
  * Replace switch?
  * Source: http://www.rascal-mpl.org/#_Metrics
  */
public int cyclomaticComplexity(MethodDec m) {
	result = 1;
	visit (m) {
		case (Expr)`(<Expr _>)?<Expr _>:<Expr _>`: result += 1;
		case (Expr)`<Expr _>||<Expr _>`: result += 1;
		case (Expr)`<Expr _>&&<Expr _>`: result += 1;
		case (Stm)`do <Stm _> while (<Expr _>);`: result += 1;
	 	case (Stm)`while (<Expr _>) <Stm _>`: result += 1;
		case (Stm)`if (<Expr _>) <Stm _>`: result +=1;
		case (Stm)`if (<Expr _>) <Stm _> else <Stm _>`: result +=1;
		case (Stm)`for (<{Expr ","}* _>; <Expr? _>; <{Expr ","}*_>) <Stm _>` : result += 1;
		case (Stm)`for (<LocalVarDec _> ; <Expr? e> ; <{Expr ","}* _>) <Stm _>`: result += 1;
		case (Stm)`for (<FormalParam _> : <Expr _>) <Stm _>` : result += 1;
		case (SwitchLabel)`case <Expr _> :` : result += 1;
		case (CatchClause)`catch (<FormalParam _>) <Block _>` : result += 1;
	}
	return result;
}
