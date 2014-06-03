#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int matriz[10][10];
int step,current=0,limit=5;
int posx=5,posy=5,vary=5,varx=5;


void llenar() {
	int x,y;

	for(x=0;x<10;x++)
		for(y=0;y<10;y++)
			matriz[x][y]=0;
}

void mostrar() {
	int x,y;
	for(x=0;x<10;x++){
		for(y=0;y<10;y++)
			printf("%d ", matriz[x][y]);
		printf("\n");
	}
}

void right(){

	varx++;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
	printf("%d\n ", abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));

}

void down(){

	vary++;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
	printf("%d\n ", abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
}

void left(){

	varx--;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
	printf("%d\n ", abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
}

void up(){

	vary--;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
	printf("%d\n ", abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
}

void espiral(){
	
	while(current<limit){
		current++;
		step=0;
		while(step<current){
			step++;
			right();
		}
	
		step=0;
		while(step<current){
			step++;
			down();
		}
	
		current++;
		step=0;
		while(step<current){
			step++;
			left();
		}
	
		step=0;
		while(step<current){
			step++;
			up();
		}
	}
}

void main() {

	llenar();
	espiral();
	//printf("\n %d %d \n",step,current);
	mostrar();
}
