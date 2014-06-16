#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int matriz[20][20];
int posx1=2,posx2=11,posy1=2,posy2=17;

void llenar() {
	int x,y;

	for(x=0;x<20;x++)
		for(y=0;y<20;y++)
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

void linea () {
	int i;
	float p1,p2,p3,p4;	//p1 der, p2 abajo, p3 izq, p4 arriba

	if ( p1 = sqrt(abs(pow(posx2+1-posx1,2)) + abs(pow(posy2-posy1,2))) < 
			p2 = sqrt(abs(pow(posx2-posx1,2)) + abs(pow(posy2+1-posy1,2))) )
		if ( p1 < p3 = sqrt(abs(pow(posx2-1-posx1,2)) + abs(pow(posy2-posy1,2))) )
			if ( p1 < p4 = sqrt(abs(pow(posx2-posx1,2)) + abs(pow(posy2-1-posy1,2))) ) {
				posx1++;
				matriz[posx1][posy1]=1;
			}
			else {
				posy1++;
				matriz[posx1][posy1]=1; 
			}
		





	

	//derecha
	p1 = sqrt(abs(pow(posx2+1-posx1,2)) + abs(pow(posy2-posy1,2)));
	//abajo
	p2 = sqrt(abs(pow(posx2-posx1,2)) + abs(pow(posy2+1-posy1,2)));
	//izq
	p3 = sqrt(abs(pow(posx2-1-posx1,2)) + abs(pow(posy2-posy1,2)));
	//arriba
	p4 = sqrt(abs(pow(posx2-posx1,2)) + abs(pow(posy2-1-posy1,2)));




void main(){

	llenar();
	matriz[posx1][posy1]=1;
	matriz[posx2][posy2]=1;

	linea();

}
