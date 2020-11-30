/***
* Name: Project1
* Author: valeriabladinieres
* Description: Festival
* Tags: Tag1, Tag2, TagN
***/

model Project_HelloWorld

/* Insert your model definition here */


global {
	init
	{
		create InfoCenter number: 1{
			location <- {50, 50};
		}
		create Guest number: 40{
			trait <- flip(0.5) ? "Male" : "Female" ;
			if trait = "Male"{
			myColor <- #gray;
			}
			else{
				myColor <- #white;
			}
		}
		create Store number: 2{
			trait <- "Food";
		}
		create Store number: 2{
			trait <- "Drink";
		}
		create Bath number: 1{
			trait <- "Male";
		}
		create Bath number: 1{
			trait <- "Female";
		}
	bool foccupied <- false;
	bool moccupied <- false;
	}

}

species InfoCenter{
	
	list storesDrink;
	point locStoreD;
	list storesFood;
	point locStoreF;
	point BathM;
	point BathF;
	point securityLoc <- nil;
	
	
	reflex storeLoc when: length(storesDrink) < 2  or length(storesFood) < 2{
		ask Store {
			if (self.trait = "Drink"){
				myself.locStoreD <- self.location;
				add myself.locStoreD to: myself.storesDrink;
			}
			else{
				myself.locStoreF <- self.location;
				add myself.locStoreF to: myself.storesFood;	
			}
		}
	}
	
reflex BathLoc when: BathM = nil  or BathF = nil{
		ask Bath {
			if (self.trait = "Male"){
				myself.BathM <- self.location;
			}
			else{
				myself.BathF <- self.location;
			}
		}
	}	
	
	aspect default{
		draw pyramid(5) at: location color: #yellow;
		}
}

species Guest skills:[moving]{
	
	point targetPoint <- nil;
	bool hungry <- false;
	bool thirsty <- false;
	rgb myColor;
	bool good;
	bool reporting;
	bool getGuard; 
	bool notify;
	string mbathturn;
	string fbathturn;
	bool found;
	string trait;
	int ndrinks <- 0;
	int nfood <- 0;
	int timer1 <- 0;
	int timer2 <- 0;
	bool mbathb <- false;
	bool fbathb <- false;
	list bathqueuem;
	list bathqueuef;
	bool myturn<- false;
	int i<-1;
	
	
	reflex beIdle when: targetPoint = nil{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex state when: thirsty = false and (hungry = false and myColor != #black){
		int rand <- rnd(1000);
		if (rand = 1){
			thirsty <- true;
			myColor <- #yellow;
			ask InfoCenter {
				myself.targetPoint <- self.location;
				
			}
		}
		if (rand = 2){
			hungry <- true;
				myColor <- #yellow;
			ask InfoCenter {
				myself.targetPoint <- self.location;
			}
		}
		
	}
	
	
	reflex goPee when: ndrinks = 2 {
				ask InfoCenter{
					if myself.trait = "Male"{
						myself.targetPoint <- self.BathM;
						myself.myColor <- #orange;
					}
					else{
						myself.targetPoint <- self.BathF;
						myself.myColor <- #orange;
					}
				}
	}
	
	reflex goPoo when: nfood = 3 {
		ask InfoCenter{
			if myself.trait = "Male"{
				myself.targetPoint <- self.BathM;
				myself.myColor <- #brown;
				//write "Go to Poo!(Male)";
			}
			else{
				myself.targetPoint <- self.BathF;
				myself.myColor <- #brown;
				//write "Go to poo! (Female)";
			}
		}
	}
	

	
	reflex BusyBathM when: mbathb = true{
		ask Bath{
			if self.trait = 'Male'{
				if self.moccupied = false{
					if myself.name = first(self.bathqueuem) or length(self.bathqueuem) = 0{
						myself.myturn <- true;
						myself.mbathb <- false;
						myself.location <- self.location;
					}
					
				}
				else {
					int result <- self.bathqueuem index_of myself.name;
					myself.targetPoint <- self.location+{2+result,2+result,0};
				}
			}
		}
	}


		
	reflex BusyBathF when: fbathb = true{
		ask Bath{
			if self.trait = 'Female'{
				if self.foccupied = false{
					if myself.name = first(self.bathqueuef){
						myself.myturn <- true;
						myself.fbathb <- false;
						myself.location <- self.location;
					}
				}
				else {
					int result <- self.bathqueuef index_of myself.name;
					myself.targetPoint <- self.location+{2+result,2+result,0};
				}
			}
		}
	}	
	
	

	reflex enterStore when: targetPoint != nil and (location distance_to(targetPoint) < 2 and (mbathb = false and fbathb = false)) {
			
	
		
		if myColor != #gray and myColor != #white{
			if thirsty = true and myColor = #blue{
				if trait = "Male"{
					myColor <- #gray;
				}
				else{
					myColor <- #white;
				}
				thirsty <- false;
				ndrinks <- ndrinks + 1;
				targetPoint <- {rnd(100),rnd(100)};
			}
			if hungry = true and myColor = #red{
				if trait = "Male"{
					myColor <- #gray;
					}
					else{
					myColor <- #white;
					}
					hungry <- false;
					nfood <- nfood+1;
					targetPoint <- {rnd(100),rnd(100)};
			}
			if thirsty = true and myColor = #yellow{
				ask InfoCenter {
					myself.targetPoint <- self.storesDrink[rnd(1)];
					myself.myColor <- #blue;
				}
			}
			if hungry = true and myColor = #yellow{
				ask InfoCenter {
					myself.targetPoint <- self.storesFood[rnd(1)];
					myself.myColor <- #red;
				}
			}
			
			if (myColor = #orange or myColor=#brown) and (mbathb = false and (myturn = false and trait = 'Male')){
			ask Bath{
				if self.trait = 'Male'{
				myself.targetPoint <- self.location+{4+length(self.bathqueuem),4+length(self.bathqueuem),0};
				add myself.name to: self.bathqueuem;
				write self.bathqueuem;
				}
				}
			mbathb <- true;
			}
			
			if (myColor = #orange or myColor = #brown) and (trait='Female' and (fbathb = false and myturn = false)){
			ask Bath{
				if self.trait = 'Female'{
				myself.targetPoint <- self.location+{4+length(self.bathqueuef),4+length(self.bathqueuef),0};
				add myself.name to: self.bathqueuef;
				write self.bathqueuef;
				}
				}
			fbathb <- true;
			}
			
			if myColor = #orange and myturn = true{
				if trait = 'Male'{
					ask Bath{
						if self.trait = 'Male'{
							myself.location <- self.location;
						}
					}
				}
				if trait = 'Female'{
					ask Bath{
						if self.trait = 'Female'{
							myself.location <- self.location;
						}
					}
				}
			timer1 <- timer1+1;
			ndrinks <- 0;
			//write timer1;
			if timer1 > 100{
				if trait = "Male"{
					myColor <- #gray;
					timer1 <- 0;
					myturn <- false;
					}				
				else{
					myColor <- #white;
					timer1<- 0;
					myturn <- false;
					}
			targetPoint <- {rnd(100),rnd(100)};
			
			}
			}
			

				
			if myColor = #brown and myturn = true{
				if trait = 'Male'{
					ask Bath{
						if self.trait = 'Male'{
							myself.location <- self.location;
						}
					}
				}
				if trait = 'Female'{
					ask Bath{
						if self.trait = 'Female'{
							myself.location <- self.location;
						}
					}
				}
			timer2 <- timer2+1;
			nfood <- 0;
			//write timer1;
			if timer2 > 250{
				if trait = "Male"{
					myColor <- #gray;
					timer2 <- 0;
					myturn <- false;
					}				
				else{
					myColor <- #white;
					timer2<- 0;
					myturn <- false;
					}
			targetPoint <- {rnd(100),rnd(100)};
			
			}
			}			

			}
	
		
	
		
		else{
			targetPoint <- nil;
		}
		
	}
	
	aspect default{
		draw sphere(1) at: location+{0,0,1} color: myColor;
		draw pyramid(2) at: location color: myColor;
	}
}


species Store{
	string trait;
	
	aspect default{
		if (self.trait = "Drink"){
			draw cube(5) at: location color: #blue;
		}
		if (self.trait = "Food"){
			draw cube(5) at: location color: #red;
		}
	}
}

species Bath{
	string trait;
	list bathqueuem;
	list bathqueuef;
	bool moccupied <-false;
	bool foccupied <- false;
	string usingbathm;
	string usingbathf;
	
	reflex Mocup2 when: moccupied = true{
		ask Guest{
			if myself.usingbathm = self.name and self.myturn = false{
				myself.moccupied <- false;
				myself.usingbathm <- nil;
				remove first(myself.bathqueuem) from: myself.bathqueuem;
			}
		}
	}
	
	reflex Mocup when: moccupied = false{
		ask Guest{
			if self.myturn = true{
				myself.usingbathm <- self.name;
				myself.moccupied <- true;
			}
		}
	}
	
	
	
		reflex Focup when: foccupied = false{
		ask Guest{
			if self.myturn = true{
				myself.usingbathf <- self.name;
				myself.foccupied <- true;
			}
		}
	}
	
	reflex Focup2 when: foccupied = true{
		ask Guest{
			if myself.usingbathf = self.name and self.myturn = false{
				myself.foccupied <- false;
				myself.usingbathf <- nil;
				remove first(myself.bathqueuef) from: myself.bathqueuef;
			}
		}
	}
	
	
	aspect default{
		if (self.trait = "Male"){
			draw sphere(3) at: location color: #darkblue;
		}
		if (self.trait = "Female"){
			draw sphere(3) at: location color: #salmon;
		}
	}
}

experiment main type: gui {
	output{
		display map type: opengl{
			species InfoCenter;
			species Guest;
			species Store;
			//species Security;
			species Bath;
		}
	}
}
