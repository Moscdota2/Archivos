package Actividades;
import java.util.Scanner;

public class Intereses {

	public static void main(String[] args) {
	
		double a, b, c;
		int añ;
		int x= 0, p = 0;
	
		Scanner entrada = new Scanner (System.in);
		//Declaro variables
		System.out.println("Programa de generación de Intereses!");
		
		System.out.println("Ingrese el monto total del capital: ");
		a = entrada.nextInt();
		
		System.out.println("Ingrese el monto total de la tasa de interes: ");
		b = entrada.nextInt();
		
		System.out.println("Ingrese la cantidad de años para generar el interes: ");
		añ = entrada.nextInt();
		//Pongo una ciclo repetitivo para sacar la cuenta de los intereses
		while (x < añ) {
			x ++;
			p = 1;
			while(p <=4 ) {
				c= a * b/100;
				a=a + c;
				System.out.println("El primer periodo de interéss " + p + " Del año " + x + "  El Capital a pagar va a ser de:  " + a );
				p++;
				//Aqui se imprime finalmente 
				
			}
			
			
		}
		
	}

}

