module Snippets

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import util::FileSystem;
import util::Math;

import util::ValueUI;

import Set;

import ParseTree;
import Exception;
//import List;
import Type;

public lrel[str, loc] methodsBasedOnM3() {
	M3 myModel = createM3FromEclipseProject(|project://smallsql0.21_src/src|);
	set[loc] methods = methods(myModel);
	return [<readFile(method), method> | method <- methods]; // Still works, ha!
	
	//return methodStr;
}

public void testAst() {
	set[Declaration] ast = createAstsFromEclipseProject(|project://fragment_smallsql|, true);
	
	visit(ast) {
		//////// case variables(a,b): exs += a;
		case simpleType(a): println("simpleType: <a.name> @ <a.src>");
		case variable(a, b): println("variable: <a>");
		case simpleName(a): println("simpleName: <a>");
		case method(a, b, c, d, e): println("method: <b> @ <e.src>");
		case number(a): println("number: <a>");
		case booleanLiteral(a): println("boolean: <a>");
		case stringLiteral(a): println("string: <a>");
		case characterLiteral(a): println("character: <a>");
		/////// case declarationStatement(a): println(a);
	}
}

public void totalDeclsAndStmts() {
	set[Declaration] ast = createAstsFromEclipseProject(|project://smallsql0.21_src|, true);
	
	println("Total decls:");
	println(declarations(ast));
	
	println("Total stmts:");
	println(statements(ast));
	
	return ast; 
}

public void averageUnitSize(list[tuple[int, int]] ccRes, real volume){
	println( toReal(sum([uloc | <cc, uloc> <- ccRes])) / toReal(size(ccRes)) );
}

public int declarations(set[Declaration] ast) {

	decls = [dec | dec <- ast, /Declaration _ := dec];

	return (0 | it + 1 | /Declaration _ := ast);
}

public int statements(set[Declaration] ast) {
	return (0 | it + 1 | /Statement _ := ast);
}
