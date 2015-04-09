#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;
use utf8;

use lib qw(../lib lib );

use Web::Scraper::Citations;
use Mojo::ByteStream 'b';
use Data::Dumper;

#my $file = "lista_prueba.dat";
my $file = shift
  or die "Uso: $0 NOMBRE.dat -> archivo con los IDs en Google Scholar de los investigadores\n";
open(my $fh, '<:encoding(UTF-8)', $file)
  or die "No se pudo abrir el archivo '$file' $!";

my @researcher_ids = ();

while (my $row = <$fh>){
  chomp $row;
  push @researcher_ids, $row;
}

my @dataset = ();

foreach (@researcher_ids){
  my $person = Web::Scraper::Citations->new($_);

  my @row = ();
  for my $column ( qw( name affiliation citations citations_last5 h h_last5 i10 i10_last5) ) {
    push @row, (b($person->$column)->encode('UTF-8'))->to_string;
  }
  push(@dataset,\@row);

  #sleep(30);
}

my @sorted = sort {$b->[2] <=> $a->[2]} @dataset;

print Dumper(@sorted);

__END__
