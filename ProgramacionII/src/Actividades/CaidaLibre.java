package Actividades;
import java.util.Scanner;

public class CaidaLibre {
	private static final Object[] Double = null;

	public static void main(String[] args) {
		double g=10, a=0, v0, vf, t = 0, tvuelo = 0, tmax, d, h, dv;
		int num,i;
		
		
		Scanner entrada = new Scanner(System.in);
		
		System.out.println("Caida Libre!");
		System.out.println("Ingrese los datos de la velocidad inicial :");
		v0= entrada.nextDouble();
		
		t= v0 / 10;
		//Aqui calculamos tiempo que sube el objeto.
		tmax=t*2;
		//Aqui sacamos el tiempo total del vuelo del objeto, desde que sube, hasta que baja.
		
		System.out.println("El tiempo que sube es :" + t + " Segundos");
		System.out.println("El tiempo total de vuelo es:" + tmax + " Segundos");
		
		d=(v0*t) + Math.pow(t,2) * a / 2;
		
	    System.out.println("El resultado DE TODA la distancia es: " + d + " metros");
		
		 Double[] array = new Double[(int) tmax];
		//Hago un vector para tomar en cuenta cada segundo que el objeto está en el aire para con esos calculos sacar la distancia por cada segundo que está en el aire!!!
		for (int i1 = 1; i1 < tmax; i1++) ;
		
		dv=(v0*tmax) + Math.pow(tmax,2) * a / 2;
		
		System.out.println("Los segundos y su distancia son: " );
		
		System.out.println("La distancia del objeto acorde pasan los segundos que está en el aire es: " +dv + " Metros");
		
			
	}
	}	

