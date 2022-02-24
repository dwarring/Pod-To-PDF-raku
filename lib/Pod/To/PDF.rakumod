use Pod::To::Cairo;
unit class Pod::To::PDF:ver<0.0.1>
    is Pod::To::Cairo;

use Cairo;
use File::Temp;

has Str $!title;
has int32 @!outline-stack;

submethod TWEAK(Str :$title, Str :$lang = 'en') {
    self.title = $_ with $title;
    self.surface.set_metadata(CAIRO_PDF_METADATA_CREATOR, "Raku {self.^name} v{self.^ver}");
}

method render(
    $class: $pod,
    :$pdf-file = tempfile("POD6-****.pdf", :!unlink)[0],
    UInt:D :$width  = 512,
    UInt:D :$height = 720,
    |c,
) {
    state %cache{Any};
    %cache{$pod}{$width~'x'~$height} //= do {
        my Cairo::Surface::PDF $surface .= create($pdf-file, $width, $height);
        $class.new(:$pod, :$surface, :$width, :$height, |c);
        $surface.finish;
        $pdf-file;
    }
}

our sub pod2pdf(
    $pod,
    :$class = $?CLASS,
    Str() :$pdf-file = tempfile("POD6-****.pdf", :!unlink)[0],
    UInt:D :$width  = 512,
    UInt:D :$height = 720,
    Cairo::Surface::PDF :$surface = Cairo::Surface::PDF.create($pdf-file, $width, $height);
    |c,
) is export {
    $class.new(|c, :$pod, :$surface);
    $surface;
}

method add-toc-entry(Str:D $Title, Str :$dest!, UInt:D :$level! ) {
    my Str $name = $Title.subst(/\s+/, ' ', :g); # Tidy a little
    @!outline-stack.pop while @!outline-stack >= $level;
    my int32 $parent-id = $_ with @!outline-stack.tail;
    while @!outline-stack < $level-1 {
        # e.g. jump from =head1 to =head3
        # need to insert missing entries
        $parent-id = $.surface.add_outline: :$parent-id, :$dest;
        @!outline-stack.push: $parent-id;
    }
    my uint32 $toc-id = $.surface.add_outline: :$parent-id, :$name, :$dest;
    @!outline-stack.push: $toc-id;
}

method title is rw {
    Proxy.new(
        FETCH => { $!title },
        STORE => -> $, $!title {
            self.surface.set_metadata(CAIRO_PDF_METADATA_TITLE, $!title);
        }
    )
}

=begin pod
=TITLE

Pod::To::PDF - Pod to PDF renderer

=head2 Usage

From command line:

    $ raku --doc=PDF lib/to/class.rakumod | xargs evince

From Raku:
    =begin code :lang<raku>
    use Pod::To::PDF;
    use Cairo;

    =NAME
    foobar.pl

    =head2 SYNOPSIS
    =code foobar.pl <options> files ...

    my Cairo::Surface::PDF $pdf = pod2pdf($=pod);
    $pdf.finish();
    =end code

=head2 Exports

    class Pod::To::PDF;
    sub pod2pdf; # See below

From command line:
    =begin code :lang<shell>
    $ raku --doc=PDF lib/to/class.rakumod | xargs xpdf
    =end code
From Raku code, the C<pod2pdf> function returns a L< Cairo::Surface::PDF> object which can
be further manipulated, or finished to complete rendering.

    =begin code :lang<raku>
    use Pod::To::PDF;
    use Cairo;
 
    =NAME
    foobar.raku

    =head2 SYNOPSIS
    =code foobarraku <options> files ...

    my Cairo::Surface::PDF $pdf = pod2pdf($=pod);
    $pdf.finish();
    =end code

=head2 Description

This module renders Pod to PDF documents via Cairo.

The generated PDF has a table of contents and is tagged for
accessibility and testing purposes.

It uses HarfBuzz for font shaping and glyph selection
and FontConfig for system font loading.

=head2 Methods and subroutines
=head3 sub pod2pdf()
=begin code :lang<raku>
sub pod2pdf(
    Pod::Block $pod
) returns Cairo::Surface::PDF;
=end code

=head4 pod2pdf() Options

=defn Str() :$pdf-file
A filename for the output PDF file.

=defn Cairo::Surface::PDF :$surface
A surface to render to

=defn UInt:D :$width, UInt:D :$height
The page size in points (there are 72 points per inch).

=defn UInt:D :$margin
The page margin in points

=defn Hash :@fonts
By default, Pod::To::PDF loads system fonts via FontConfig. This option can be used to preload selected fonts.
=begin code :lang<raku>
use Pod::To::PDF;
use Cairo;
my @fonts = (
    %(:file<fonts/Raku.ttf>),
    %(:file<fonts/Raku-Bold.ttf>, :bold),
    %(:file<fonts/Raku-Italic.ttf>, :italic),
    %(:file<fonts/Raku-BoldItalic.ttf>, :bold, :italic),
    %(:file<fonts/Raku-Mono.ttf>, :mono),
);

my Cairo::Surface::PDF $pdf = pod2pdf($=pod, :@fonts, :pdf-file<out.pdf>);
$pdf.finish();
=end code
Each font entry should have a `file` entry and various
combinations of `bold`, `italic` and `mono` flags. Note
that `mono` is used to render code blocks and inline code. 

=defn `:!contents`
Disables Table of Contents generation.

=head2 Installation

This module's dependencies include L<HarfBuzz|https://harfbuzz-raku.github.io/HarfBuzz-raku/>, L<Font::FreeType|https://pdf-raku.github.io/Font-FreeType-raku/> and L<FontConfig|https://raku.land/zef:dwarring/FontConfig>, which further depend on native C<harfbuzz>, C<freetype6> and C<fontconfig> libraries.

Please check these module's installation instructions.

=head2 Testing

Installation of the L<PDF::Tags::Reader> module is recommended
to enable structural testing.

For example, to test this module from source.

=begin code
$ git clone https://github.com/dwarring/Pod-To-PDF-raku
$ cd Pod-To-PDF-raku
$ zef install PDF::Tags::Reader
$ zef APP::Prove6
$ zef --deps-only install .
$ prove6 -I .
=end code

=end pod
