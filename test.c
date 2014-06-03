#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int matriz[10][10];
int step,current=0,limit=5;	/*	step -> paso en el que va avanzando, current -> nivel en el que esta, limit -> restriccion de avance	*/
int posx=5,posy=5,vary=5,varx=5;

/*	llena matriz con 0	*/
void llenar() {
	int x,y;

	for(x=0;x<10;x++)
		for(y=0;y<10;y++)
			matriz[x][y]=0;
}

/*	mostrar matriz	*/
void mostrar() {
	int x,y;
	for(x=0;x<10;x++){
		for(y=0;y<10;y++)
			printf("%d ", matriz[x][y]);
		printf("\n");
	}
}

/*	avanza hacia la derecha y calcula la distancia (truncada) desde el centro	*/
void right(){

	varx++;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
}

/*	avanza hacia abajo y calcula la distancia desde el centro	*/
void down(){

	vary++;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
}

/*	avanza hacia la izquierda y calcula la distancia desde el centro	*/
void left(){

	varx--;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
}

/*	avanza hacia arriba y calcula la distancia desde el centro	*/
void up(){

	vary--;
	matriz[vary][varx] = (int)sqrt(abs(pow(varx-posx,2)) + abs(pow(vary-posy,2)));
}

/*	recorre la matriz en espiral desde adentro hacia afuera	*/
void espiral(){
	
	/*	avanza hasta que llegar a limit	*/
	while(current<limit){
		current++;
		step=0;
		/*	avanza hasta recorrer un nivel	*/
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
