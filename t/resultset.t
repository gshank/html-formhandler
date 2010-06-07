use strict;
use warnings;
use Test::More;

use lib ('t/lib');
use BookDB::Schema;

{
    package Test::Resultset;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';

    has '+item_class' => ( default => 'Employer' );
    has 'resultset' => ( isa => 'DBIx::Class::ResultSet', is => 'rw', trigger => sub { shift->set_resultset(@_) } );
    sub set_resultset {
        my ( $self, $resultset ) = @_;
        $self->schema( $resultset->result_source->schema );
    }
    sub init_object {
        my $self = shift;
        my $rows = [$self->resultset->all];
        return { employers => $rows };
    }
    has_field 'employers' => ( type => 'Repeatable' );
    has_field 'employers.employer_id' => ( type => 'PrimaryKey' );
    has_field 'employers.name';
    has_field 'employers.category';
    has_field 'employers.country';

    sub update_model {
        my $self = shift;
        my $values = $self->values->{employers};
        foreach my $row (@$values) {
            delete $row->{employer_id} unless defined $row->{employer_id};
            $self->resultset->update_or_create( $row );
        }
    }
}

my $schema = BookDB::Schema->connect('dbi:SQLite:t/db/book.db');
my $employers = $schema->resultset('Employer');
my $form = Test::Resultset->new( resultset => $employers );
ok( $form, 'form builds' );
ok( $form->schema, 'form has schema' );
my $fif = {
   'employers.0.category' => 'Perl',
   'employers.0.country' => 'US',
   'employers.0.employer_id' => 1,
   'employers.0.name' => 'Best Perl',
   'employers.1.category' => 'Programming',
   'employers.1.country' => 'UK',
   'employers.1.employer_id' => 2,
   'employers.1.name' => 'Worst Perl',
   'employers.2.category' => 'Programming',
   'employers.2.country' => 'DE',
   'employers.2.employer_id' => 3,
   'employers.2.name' => 'Convoluted PHP',
   'employers.3.category' => 'Losing',
   'employers.3.country' => 'DE',
   'employers.3.employer_id' => 4,
   'employers.3.name' => 'Contractor Heaven',
};
is_deeply( $form->fif, $fif, 'fif is correct' );

$fif->{'employers.2.category'} = 'Marketing';
$form->process( params => $fif );
ok( $form->validated, 'form validated' );
is( $form->resultset->find(3)->category, 'Marketing', 'row updated ok' );

$fif->{'employers.2.category'} = 'Programming';
$form->process( params => $fif );
is( $form->resultset->find(3)->category, 'Programming', 'row updated ok' );

done_testing;
