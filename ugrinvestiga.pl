#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;
use utf8;

use lib qw(../lib lib );

use Web::Scraper::Citations;
use Mojo::ByteStream 'b';

my $file = shift or die "Uso: $0 NOMBRE.csv -> archivo CSV con los IDs en Google Scholar de los investigadores\n";
#my $file = "lista_prueba.csv";
my $line;
my @researcher_ids = ();

open INFILE, $file;
while ($line = <INFILE>){
  chomp($line);
  push(@researcher_ids, $line);
}
close INFILE;

foreach (@researcher_ids){
  my $person = Web::Scraper::Citations->new($_);

  my @row = ();
  for my $column ( qw( name affiliation citations citations_last5 h h_last5 i10 i10_last5) ) {
    push @row, b($person->$column)->encode('UTF-8');
  }

  my $entry = join(", ", @row );
  print $entry . "\n";

  sleep(30);
}

__END__
