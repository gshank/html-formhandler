package HTML::FormHandler::Traits;
# ABSTRACT: customized replacement for MooseX::Traits

use Moose::Role;
use Class::Load qw/ load_class /;
use namespace::autoclean;

has '_trait_namespace' => (
    init_arg => undef,
    isa      => 'Str',
    is       => 'bare',
);

my %COMPOSED_CLASS_INDEX;
# {
#    'HTML::FormHandler::Field::Text' => { 'Role|Another::Role' => 1 },
#    'HTML::FormHandler::Field::Select' => { 'My::Role' => 2,
#                                            'My::Role|Your::Role' => 3 },
# }
my %COMPOSED_META;
my $composed_index = 0;

sub resolve_traits {
    my ( $class, @traits ) = @_;

    return map {
        my $orig = $_;
        if ( !ref $orig ) {
            my $transformed = transform_trait( $class, $orig );
            load_class($transformed);
            $transformed;
        }
        else {
            $orig;
        }
    } @traits;
}

sub transform_trait {
    my ( $class, $name ) = @_;
    return $1 if $name =~ /^[+](.+)$/;

    my $namespace = $class->meta->find_attribute_by_name('_trait_namespace');
    my $base;
    if ( $namespace->has_default ) {
        $base = $namespace->default;
        if ( ref $base eq 'CODE' ) {
            $base = $base->();
        }
    }

    return $name unless $base;
    return join '::', $base, $name;
}

sub composed_class_name {
    my (%options) = @_;

    my $class     = $options{class};
    my $cache_key = _anon_cache_key( $options{roles} );

    my $index = $COMPOSED_CLASS_INDEX{$class}{$cache_key};
    if ( defined $index ) {
        return "${class}::$index";
    }
    $index = ++$composed_index;
    $COMPOSED_CLASS_INDEX{$class}{$cache_key} = $index;
    return "${class}::$index";
}

sub _anon_cache_key {
    # Makes something like Role|Role::1
    return join( '|', @{ $_[0] || [] } );
}

sub with_traits {
    my ( $class, @traits ) = @_;

    @traits = resolve_traits( $class, @traits );
    return $class->meta unless ( scalar @traits );

    my $class_name = $class->meta->name;
    my $new_class_name = composed_class_name( class => $class_name, roles => \@traits, );
    my $meta;
    if ( $meta = $COMPOSED_META{$new_class_name} ) {
        return $meta->name;
    }
    else {
        $meta = $class->meta->create(
            $new_class_name,
            superclasses => [$class_name],
            roles        => \@traits,
        );
        $COMPOSED_META{$new_class_name} = $meta;
        return $meta->name;
    }
}

sub new_with_traits {
    my ( $class, %args ) = @_;

    my $traits = delete $args{traits} || [];
    my $new_class   = $class->with_traits(@$traits);
    my $constructor = $new_class->meta->constructor_name;
    return $new_class->$constructor(%args);
}

=head1 SYNOPSIS

Use to get a new composed class with traits:

   my $class = My::Form->with_traits( 'My::Trait', 'Another::Trait' );
   my $form = $class->new;

=cut

no Moose::Role;
1;
