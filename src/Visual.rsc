module Visual

import vis::Figure;
import vis::Render;
import IO;
import util::Math;


public void handleClick(str algType, str project) 
{
	println(algType);
	println(project);
	
	
}

public Figure cloneClass(list[rel[str, int]] class) 
{
	rel[str, int] example = head(class);
	
	//str example =

	return vcat([	text()
	], resizable(false, false), gap(20));
}

public Figure paramSelection() 
{
	str algType = "Type-1";
	str selProject = "smallsql";
	
  	return vcat([ 	combo(["Type-1", "Type-2", "Type-3"], 	void(str s){ algType = s; }),
                	combo(["smallsql", "hsqldb"], 			void(str s){ selProject = s; }),
                	button("Analyse Project", 				void(){ handleClick(algType, selProject); }, 
                											hsize(200), resizable(false, false))
              ], resizable(false, false), gap(20));
}

public void main()
{
	render("Menu", paramSelection());
}
