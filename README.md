TITLE
=====



Pod::To::PDF - Pod to PDF renderer

Usage
-----

From command line:

    $ raku --doc=PDF lib/to/class.rakumod | xargs evince

From Raku:

```raku
use Pod::To::PDF;
use Cairo;

=NAME
foobar.pl

=head2 SYNOPSIS
=code foobar.pl <options> files ...

my Cairo::Surface::PDF $pdf = pod2pdf($=pod);
$pdf.finish();
```

Exports
-------

    class Pod::To::PDF;
    sub pod2pdf; # See below

From command line:

```shell
$ raku --doc=PDF lib/to/class.rakumod | xargs xpdf
```

From Raku code, the `pod2pdf` function returns a [Cairo::Surface::PDF](Cairo::Surface::PDF) object which can be further manipulated, or finished to complete rendering.

```raku
use Pod::To::PDF;
use Cairo;

=NAME
foobar.raku

=head2 SYNOPSIS
=code foobarraku <options> files ...

my Cairo::Surface::PDF $pdf = pod2pdf($=pod);
$pdf.finish();
```

Description
-----------

This module renders Pod to PDF documents via Cairo.

The generated PDF has a table of contents and is tagged for accessibility and testing purposes.

It uses HarfBuzz for font shaping and glyph selection and FontConfig for system font loading.

Methods and subroutines
-----------------------

### sub pod2pdf()

```raku
sub pod2pdf(
    Pod::Block $pod
) returns Cairo::Surface::PDF;
```

#### pod2pdf() Options

**Str() :$pdf-file**

A filename for the output PDF file.

**Cairo::Surface::PDF :$surface**

A surface to render to

**UInt:D :$width, UInt:D :$height**

The page size in points (there are 72 points per inch).

**UInt:D :$margin**

The page margin in points

**Hash :@fonts**

By default, Pod::To::PDF loads system fonts via FontConfig. This option can be used to preload selected fonts.

```raku
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
```

Each font entry should have a `file` entry and various combinations of `bold`, `italic` and `mono` flags. Note that `mono` is used to render code blocks and inline code. 

**`:!contents`**

Disables Table of Contents generation.

Installation
------------

This module's dependencies include [HarfBuzz](https://harfbuzz-raku.github.io/HarfBuzz-raku/), [Font::FreeType](https://pdf-raku.github.io/Font-FreeType-raku/) and [FontConfig](https://raku.land/zef:dwarring/FontConfig), which further depend on native `harfbuzz`, `freetype6` and `fontconfig` libraries.

Please check these module's installation instructions.

Testing
-------

Installation of the [PDF::Tags::Reader](PDF::Tags::Reader) module is recommended to enable structural testing.

For example, to test this module from source.

    $ git clone https://github.com/dwarring/Pod-To-PDF-raku
    $ cd Pod-To-PDF-raku
    $ zef install PDF::Tags::Reader
    $ zef APP::Prove6
    $ zef --deps-only install .
    $ prove6 -I .

