#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;
use utf8;
use open IO => ':locale';

use Web::Scraper::Citations;
use Mojo::ByteStream 'b';
use File::Slurp::Tiny qw(read_lines write_file);

my $num_args = $#ARGV + 1;
if ($num_args != 2){
  die "\nUso: $0 ENTRADA.dat SALIDA.csv" .
    "\n ENTRADA.dat -> archivo con los IDs en Google Scholar de los investigadores" .
    "\n SALIDA.csv -> archivo con el ranking en formato CSV\n\n";
}

my ($infile, $outfile) = @ARGV;

# Lectura del archivo de entrada con los IDs en Google Scholar de los investigadores
my @researcher_ids = read_lines($infile);
my $num_res = scalar @researcher_ids;

my @dataset = ();

my $i = 1;
foreach (@researcher_ids){
  # Recuperación de la información de un investigador en función de su ID
  chomp($_);

  say "Petición " . $i . " de " . $num_res . ": " . $_;

  my $person = eval { Web::Scraper::Citations->new($_);};

  if ($@) {
    die "\n  Se he producido un error en la solicitud con ID \"" . $_ . "\".\n" .
    "  Si el perfil \"https://scholar.google.es/citations?user=" . $_ .
    "\" no existe elimine dicho identificador del archivo de entrada." . 
    "\n  En caso contrario, pruebe a volver a ejecutar el programa.\n\n";
  }

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

  $i++;
}

# Ordenación del listado en función del criterio seleccionado
my @sorted = sort {$b->[2] <=> $a->[2]} @dataset;

@dataset = ();

# Formateo de los datos de cada uno de los investigadores como valores separados por comas
foreach my $p (@sorted){
  push @dataset, join(",", @{$p});
}

# Escritura del ranking en el archivo de salida
write_file($outfile, join("\n",@dataset));

say "\nRanking generado guardado en el archivo \"" . $outfile . "\".";
