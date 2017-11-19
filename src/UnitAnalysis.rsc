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

public void execute() {
	real volume = 24040.; // Stub ? 24245
	
	// Inspired by: http://www.rascal-mpl.org/#_Metrics
	set[MethodDec] allMethods(loc file) = {m | /MethodDec m := parse(#start[CompilationUnit], file)};
	lrel[int cc, int uLoc] mapCC(loc file) 
		= [<cyclomaticComplexity(m), size(filterLines(readFileLines(m@\loc)))> | m <- allMethods(file)];
	
	list[tuple[int, int]] ccRes = [*mapCC(f) | /file(f) <- crawl(|project://smallsql0.21_src/src|)];
	
	println("-----------------");
	println("Unit size (Low to High)");
	println("-----------------");
	printUnitSize(ccRes, volume);
	
	println("-----------------");
	println("CC per Unit (Low to High)");
	println("-----------------");
	printCCperUnit(ccRes, volume);
	
	println("");
}

public void averageUnitSize(list[tuple[int, int]] ccRes, real volume){
	println( toReal(sum([uloc | <cc, uloc> <- ccRes])) / toReal(size(ccRes)) );
}

public void printUnitSize(list[tuple[int, int]] ccRes, real volume) {
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, uloc >= 0 && uloc <= 10]), 0.1 ));
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, uloc >= 11 && uloc <= 30]), 0.1 ));
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, uloc >= 31 && uloc <= 50]), 0.1 ));
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, uloc > 50]), 0.1 ));
}

public void printCCperUnit(list[tuple[int, int]] ccRes, real volume) {
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, cc >= 1 && cc <= 10]), 0.1 ));
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, cc >= 11 && cc <= 20]), 0.1 ));
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, cc >= 21 && cc <= 50]), 0.1 ));
	println( round( sum([(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, cc > 50]), 0.1 ));
}

// Source: http://www.rascal-mpl.org/#_Metrics
public int cyclomaticComplexity(MethodDec m) {
	result = 1;
	visit (m) {
		case (Stm)`do <Stm _> while (<Expr _>);`: result += 1;
	 	case (Stm)`while (<Expr _>) <Stm _>`: result += 1;
		case (Stm)`if (<Expr _>) <Stm _>`: result +=1;
		case (Stm)`if (<Expr _>) <Stm _> else <Stm _>`: result +=1;
		case (Stm)`for (<{Expr ","}* _>; <Expr? _>; <{Expr ","}*_>) <Stm _>` : result += 1;
		case (Stm)`for (<LocalVarDec _> ; <Expr? e> ; <{Expr ","}* _>) <Stm _>`: result += 1;
		case (Stm)`for (<FormalParam _> : <Expr _>) <Stm _>` : result += 1;
		case (Stm)`switch (<Expr _> ) <SwitchBlock _>`: result += 1;
		case (SwitchLabel)`case <Expr _> :` : result += 1;
		case (CatchClause)`catch (<FormalParam _>) <Block _>` : result += 1;
	}
	return result;
}
