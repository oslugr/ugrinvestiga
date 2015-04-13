# ugrinvestiga
Descarga de los perfiles de los investigadores de la UGR (o de cualquier otra uni)

## Instalación de dependencias

Los módulos necesarios son `Web::Scraper::Citations`, `Mojo::ByteStream` y `File::Slurp`. Se pueden instalar automáticamente con:

```
cpanm --installdeps .
```

## Ejecución

Para la ejecución correcta del programa es necesario indicar dos archivos como argumentos:

```
./ugrinvestiga.pl ENTRADA.dat SALIDA.csv CRITERIO
```

* *ENTRADA.dat*: archivo con los IDs en Google Scholar de los investigadores.
* *SALIDA.csv*: archivo con el ranking en formato CSV.
* *CRITERIO*:
1. Citas totales
2. Citas en los últimos 5 años
3. Indice h total
4. Indice h de los últimos 5 años
5. Indice i10 total
6. Indice i10 de los últimos 5 años
