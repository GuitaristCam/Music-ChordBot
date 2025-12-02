#!/usr/bin/env perl

# Example: Using Music::ChordBot to programmatically create chord progressions

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Music::ChordBot::Song;

# Create a simple song
song "Example Song";
tempo 120;

section "Verse";
style "Hammered";

# Classic I-V-vi-IV progression in C
C 4; G 4; Am 4; F 4;
C 4; G 4; Am 4; F 4;

section "Chorus";
style "Strident";

# Add some seventh chords
Cmaj7 4; Em7 4; Am7 4; Fmaj7 4;
Dm7 4; G7 4; Cmaj7 8;

# Output to STDOUT
print Music::ChordBot::Song::json(), "\n";
