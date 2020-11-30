/***
* Name: Assignment3_Task1
* Author: valeriaBladinieres and raulAznar
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Assignment3_Task1

/* Insert your model definition here */


global {
	int n <- 12;
	int i <- 0;
	list queens;
	
	init {
		create Queen number: n{
			posx <- (100/n)/2 +(100/n)*i;
			i <- i+1;
			add self to: queens;
			counter <- queens index_of self;
		}
		create dontGo number: n;
	}
}
species Queen skills: [fipa, moving] { 
	rgb myColor <- #blue;
	float posx <- 0.0;
	float posy <- 0.0;
	bool fi;
	bool fristT;
	
	matrix mat <- 0 as_matrix({n,n}); 
	matrix matF <- 0 as_matrix({n,n}); 
	list pMove1<- [];
	list pFreeMoves<- [];
	list pFreeMoves2<- [];
	list cpos;
	bool turn <- false;
	bool ret <- false;
	int counter;
	
	reflex justFirst when: counter = 0 and fi= false{
		loop j from:0 to:n-1{
				add [0,j] to: pMove1;
		}
		write "Moves 1st Queen: "+ pMove1;
		write "------";
		cpos <- first(pMove1);
		remove first(pMove1) from: pMove1;
		fi <- true;
		fristT <- true;
	}
	
	reflex recieve_possible_places when: !empty(informs) {
		turn <-true;
		loop mess over: informs {
			write name + ' receives message with these free spaces: ' + (string(mess.contents));
			write "Free Spaces available prev: "+ pFreeMoves;
			write "Is it a retrival? "+ mess.contents[1];
			ret <- bool(mess.contents[1]);
			if ret = false{
				pFreeMoves <- mess.contents[0] ;
			}
			if ret = true and counter =0{
				turn <-false;
				fristT <- true;
			}
			
		}
	}
	
	reflex check when: counter = 0 and fristT = true{
		write "===========";
		write "Current position " +name+" :"+cpos ;
		if ret = true{
			write "ya regreso y va a ir a siguiente";
			pFreeMoves <-[];
			ret <- false;
		 	mat <- 0 as_matrix({n,n}); 
			matF <- 0 as_matrix({n,n}); 
			write name;
			write pMove1;
			cpos <- first(pMove1);
			remove first(pMove1) from: pMove1;
		}
		if ret =false{
			loop j from: 0 to: n-1{
			loop k from:0 to:n-1{	
				if j = cpos[0]{
						mat[j,k] <- 9;
					}
					if k = cpos[1]{
						mat[j,k] <- 9;
					}
					if j=k{
						if (j + int(cpos[0])) < n and ( k + int(cpos[1])) < n {
							mat[j+int(cpos[0]),k+int(cpos[1])] <- 9;
						}
					}
					if j = n -1-k {
						int ro<-  k-n+1;
						if ((j + int(cpos[0]) < n) and (ro + int(cpos[1]) >=0) ){
							mat[j+int(cpos[0]),ro+ int(cpos[1])] <- 9;
						}
					}
				}
			}
			loop j from:int(cpos[0]) to:n-1{
				loop k from:0 to:n-1{	
					matF[j,k] <- mat[j,k];
					if matF[j,k] = 0{
						add [j,k] to:pFreeMoves;
					}
				}
			}
			
			matF[int(cpos[0]),int(cpos[1])] <- 4;
			write mat;
			write matF;
			
			write "Next: "+ queens[counter+1];
			write "With these free spaces: "+pFreeMoves;
			do start_conversation with: [ to :: queens[counter+1], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [pFreeMoves,false]];
			
			write"************";
			fristT <-false;
			
			//change from matrix to positions real in GUI
			if cpos[1] = 0{
				posy <- (100/n)/2*(float(cpos[1])+1);
			}
			else{
				posy <- (100/n)/2+(100/n)*(float(cpos[1]));
			}
		}
	}
	
	reflex check_diagonals when: turn = true{
		
		if ret = false{
			loop p over: pFreeMoves{
				if p[0] = counter{
					add p to:pMove1; 
				}
			}
		}
		write "Possible positions:" +pMove1 ; 
		if ret = true{
			write "ya regreso y va a ir a siguiente";
			pFreeMoves2 <-[];
			ret <- false;
			mat <- 0 as_matrix({n,n}); 
			matF <- 0 as_matrix({n,n}); 
		}
		if  empty(pMove1){
			write "have to infrom previous";
			turn <-false;
			write queens[counter-1];
			do start_conversation with: [ to :: queens[counter-1], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [[], true]];
			write"************";
		}
		if  ret = false and !empty(pMove1) {
			cpos <- first(pMove1);
			remove first(pMove1) from: pMove1;
			write "Current position "+name+": "+cpos;
			write "Have other options as: " + pMove1;
			
			//check diagonals
			loop j from: 0 to: n-1{
				loop k from:0 to:n-1{	
					if j = cpos[0]{
						mat[j,k] <- 9;
					}
					if k = cpos[1]{
						mat[j,k] <- 9;
					}
					if j=k{
						if (j + int(cpos[0])) < n and ( k + int(cpos[1])) < n {
							mat[j+int(cpos[0]),k+int(cpos[1])] <- 9;
						}
					}
					if j = n -1-k {
						int ro<-  k-n+1;
						if ((j + int(cpos[0]) < n) and (ro + int(cpos[1]) >=0) ){
							mat[j+int(cpos[0]),ro+ int(cpos[1])] <- 9;
						}
					}
					
				}
			}
			
			loop j from:int(cpos[0]) to:n-1{
				loop k from:0 to:n-1{	
					matF[j,k] <- mat[j,k];
					if matF[j,k] = 0 and pFreeMoves contains [j,k]{
						add [j,k] to:pFreeMoves2;
					}
				}
			}
			
			matF[int(cpos[0]),int(cpos[1])] <- 4;
			write mat;
			write matF;
			
			if counter = n-1{
				//let know it has found path
				write "Found Solution!!!!!!!!!!";
				turn <- false;
			}
			else{
				write queens[counter+1];
				write "Free place in common with prevoius: "+ pFreeMoves2;
				turn <- false;
				
				do start_conversation with: [ to :: queens[counter+1], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [pFreeMoves2,false]];
				write"************";
			
			}
			//change from matrix to positions real in GUI
			if cpos[1] = 0{
				posy <- (100/n)/2*(float(cpos[1])+1);
			}
			else{
				posy <- (100/n)/2+(100/n)*(float(cpos[1]));
			}
			
		}
		
	}
	
	aspect default{
		draw sphere((100/n)*0.2) at:{posx,posy,0} color: myColor;
	}
	
}

grid my_grid width: n height: n {
	bool colorDef;
	
	reflex color_grid when: colorDef = false {
		if 1 = (grid_x + grid_y) mod 2  {
			color <- #black;
		}
		colorDef <-true;
	}
}

species dontGo{
	
	aspect default{
		draw sphere((100/n)*0.1) at:{0,0,0} color: #red;
	}
}

experiment main type: gui {
	output{
		display map type: opengl{
			species Queen;
			species my_grid;
			species dontGo;
		}
	}
}
	