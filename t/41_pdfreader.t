#! perl

use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok( 'Music::ChordBot::PDFReader' ) }

my $reader = Music::ChordBot::PDFReader->new();
isa_ok( $reader, 'Music::ChordBot::PDFReader' );

# Note: Full PDF reading tests require either pdftotext or CAM::PDF
# These are integration tests that would need actual PDF files
# For unit testing, we verify the module loads correctly
