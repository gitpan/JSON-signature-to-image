#!/usr/bin/perl

=head1 NAME

signature-to-image

=head1 AUTHOR

This Perl Module:  Jim Turner <http://home.mesh.net/turnerjw/jim>

Original PHP code:   Thomas J Bradley <hey@thomasjbradley.ca> <http://thomasjbradley.ca/lab/signature-to-image>

=head1 COPYRIGHT

Copyright (c) 2011 Jim Turner <http://home.mesh.net/turnerjw/jim>.  
All rights reserved.  

This program is free software; you can redistribute 
it and/or modify it under the same terms as Perl itself.

This is a derived work from signature-to-image.php (see below):

Signature to Image: A supplemental script for Signature Pad that
generates an image of the signature's JSON output server-side using PHP.

project ca.thomasjbradley.applications.signaturetoimage

author Thomas J Bradley <hey@thomasjbradley.ca>

link http://thomasjbradley.ca/lab/signature-to-image

link http://github.com/thomasjbradley/signature-to-image

copyright Copyright MMXI, Thomas J Bradley

license New BSD License

version 1.0.1

Perl version created 2011/12/02 by Jim Turner

=head1 SYNOPSIS

signature-to-image.pl [--multiplier=#(5)] [--penwidth=#(2)] [--xmax=#(198)] [--ymax=#(55)] [--pen_color='r,g,b'(20,83,148)] [--background_color='r,g,b'(255,255,255)] json-file|-

-or-

cat jason-file | signature-to-image.pl [--multiplier=#(5)] [--penwidth=#(2)] [--xmax=#(198)] [--ymax=#(55)] [--pen_color='r,g,b'(20,83,148)] [--background_color='r,g,b'(255,255,255)] - >imagefile.png

-or-

#!/usr/bin/perl -w

require "signature-to-image.pl"

my ($img, $err) = &sig2png($json_image [, multiplier => #(5)] [, penwidth => #(2)] [, xmax => #(198)] [, ymax => #(55)] [, pen_color => 'r,g,b'(20,83,148)] [, background_color => 'r,g,b'(255,255,255)])

if ($err =~ /success/) {

	print $img;

} else {

	warn "..Could not create png image from json signature string ($err)!\n";

}

=head1 PREREQUISITES

	GDlib for perl;
	JSON::Parse;

=head1 PURPOSE

Create a Perl version of Thomas Bradley's signature-to-image.php for a client.

=head1 METHODS

=over 4

=item sig2png ( STR [, options ] )


Converts a json string to a PNG image and returns an array containing the image as a binary string
followed by "success" or an empty image string followed by an error message.

Options:

	multiplier => #  - Multiple image size by # pixels (default 5)
	penwidth => #  - Width in pixels of each vector to be drawn (will be multiplied by C<multiplier>) (default 2).
	xmax => #  - maximum width in pixels of the generated image (will be multiplied by C<multiplier>) (default 198).
	ymax => #  - maximum height in pixels of the generated image (will be multiplied by C<multiplier>) (default 55).
	pen_color => "r#,g#,b#"  - RGB values (0-255) for color to draw the signature in (default "20,83,148").
	background_color => "r#,g#,b#"  - RGB values (0-255) for background color (default "255,255,255").

=back

=head1 KEYWORDS

JSON, JSON::Parse, signature-to-image

=cut

#package JSON::signature_to_image;

use GD;
use JSON::Parse (qw(json_to_perl valid_json));

#use vars qw($VERSION);
my $VERSION = '1.0';

my $usage = <<END_TEXT;
usage:
function:&sig2png(<json_image> [, multiplier => #(5)] [, penwidth => #(2)] [, xmax => #(198)] [, ymax => #(55)] [, pen_color => 'r,g,b'(20,83,148)] [, background_color => 'r,g,b'(255,255,255)])
command-line:signature-to-image.pl [--multiplier=#(5)] [--penwidth=#(2)] [--xmax=#(198)] [--ymax=#(55)] [--pen_color='r,g,b'(20,83,148)] [--background_color='r,g,b'(255,255,255)] json-file|-
END_TEXT

sub sig2png {     #MAIN METHOD FUNCTION TO CONVERT JSON STRING INTO PNG SIGNATURE IMAGE:
  return ('', "no json image string - usage:$usage")  unless (@_);
  my $json = shift;
  %args = @_;

  return ('', "invalid json image")  unless (valid_json $json);

  my $perl = json_to_perl ($json);   #CONVERT JSON IMAGE OBJECT TO AN OBJECT PERL CAN UNDERSTAND:
  my (@coords, @lines);
  #my $drawMultiplier = 12;
  my $drawMultiplier = $args{multiplier} || 5;   #MULTIPLY SIZE OF GENERATED IMAGE BY THIS FACTOR:
  my $penWidth = $args{penwidth} || 2;           #DRAW THE LINE THIS WIDTH:
  $penWidth *= $drawMultiplier;
  foreach my $i (@{$perl}) {
    @coords = ();
    foreach my $j (sort keys %{$i}) {
      push (@coords, $$i{$j}*$drawMultiplier);
    }
    push (@lines, [@coords]);
  }
  my $maxX = $args{xmax} || 198;                 #ALLOW USER TO ALTER IMAGE SIZE:
  my $maxY = $args{ymax} || 55;

  #my $pen_color = $args{pen_color} || '0x14,0x53,0x94';;  #HEX NO WORKEE THIS WAY?!
  my $pen_color = $args{pen_color} || '20,83,148';
  my @penColors = split(/\,\s*/, $pen_color);
  # my $background_color = $args{background_color} || '0xff,0xff,0xff';  #HEX NO WORKEE THIS WAY?!
  my $background_color = $args{background_color} || '255,255,255';
  my @bgColors = split(/\,\s*/, $background_color);
  $maxX *= $drawMultiplier;
  $maxY *= $drawMultiplier;
  my ($img) = new GD::Image($maxX,$maxY);
  return (undef, 'Faild to create image!')  unless (defined $img);
  my $bgcolr = $img->colorAllocate(@bgColors);
  my $penColour = $img->colorAllocate(@penColors);

  $img->fill(1,1,$bgcolr);
  $img->setThickness($penWidth);
  foreach my $l (@lines) {       #DRAW EACH LINE FROM THE COORDINATES IN THE JSON IMAGE:
#    print "--line=".join('|',@{$l})."=\n";
    $img->line(@{$l}, $penColour);
  }

  return ($img->png, 'success');   #RETURN THE IMAGE.
}

if (defined @ARGV) {
  #EXAMPLE USAGE:
  if ($ARGV[0] =~ /\-h/) {
    print STDERR $usage;
    exit 1;
  } elsif ($ARGV[0] =~ /\-v/) {
    print STDERR "..$0 version $VERSION\n";
    exit 1;
  }
  #GET COMMAND-LINE ARGUMENTS:
  my @args;
  my @fids;
  while (@ARGV) {
    if ($ARGV[0] =~ /^\-\-/o) {
      push (@args, $1, $2)  if ($ARGV[0] =~ /^\-\-(\w+)\=(.+)/o);
      shift @ARGV;
    } else {
      push (@fids, shift(@ARGV));
    }
  }
  @ARGV = @fids;

  #READ INPUT FILE:
  my $imgStr = '';
  while (<>) {
    $imgStr .= $_;
  }

  #CALL METHOD FUNCTION TO CONVERT TO IMAGE:
  my ($image, $err) = &sig2png($imgStr, @args);

  #WRITE PNG IMAGE TO STDOUT OR ERROR MESSAGE TO STDERR:
  if ($err =~ /success/i) {
    print $image;
  } else {
    print STDERR $err;
    exit 1;
  }
  exit 0;
}

1

__END__
