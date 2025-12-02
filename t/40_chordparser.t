#! perl

use strict;
use warnings;
use Test::More tests => 20;

BEGIN { use_ok( 'Music::ChordBot::ChordParser' ) }

my $parser = Music::ChordBot::ChordParser->new();
isa_ok( $parser, 'Music::ChordBot::ChordParser' );

# Test basic major chords
{
    my $chord = $parser->parse_chord("C");
    is( $chord->{root}, "C", "C root" );
    is( $chord->{type}, "Maj", "C major type" );
}

{
    my $chord = $parser->parse_chord("G");
    is( $chord->{root}, "G", "G root" );
    is( $chord->{type}, "Maj", "G major type" );
}

# Test minor chords
{
    my $chord = $parser->parse_chord("Dm");
    is( $chord->{root}, "D", "Dm root" );
    is( $chord->{type}, "Min", "Dm minor type" );
}

{
    my $chord = $parser->parse_chord("Am");
    is( $chord->{root}, "A", "Am root" );
    is( $chord->{type}, "Min", "Am minor type" );
}

# Test seventh chords
{
    my $chord = $parser->parse_chord("Dm7");
    is( $chord->{root}, "D", "Dm7 root" );
    is( $chord->{type}, "Min7", "Dm7 type" );
}

{
    my $chord = $parser->parse_chord("G7");
    is( $chord->{root}, "G", "G7 root" );
    is( $chord->{type}, "7", "G7 type" );
}

# Test with sharps and flats
{
    my $chord = $parser->parse_chord("F#m");
    is( $chord->{root}, "F#", "F#m root" );
    is( $chord->{type}, "Min", "F#m type" );
}

# Test extract_chords_from_line
{
    my @chords = $parser->extract_chords_from_line("| C | G | Am | F |");
    is( scalar(@chords), 4, "Found 4 chords" );
    is( $chords[0]->{root}, "C", "First chord is C" );
    is( $chords[1]->{root}, "G", "Second chord is G" );
}

# Test empty input
{
    my $chord = $parser->parse_chord("");
    is( $chord, undef, "Empty string returns undef" );
}
