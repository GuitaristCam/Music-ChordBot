#! perl

package Music::ChordBot::PDFReader;

use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

=head1 NAME

Music::ChordBot::PDFReader - Extract text content from PDF files

=head1 SYNOPSIS

    use Music::ChordBot::PDFReader;
    
    my $reader = Music::ChordBot::PDFReader->new();
    my $text = $reader->read_pdf("chords.pdf");

=head1 DESCRIPTION

This module provides functionality to extract text from PDF files
for chord sheet processing.

=cut

=head1 METHODS

=head2 new

Create a new PDFReader instance.

=cut

sub new {
    my $class = shift;
    return bless {}, $class;
}

=head2 read_pdf

Extract text from a PDF file.

    my $text = $reader->read_pdf("file.pdf");

=cut

sub read_pdf {
    my ($self, $filename) = @_;
    
    die "File not found: $filename\n" unless -f $filename;
    
    # Try to use pdftotext first (from poppler-utils)
    if ($self->_has_pdftotext()) {
        return $self->_read_with_pdftotext($filename);
    }
    
    # Fallback to CAM::PDF if available
    if (eval { require CAM::PDF; 1 }) {
        return $self->_read_with_campdf($filename);
    }
    
    die "No PDF reading method available. Please install poppler-utils (pdftotext) or CAM::PDF module.\n";
}

=head2 _has_pdftotext

Check if pdftotext command is available.

=cut

sub _has_pdftotext {
    my $self = shift;
    
    # Check if pdftotext is in PATH using safer approach
    foreach my $dir (split /:/, $ENV{PATH} || '') {
        return 1 if -x "$dir/pdftotext";
    }
    return 0;
}

=head2 _read_with_pdftotext

Read PDF using pdftotext command.

=cut

sub _read_with_pdftotext {
    my ($self, $filename) = @_;
    
    # Validate filename to prevent command injection
    die "Invalid filename\n" if $filename =~ /[`'\$;|&<>]/;
    
    # Use open() with list form for safer execution
    open my $fh, '-|', 'pdftotext', '-layout', $filename, '-'
        or die "Failed to run pdftotext: $!\n";
    
    my $text = do { local $/; <$fh> };
    close $fh;
    
    if ($? != 0) {
        die "Failed to extract text from PDF using pdftotext\n";
    }
    
    return $text;
}

=head2 _read_with_campdf

Read PDF using CAM::PDF module.

=cut

sub _read_with_campdf {
    my ($self, $filename) = @_;
    
    my $pdf = CAM::PDF->new($filename);
    unless ($pdf) {
        die "Failed to open PDF file: $filename\n";
    }
    
    my $text = '';
    my $num_pages = $pdf->numPages();
    
    for my $page (1 .. $num_pages) {
        my $page_text = $pdf->getPageText($page);
        $text .= $page_text . "\n";
    }
    
    return $text;
}

1;

=head1 DEPENDENCIES

This module requires either:

=over 4

=item * poppler-utils (pdftotext command) - recommended

=item * CAM::PDF Perl module - fallback option

=back

=head1 AUTHOR

Music::ChordBot was written by Johan Vromans.

=head1 COPYRIGHT

Copyright (C) 2013,2025 Johan Vromans.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
