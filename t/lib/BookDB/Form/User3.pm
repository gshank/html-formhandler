package BookDB::Form::User3;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';

use DateTime::Format::W3CDTF;

my $f = DateTime::Format::W3CDTF->new;

has_field 'birthdate' => ( 
    apply => [ { transform => sub{ $f->parse_datetime( $_[0] ) } } ],
    deflation => sub { $f->format_date( $_[0] ) },
);

no HTML::FormHandler::Moose;
1;
