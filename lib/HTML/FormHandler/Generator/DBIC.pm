package HTML::FormHandler::Generator::DBIC;
use Moose;
use MooseX::AttributeHelpers;

use DBIx::Class;
use Template;
use version; our $VERSION = '0.02';

=head1 NAME

HTML::FormHandler::Generator::DBIC - generate form classes from DBIC schema 

=head1 SYNOPSIS

   form_generator.pl --rs_name=Book --schema_name=BookDB::Schema::DB 
          --db_dsn=dbi:SQLite:t/db/book.db

=head1 DESCRIPTION

Options:

  rs_name       -- Resultset Name
  schema_name   -- Schema Name 
  db_dsn           -- dsn connect info


=cut

has db_dsn => ( 
    is => 'ro', 
    isa => 'Str',
);

has db_user => ( 
    is => 'ro', 
    isa => 'Str',
);

has db_password => ( 
    is => 'ro', 
    isa => 'Str',
);

has 'schema_name' => (
    is  => 'ro',
    isa => 'Str',
);

has 'rs_name' => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);

has 'schema' => (
    is  => 'rw',
    lazy_build => 1,
    isa => 'DBIx::Class::Schema',
    required => 1,
);

sub _build_schema {
    my $self = shift;
    my $schema_name = $self->schema_name;
    eval "require $schema_name";
    return $schema_name->connect( $self->db_dsn, $self->db_user, $self->db_password, );
}

has 'tt' => (
    is => 'ro',
    default => sub { Template->new() },
);

has 'class_prefix' => (
    is => 'ro',
);

has 'style' => (
    is => 'ro'
);

has 'm2m' => (
    is => 'ro',
);

has 'packages' => (
   metaclass  => 'Collection::Hash',
   isa        => 'HashRef[Str]',
   is         => 'rw',
   default    => sub { {} },
   auto_deref => 1,
   provides   => {
       keys      => 'used_packages',
   },
   curries  => {
       set => { 
           add_package => sub {
               my ($self, $body, $package) = @_;
               $body->($self, $package, 1);
           } 
       }
   }
);

has 'field_classes' => (
   metaclass  => 'Collection::Hash',
   isa        => 'HashRef[HashRef]',
   is         => 'rw',
   default    => sub { {} },
   auto_deref => 1,
   provides   => {
       keys      => 'list_field_classes',
       get       => 'get_field_class_data',
       exists    => 'exists_field_class',
       set       => 'set_field_class_data',
   },
);

my $form_template = <<'END';
{
    package [% config.class %]Form;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    with 'HTML::FormHandler::Render::Simple';
[% FOR package = self.used_packages %]
    use [% package %];
[% END %]

    has '+item_class' => ( default => '[% rs_name %]' );

    [% FOR field = config.fields -%]
    [% field %]
    [% END %]
    has_field submit => ( widget => 'submit' )
}
[% FOR field_class = self.list_field_classes %]
[% SET cf = self.get_field_class_data( field_class ) %]
{
    package [% cf.class %]Field;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Field::Compound';
    
    [% FOR field = cf.fields -%]
    [% field %]
    [% END %]
}
[% END %]

END

sub generate_form {
    my ( $self ) = @_;
    my $config = $self->get_config;
    my $output;
    # warn Dumper( $config ); use Data::Dumper;
    my $tmpl_params = {
        self => $self,
        config => $config,
        rs_name => $self->rs_name,
    };
    $tmpl_params->{single} = 1 if defined $self->style && $self->style eq 'single';
    $self->tt->process( \$form_template, $tmpl_params, \$output )
                   || die $self->tt->error(), "\n";
    return $output;
}

sub _strip_class {
    my $fullclass = shift;
    my @parts     = split /::/, $fullclass;
    my $class     = pop @parts;
    return $class;
}

sub get_config {
    my( $self ) = @_;
    my $config = $self->get_elements ( $self->rs_name, 0, );
#    push @{$config->{fields}}, {
#        type => 'submit',
#        name => 'foo',
#    };
    my $target_class = $self->rs_name;
    $target_class = $self->class_prefix . '::' . $self->rs_name if $self->class_prefix;
    $config->{class} = $target_class;
    return $config;
}

   
   
sub m2m_for_class {
    my( $self, $class ) = @_;
    return if not $self->m2m;
    return if not $self->m2m->{$class};
    return @{$self->m2m->{$class}};
}

my %types = (
    text      => 'TextArea',
    int       => 'Integer',
    integer   => 'Integer',
    num       => 'Number',
    number    => 'Number',
    numeric   => 'Number',
);
 
sub field_def {
    my( $self, $name, $info ) = @_;
    my $output = '';
    $output .= "has_field '$name' => ( ";
    if( lc $info->{data_type} eq 'date' or lc $info->{data_type} eq 'datetime' ){
        $self->add_package( 'DateTime' );
        $output .= <<'END';

            type => 'Compound',
            apply => [ 
                {
                    transform => sub{ DateTime->new( $_[0] ) },
                    message => "Not a valid DateTime",
                }
            ],
        );
END
        $output .= "        has_field '$name.$_';\n" for qw( year month day );
        return $output;
    }
    my $type = $types{ $info->{data_type} } || 'Text'; 
    $type = 'TextArea' if defined($info->{size}) && $info->{size} > 60;
    $output .= "type => '$type', ";
    $output .= "size => $info->{size}, " if $type eq 'Text' && $info->{size};
    $output .= 'required => 1, ' if not $info->{is_nullable};
    return $output . ');';
}

sub get_elements {
    my( $self, $class, $level, @exclude ) = @_;
    my $source = $self->schema->source( $class );
    my %primary_columns = map {$_ => 1} $source->primary_columns;
    my @fields;
    my @fieldsets;
    for my $rel( $source->relationships ) {
        next if grep { $_ eq $rel } @exclude;
        next if grep { $_->[1] eq $rel } $self->m2m_for_class($class);
        my $info = $source->relationship_info($rel);
        push @exclude, get_self_cols( $info->{cond} );
        my $rel_class = _strip_class( $info->{class} );
        my $elem_conf;
        if ( ! ( $info->{attrs}{accessor} eq 'multi' ) ) {
            push @fields, "has_field '$rel' => ( type => 'Select', );\n"
        }
        elsif( $level < 1 ) {
            my @new_exclude = get_foreign_cols ( $info->{cond} );
            my $config = $self->get_elements ( $rel_class, 1, );
            my $target_class = $rel_class;
            $target_class = $self->class_prefix . '::' . $rel_class if $self->class_prefix;
            $config->{class} = $target_class;
            $config->{name} = $rel;
            $self->set_field_class_data( $target_class => $config ) if !$self->exists_field_class( $target_class );
            my $field_def = '';
            if( defined $self->style && $self->style eq 'single' ){
                $field_def .= '# ';
            }
            $field_def .= "has_field '$rel' => ( type => '+${target_class}Field', );\n";
            push @fields, $field_def;
        }
    }
    for my $col ( $source->columns ) {
        my $new_element = { name => $col };
        my $info = $source->column_info($col);
        if( $primary_columns{$col} ){ 
            # - generated schemas have not is_auto_increment set so
            # so the below needs to be commented out
            # and $info->{is_auto_increment} ){  
            unshift @fields, "has_field '$col' => ( type => 'Hidden' );\n";
        }   
        else{
            next if grep { $_ eq $col } @exclude;
            unshift @fields, $self->field_def( $col, $info );
       }
    }
    for my $many( $self->m2m_for_class($class) ){
        unshift @fields, "has_field '$many->[0]' => ( type => 'Select', multiple => 1 );\n"
    }
    return { fields => \@fields };
}

sub get_foreign_cols{
    my $cond = shift;
    my @cols;
    if ( ref $cond eq 'ARRAY' ){
        for my $c1 ( @$cond ){
            push @cols, get_foreign_cols( $c1 );
        }
    }
    elsif ( ref $cond eq 'HASH' ){ 
        for my $key ( keys %{$cond} ){
            if( $key =~ /foreign\.(.*)/ ){
                push @cols, $1;
            }
        }
    }
    return @cols;
}

sub get_self_cols{
    my $cond = shift;
    my @cols;
    if ( ref $cond eq 'ARRAY' ){
        for my $c1 ( @$cond ){
            push @cols, get_self_cols( $c1 );
        }
    }
    elsif ( ref $cond eq 'HASH' ){ 
        for my $key ( values %{$cond} ){
            if( $key =~ /self\.(.*)/ ){
                push @cols, $1;
            }
        }
    }
    return @cols;
}

{
    package HTML::FormHandler::Generator::DBIC::Cmd;
    use Moose;
    extends 'HTML::FormHandler::Generator::DBIC';
         with 'MooseX::Getopt';
    has '+db_dsn'      => ( required => 1 );
    has '+schema_name' => ( required => 1 );
    has '+schema' => ( metaclass => 'NoGetopt' );
    has '+tt' => ( metaclass => 'NoGetopt' );
    has '+m2m' => ( metaclass => 'NoGetopt' );
}



=head1 AUTHOR

Zbigniew Lukasiak

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;
