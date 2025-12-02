#! perl

use strict;
use warnings;
use Test::More tests => 6;
use utf8;

BEGIN { use_ok( 'Music::ChordBot::ChordParser' ) }
BEGIN { use_ok( 'Music::ChordBot::Song' ) }

# Integration test: Parse chords and create a song

my $parser = Music::ChordBot::ChordParser->new();

# Simulate extracted text from a PDF chord sheet
my $chord_sheet_text = <<'END_TEXT';
Amazing Grace

| C | C | F | C |
| C | Am | D7 | G7 |
| C | C | F | C |
| C | G7 | C | C |

END_TEXT

# Extract chords
my @all_chords;
foreach my $line (split /\n/, $chord_sheet_text) {
    my @chords = $parser->extract_chords_from_line($line);
    push @all_chords, @chords if @chords;
}

ok( scalar(@all_chords) > 0, "Extracted chords from text" );
is( scalar(@all_chords), 18, "Found 18 chords" );

# Create a song
song "Amazing Grace";
tempo 90;

section "Verse";
style "Hammered";

foreach my $chord_ref (@all_chords) {
    next unless defined $chord_ref->{root} && defined $chord_ref->{type};
    chord $chord_ref->{root} . " " . $chord_ref->{type} . " 4";
}

my $json = Music::ChordBot::Song::json();

ok( defined $json, "Generated JSON output" );
like( $json, qr/"songName":"Amazing Grace"/, "JSON contains song name" );
