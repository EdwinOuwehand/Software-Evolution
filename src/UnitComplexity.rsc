module UnitComplexity

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import ParseTree;

import List;
import Exception;
import util::FileSystem;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import Type;

// Creates AST
//24245
//M3 myModel2 = createM3FromEclipseProject(|project://hsqldb-2.3.1/hsqldb/src|);

//M3 myMethods = methods(myModel);


//ast = createAstsFromEclipseProject(|project://smallsql0.21_src|, true);
//int statments = (0 | it + 1 | /Statement _ := ast);
//int declarations = (0 | it + 1 | /Declaration _ := ast);

public void main() {
	M3 myModel = createM3FromEclipseProject(|project://smallsql0.21_src/src|);
	set[loc] methods = methods(myModel);
	
	// Use this for unit size
	//list[str] methodStr = [readFile(method) | method <- methods];

	
	set[MethodDec] allMethods(loc file) = {m | /MethodDec m := parse(#start[CompilationUnit], file)};
	
	lrel[int cc, loc method] maxCC(loc file) = [<cyclomaticComplexity(m), m@\loc> | m <- allMethods(file)];
	//list[int cc] maxCC(loc file) = [cyclomaticComplexity(m) | m <- allMethods(file)];
	
	ccRes = [*maxCC(f) | /file(f) <- crawl(|project://smallsql0.21_src/src|)];
	
	println(ccRes);
	// This is not accurate, it should be expressed not in amount of units, but the percentage of code that these
	// complex units take up.
	//println(size([x | x <- ccRes, x >= 1 && x <= 10]));
	//println(size([x | x <- ccRes, x >= 11 && x <= 20]));
	//println(size([x | x <- ccRes, x >= 21 && x <= 50]));
	//println(size([x | x <- ccRes, x > 50]));
		
	//list[int] ccList = [ cyclomaticComplexity(readFile(method)) | method <- methods];
	
	
	//println(methodStr);
	//println(ccList);
	
	//println([readFile(method) | method <- methods]);
	
	// myMethod.methodInvocation
	// methodAST = [createAst[readFile(method) | method <- methods]FromEclipseFile(method, model=myModel) | method <- methods];
	// methodAST = [readFile(method) | method <- methods]; // This is good for unit size
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
