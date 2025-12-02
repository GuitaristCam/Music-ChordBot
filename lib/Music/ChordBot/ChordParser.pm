#! perl

package Music::ChordBot::ChordParser;

use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

=head1 NAME

Music::ChordBot::ChordParser - Parse chord symbols from text

=head1 SYNOPSIS

    use Music::ChordBot::ChordParser;
    
    my $parser = Music::ChordBot::ChordParser->new();
    my $chord = $parser->parse_chord("Dm7");
    # Returns: { root => "D", type => "Min7" }

=head1 DESCRIPTION

This module provides functionality to parse chord symbols from text and
convert them to the format expected by ChordBot.

=cut

=head1 METHODS

=head2 new

Create a new ChordParser instance.

=cut

sub new {
    my $class = shift;
    return bless {}, $class;
}

=head2 parse_chord

Parse a chord symbol and return a hashref with root and type.

    my $chord = $parser->parse_chord("Dm7");
    # Returns: { root => "D", type => "Min7" }

=cut

sub parse_chord {
    my ($self, $chord_str) = @_;
    
    return undef unless defined $chord_str && length($chord_str) > 0;
    
    # Remove leading/trailing whitespace
    $chord_str =~ s/^\s+|\s+$//g;
    
    # Parse the root note (A-G with optional # or b)
    my $root;
    if ($chord_str =~ /^([A-G][#b]?)(.*)$/) {
        $root = $1;
        my $rest = $2;
        
        # Normalize root notation
        $root =~ s/b$/♭/;  # Convert b to flat symbol if needed
        
        # Parse the chord type
        my $type = $self->_parse_chord_type($rest);
        
        return {
            root => $root,
            type => $type
        };
    }
    
    return undef;
}

=head2 _parse_chord_type

Internal method to parse chord type suffix.

=cut

sub _parse_chord_type {
    my ($self, $type_str) = @_;
    
    # Remove whitespace
    $type_str =~ s/^\s+|\s+$//g;
    
    # Mapping of common chord notations to ChordBot types
    my %chord_map = (
        # Major chords
        ''          => 'Maj',
        'M'         => 'Maj',
        'maj'       => 'Maj',
        'Maj'       => 'Maj',
        
        # Minor chords
        'm'         => 'Min',
        'min'       => 'Min',
        'Min'       => 'Min',
        '-'         => 'Min',
        
        # Seventh chords
        '7'         => '7',
        'maj7'      => 'Maj7',
        'Maj7'      => 'Maj7',
        'M7'        => 'Maj7',
        'm7'        => 'Min7',
        'min7'      => 'Min7',
        'Min7'      => 'Min7',
        '-7'        => 'Min7',
        
        # Diminished
        'dim'       => 'Dim',
        'dim7'      => 'Dim7',
        '°'         => 'Dim',
        '°7'        => 'Dim7',
        'o'         => 'Dim',
        'o7'        => 'Dim7',
        
        # Augmented
        'aug'       => 'Aug',
        '+'         => 'Aug',
        
        # Suspended
        'sus'       => 'Sus',
        'sus2'      => 'Sus2',
        'sus4'      => 'Sus4',
        
        # Extended chords
        '9'         => '9',
        'm9'        => 'Min9',
        'min9'      => 'Min9',
        'maj9'      => 'Maj9',
        'Maj9'      => 'Maj9',
        
        '11'        => '11',
        '13'        => '13',
        
        # Altered chords
        '7b5'       => '7♭5',
        '7#5'       => '7#5',
        '7b9'       => '7♭9',
        '7#9'       => '7#9',
        
        # Special
        '6'         => '6',
        'm6'        => 'Min6',
        'min6'      => 'Min6',
        
        # Add chords
        'add9'      => 'Add9',
        
        # Half-diminished
        'm7b5'      => 'Min7♭5',
        'ø'         => 'Min7♭5',
        'ø7'        => 'Min7♭5',
    );
    
    # Check for exact match
    return $chord_map{$type_str} if exists $chord_map{$type_str};
    
    # Try case-insensitive match
    foreach my $key (keys %chord_map) {
        if (lc($type_str) eq lc($key)) {
            return $chord_map{$key};
        }
    }
    
    # Default to Maj if not recognized
    return 'Maj';
}

=head2 extract_chords_from_line

Extract all chord symbols from a line of text.
Returns an array of chord hashrefs.

    my @chords = $parser->extract_chords_from_line("| Dm7 | Am7 | Dm7 | Dm7 |");

=cut

sub extract_chords_from_line {
    my ($self, $line) = @_;
    
    return () unless defined $line;
    
    my @chords;
    
    # Common patterns for chord sheets:
    # - Chords separated by spaces or pipes
    # - Chords may have duration indicators (x2, x4, etc.)
    
    # Split by common delimiters
    my @tokens = split /[\s\|]+/, $line;
    
    foreach my $token (@tokens) {
        next unless $token;
        
        # Try to parse as a chord
        my $chord = $self->parse_chord($token);
        if ($chord) {
            push @chords, $chord;
        }
    }
    
    return @chords;
}

1;

=head1 AUTHOR

Music::ChordBot was written by Johan Vromans.

=head1 COPYRIGHT

Copyright (C) 2013,2025 Johan Vromans.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
