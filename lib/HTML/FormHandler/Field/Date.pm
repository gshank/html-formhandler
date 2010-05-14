package HTML::FormHandler::Field::Date;

use Moose;
extends 'HTML::FormHandler::Field::Text';
use DateTime;
use DateTime::Format::Strptime;
our $VERSION = '0.03';

=head1 NAME

HTML::FormHandler::Field::Date - a date field with formats 

=head1 SUMMARY

This field may be used with the jQuery Datepicker plugin.

You can specify the format for the date using jQuery formatDate strings
or DateTime strftime formats. (Default format is format => '%Y-%m-%d'.)

   d  - "%e" - day of month (no leading zero)
   dd - "%d" - day of month (two digit)
   o  - "%{day_of_year}" - day of the year (no leading zeros)
   oo - "%j" - day of the year (three digit)
   D  - "%a" - day name short
   DD - "%A" - day name long
   m  - "%{day_of_month" - month of year (no leading zero)
   mm - "%m" - month of year (two digit) "%m"
   M  - "%b" - month name short
   MM - "%B" - month name long
   y  - "%y" - year (two digit)
   yy - "%Y" - year (four digit)
   @  - "%s" - Unix timestamp (ms since 01/01/1970) 

For example:  

   has_field 'start_date' => ( type => 'Date', format => "dd/mm/y" );

or

   has_field 'start_date' => ( type => 'Date', format => "%d/%m/%y" );

You can also set 'date_end' and 'date_start' attributes for validation
of the date range. Use iso_8601 formats for these dates ("yyyy-mm-dd");

   has_field 'start_date' => ( type => 'Date', date_start => "2009-12-25" );

=cut

has 'format' => ( is => 'rw', isa => 'Str', default => "%Y-%m-%d" );
has 'locale'     => ( is => 'rw', isa => 'Str' );                                  # TODO
has 'time_zone'  => ( is => 'rw', isa => 'Str' );                                  # TODO
has 'date_start' => ( is => 'rw', isa => 'Str', clearer => 'clear_date_start' );
has 'date_end'   => ( is => 'rw', isa => 'Str', clearer => 'clear_date_end' );
has '+size' => ( default => '10' );

# translator for Datepicker formats to DateTime strftime formats
my $dp_to_dt = {
    "d"  => "\%e",    # day of month (no leading zero)
    "dd" => "\%1",    # day of month (2 digits) "%d"
    "o"  => "\%4",    # day of year (no leading zero) "%{day_of_year}"
    "oo" => "\%j",    # day of year (3 digits)
    "D"  => "\%a",    # day name long
    "DD" => "\%A",    # day name short
    "m"  => "\%5",    # month of year (no leading zero) "%{day_of_month}"
    "mm" => "\%3",    # month of year (two digits) "%m"
    "M"  => "\%b",    # Month name short
    "MM" => "\%B",    # Month name long
    "y"  => "\%2",    # year (2 digits) "%y"
    "yy" => "\%Y",    # year (4 digits)
    "@"  => "\%s",    # epoch
};

sub deflate {
    my ( $self, $value ) = @_;

    $value ||= $self->value;
    # if not a DateTime, assume correctly formated string and return
    return $value unless ref $value eq 'DateTime';
    my $format = $self->get_strf_format;
    my $string = $value->strftime($format);
    return $string;
}

sub validate {
    my $self = shift;

    my $format = $self->get_strf_format;
    my $strp = DateTime::Format::Strptime->new( pattern => $format );

    my $dt = eval { $strp->parse_datetime( $self->value ) };
    unless ($dt) {
        $self->add_error( $strp->errmsg || $@ );
        return;
    }
    $self->_set_value($dt);
    my $val_strp = DateTime::Format::Strptime->new( pattern => "%Y-%m-%d" );
    if ( $self->date_start ) {
        my $date_start = $val_strp->parse_datetime( $self->date_start );
        die "date_start: " . $val_strp->errmsg unless $date_start;
        my $cmp = DateTime->compare( $date_start, $dt );
        $self->add_error("Date is too early") if $cmp eq 1;
    }
    if ( $self->date_end ) {
        my $date_end = $val_strp->parse_datetime( $self->date_end );
        die "date_end: " . $val_strp->errmsg unless $date_end;
        my $cmp = DateTime->compare( $date_end, $dt );
        $self->add_error("Date is too late") if $cmp eq -1;
    }
}

sub get_strf_format {
    my $self = shift;

    # if contains %, then it's a strftime format
    return $self->format if $self->format =~ /\%/;
    my $format = $self->format;
    foreach my $dpf ( reverse sort keys %{$dp_to_dt} ) {
        my $strf = $dp_to_dt->{$dpf};
        $format =~ s/$dpf/$strf/g;
    }
    $format     =~ s/\%1/\%d/g,
        $format =~ s/\%2/\%y/g,
        $format =~ s/\%3/\%m/g,
        $format =~ s/\%4/\%{day_of_year}/g,
        $format =~ s/\%5/\%{day_of_month}/g,
        return $format;
}

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
