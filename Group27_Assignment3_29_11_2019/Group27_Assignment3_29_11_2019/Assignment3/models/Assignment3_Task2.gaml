/***
* Name: Assignment3_Task2
* Author: valeriaBladinieres and raul AZNAR
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Assignment3_Task2

/* Insert your model definition here */

global {
	int numGuests<-20;
	int numStages<-4;
	list locationStages<-[{25.0,25.0,0.0},{75.0,75.0,0.0},{25.0,75.0,0.0},{75.0,25.0,0.0}];
	list Musicgenres<-['Pop','Rock','Electro','HipHop','Latin'];
	int inde<-0;
	list Stageslist<-[];
	
	init {
		create Stages number: numStages{
			location<-locationStages[inde];
			inde<-inde+1;
			add self to: Stageslist;
		}
		
		create Guest number: numGuests;
	}
}


species Stages skills: [fipa] { 
	rgb myColor <- #blue;
	float Lights<- rnd(0.0,1.0);
	float Visualeffects<- rnd(0.0,1.0);
	float Sound <- rnd(0.0,1.0);
	float BandPopularity<- rnd(0.0,1.0);
	float Dancechance<-rnd(0.0,1.0);
	float timeduration<-rnd(300.0,500.0);
	float Duration<-rnd(0.0,1.0);
	float importancegenre<-rnd(0.0,1.0);
	string Genre<-'Pop';
	bool over<-true;
	float starttime;

	
	reflex happens when: (over=true){
		Lights<- rnd(0.0,1.0);
		Visualeffects<- rnd(0.0,1.0);
		Sound <- rnd(0.0,1.0);
		BandPopularity<- rnd(0.0,1.0);
		Dancechance<-rnd(0.0,1.0);
		timeduration<-rnd(200.0,400.0);
		Duration<-timeduration/1000;
		Genre <- Musicgenres[rnd(0,4)];
		over<-false;
		starttime<-time+rnd(10,50);	
	}
	
	reflex startconcert when: (over=false and time=starttime){
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,Lights,Visualeffects,Sound,BandPopularity,Dancechance,Duration,Genre,'Starting Concert']];
	}
	
	reflex finishconcert when: (time>starttime+timeduration) and over=false{
		over<-true;
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,0,0,0,0,0,0,Genre,'Concert finished']];
		
	}
	
	aspect default{
		if Genre='HipHop'{
			draw square(13) at: location color: #black;	
		}
		if Genre='Pop'{
			draw square(13) at: location color: #salmon;	
		}
	
		if Genre='Rock'{
			draw square(13) at: location color: #green;	
		}
	
		if Genre='Latin'{
			draw square(13) at: location color: #red;	
		}
		if Genre='Electro'{
			draw square(13) at: location color: #yellow;	
		}
	}
}

species Guest skills: [fipa, moving] {
	rgb myColor <- #gray;
	point targetPoint <- nil;
	float Lights<- rnd(0.0,1.0);
	float Visualeffects<- rnd(0.0,1.0);
	float Sound <- rnd(0.0,1.0);
	float BandPopularity<- rnd(0.0,1.0);
	float Dancechance<-rnd(0.0,1.0);
	float Duration<-rnd(0.0,1.0);
	list Musictaste<-[rnd(0.0,1.0),rnd(0.0,1.0),rnd(0.0,1.0),rnd(0.0,1.0),rnd(0.0,1.0)];
	float importancegenre<-rnd(0.5,1.5);
	float utility<-0.0;
	float utility2<-0.0;
	agent concert;
	list utilitylist<- [0.0,0.0,0.0,0.0];

	
	
	reflex utility when: !empty(informs){
		//calcular utility y comparar con la anterior, si es mas grande ir a la location del inform.
		loop m over: informs {
			
			if m.contents[9]='Concert finished'{
					agent compare<-m.contents[0];
					int aux <- Stageslist index_of compare;
					if concert=m.contents[0]{
						utility<-0.0;
						//write'I gotta leave!!!';
					}
					utilitylist[aux]<-0.0;	
					int aux10 <- utilitylist index_of max(utilitylist);
					utility<-utilitylist[aux10];
					targetPoint<-locationStages[aux10];
					concert<-Stageslist[aux10];	
			}
			

			
			if m.contents[9]='Starting Concert'{
			utility2<-Lights*float(m.contents[2])+Visualeffects*float(m.contents[3])+Sound*float(m.contents[4])+BandPopularity*float(m.contents[5])+Dancechance*float(m.contents[6])+Duration*float(m.contents[7]);
			//write utility2;
			write 'Current Utility';
			write utility;
			string mgenre<-string(m.contents[8]);
			int result <- Musicgenres index_of mgenre;
			utility2<-utility2*(importancegenre*float(Musictaste[result]));
			write 'Utility of the new.pos';
			write utility2;
			agent compare<-m.contents[0];
			int aux <- Stageslist index_of compare;
			utilitylist[aux]<-utility2;
			if utility2>utility{
				write utilitylist;
				write 'New utility';
				write utility2;
				write 'Going to'+m.contents[0]+'in'+m.contents[1];
				utility<-utility2;
				targetPoint<-m.contents[1];
				concert<-m.contents[0];
				//write concert;
			}
		}	
		
		}
	}
	
	reflex beIdle when: targetPoint = nil{
		do wander(0.5,360.0,square(5));
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
		speed<-1.0;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		targetPoint<-nil;
	}
	
	aspect default{
		draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
		draw pyramid(2) at: location color: myColor;
	}
	
}

experiment main type: gui {
	output{
		display map type: opengl{
			species Stages;
			species Guest;
		}
	}
	
}
