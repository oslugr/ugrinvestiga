#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;
use utf8;
use open IO => ':locale';

use lib qw(../lib lib );

use Web::Scraper::Citations;
use Mojo::ByteStream 'b';
use File::Slurp::Tiny qw(read_lines write_file);

my $opciones = "\n CRITERIO:\t 1 -> Citas totales" .
  "\n\t\t 2 -> Citas en los últimos 5 años" .
  "\n\t\t 3 -> Indice h total" .
  "\n\t\t 4 -> Indice h de los últimos 5 años" .
  "\n\t\t 5 -> Indice i10 total" .
  "\n\t\t 6 -> Indice i10 de los últimos 5 años\n\n";

my $num_args = $#ARGV;
if ($num_args != 2){
  die "\nUso: $0 ENTRADA.dat SALIDA.csv CRITERIO" .
    "\n ENTRADA.dat -> archivo con los IDs en Google Scholar de los investigadores" .
    "\n SALIDA.csv -> archivo con el ranking en formato CSV" . $opciones;
}

my ($infile, $outfile, $mode) = @ARGV;

if ($mode<1 or $mode>6){
  die "\nCriterio de ordenación introducido inválido" . $opciones;
}

# Lectura del archivo de entrada con los IDs en Google Scholar de los investigadores
my @researcher_ids = read_lines($infile);
my @dataset = ();

foreach (@researcher_ids){
  # Recuperación de la información de un investigador en función de su ID
  chomp($_);
  my $person = Web::Scraper::Citations->new($_);

  my @row = ();
  for my $column ( qw( name affiliation citations citations_last5 h h_last5 i10 i10_last5) ) {
    push @row, (b($person->$column)->encode('UTF-8'))->to_string;
  }
  # Eliminación de todos los ",", ";" y "." del campo de afiliación
  $row[1] =~ s/[,;.]/ -/gm;

  if ($row[1] !~ /Granada/){
    push @row, "COMPROBAR";
  }

  push @dataset, \@row;

  # Espera de 30 segundos antes de hacer la consulta de los datos de otro investigador
  sleep(30);
}

# Ordenación del listado en función del criterio seleccionado
$mode = $mode + 1;
my @sorted = sort {$b->[$mode] <=> $a->[$mode]} @dataset;

@dataset = ();

# Formateo de los datos de cada uno de los investigadores como valores separados por comas
foreach my $p (@sorted){
  my @person = @{$p};
  push @dataset, join(",", @person);
}

# Escritura del ranking en el archivo de salida
write_file($outfile, map{"$_\n"} @dataset);


