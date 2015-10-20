# ABSTRACT: zsh completion for your MooseX::App applications
use strict;
use warnings;
package MooseX::App::Plugin::ZshCompletion;

use 5.010;

our $VERSION = '0.000'; # VERSION

use namespace::autoclean;
use Moose::Role;

sub plugin_metaroles {
    my ($self,$class) = @_;

    return {
        class   => ['MooseX::App::Plugin::ZshCompletion::Meta::Class'],
    }
}

around 'initialize_command_class' => sub {
    my $orig = shift;
    my $self = shift;

    my $return = $self->$orig(@_);
    if (blessed $return
        && $return->isa('MooseX::App::Plugin::ZshCompletion::Command')) {
        return $return->zsh_completion($self);
    }

    return $return;
};

1;

__END__

=encoding utf8

=head1 NAME

MooseX::App::Plugin::ZshCompletion - zsh completion for your MooseX::App applications

=head1 SYNOPSIS

In your base class:

 package MyApp;
 use MooseX::App qw/ ZshCompletion /;

     .zshrc:
     fpath=('completion-dir/zsh' $fpath)

In your shell

 zsh% myapp zsh_completion > completion-dir/_myapp
 zsh% chmod u+x completion-dir/_myapp
 zsh% exec zsh

=head1 DESCRIPTION

This plugin generates a zsh completion definition for your application.

=head1 METHODS

=over 4

=item plugin_metaroles

=back

=head1 SEE ALSO

L<MooseX::App::Plugin::BashCompletion>

=head1 LICENSE

COPYRIGHT AND LICENSE

Copyright (C) 2015 by Tina Mueller

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. The full text of the license can be found
in the LICENSE file.

=cut

