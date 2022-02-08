unit class Pod::To::Cairo::TextBlock;

use Text::FriBidi::Defs :FriBidiPar;
use Text::FriBidi::Line;
use Pod::To::Cairo::Style;
use HarfBuzz::Buffer;
use HarfBuzz::Raw::Defs :hb-direction;
use HarfBuzz::Font::Cairo;
use HarfBuzz::Shaper::Cairo;

subset TextDirection of Str where 'ltr'|'rtl';

has Numeric $.width;
has Numeric $.height;
has Numeric $.indent = 0;
has HarfBuzz::Font::Cairo:D $.font is required;
has TextDirection $.direction = 'ltr';

has Str $.text is required;
has @.overflow is rw is built;
has Pod::To::Cairo::Style $.style is rw handles <font-size leading space-width shape>;
has Bool $.verbatim;

method !shaper {
    my UInt $direction = $!direction eq 'rtl'
        ?? FRIBIDI_PAR_RTL
        !! FRIBIDI_PAR_LTR;
    my Text::FriBidi::Line $line .= new: :$!text, :$direction;
    my HarfBuzz::Buffer() $buf = %( :text($line.Str), :direction(HB_DIRECTION_LTR));
    given $.font.shaping-font {
        .size = $.font-size;
        HarfBuzz::Shaper::Cairo.new: :$buf, :font($_);
    }
}

method print(Bool :$nl) {
    my $x = $!indent;
    my $y = 0;
    my HarfBuzz::Shaper::Cairo $shaper .= new;
}

method blah(--> Pod::To::Cairo::TextBlock) {}