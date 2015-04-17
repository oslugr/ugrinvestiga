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

my $infile = shift || "lista_investigadores.dat";

my $outfile = shift || "lista_investigadores.csv";

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

  sleep(1);
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


