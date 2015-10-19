package MooseX::App::Plugin::ZshCompletion::Command;
# ABSTRACT: Command class for MooseX::App::Plugin::ZshCompletion

use Moose;
use 5.010;
our $VERSION = '0.000'; # VERSION

use namespace::autoclean;
use MooseX::App::Command;

command_short_description q(Zsh completion automator);

sub zsh_completion {
    my ($self,$app) = @_;

    my %command_map;
    my $app_meta        = $app->meta;
    my $commands        = $app_meta->app_commands;
    my $command_list    = join (' ', keys %{$commands});
    my $package         = __PACKAGE__;
    my $prefix          = $app_meta->app_base;

    my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    $year               += 1900;
    $mday               = sprintf('%02i',$mday);
    $mon                = sprintf('%02i',$mon+1);

    $prefix             =~ tr/./_/;

    while (my ($command,$command_class) = each %$commands) {
        Class::Load::load_class($command_class);
        #my @parameters = $app_meta->command_usage_attributes($command_class->meta,'parameter');
        my @options = $app_meta->command_usage_attributes($command_class->meta,[qw(option proto)]);
        $command_map{$command} = {
            #parameters  => [ map { $_->is_required } @parameters ],
            options     => \@options,
        };
    }

    my $syntax = '';
    my $subcmd = '';
    my $subcmd_functions = '';

    for my $command (sort keys %command_map) {
        my $data = $command_map{ $command };
        $subcmd .= <<"EOM";
        $command)
            _${prefix}_$command
        ;;
EOM

        my $options = $command_map{ $command }->{options};
        my $option_list = '';
        for my $opt (@$options) {
            my $name = $opt->cmd_usage_name;
            my @names = $opt->cmd_name_possible;
            my $doc = $opt->documentation;
            $doc =~ s/'/'"'"'/g;

            my @opt = split ' ', $name;
            if (@opt > 1) {
                # '(-q --quiet)'{-q,--quiet}'[Show minimal output]' \
                $option_list .= "        '(@{[ @opt ]})'\{@{[ join ',', @opt ]}\}'\[$doc\]";
            }
            else {
                $option_list .= "        '$opt[0]\[$doc\]";
            }
            if ($opt->has_type_constraint) {
                if ($opt->type_constraint->is_a_type_of('Bool')) {
                }
                else {
                    $option_list .= ":$names[0]";
                }
            }
            $option_list .= "' \\\n";
        }
        $subcmd_functions .= <<"EOM";
_${prefix}_$command() {
    _arguments -C \\
        '1: :->subcmd' \\
        '*: :->args' \\
$option_list && ret=0
}

EOM
    }

    $syntax .= <<"EOT";
#compdef $prefix

# Built with $package on $year/$mon/$mday

${prefix}_COMMANDS='help $command_list'

_$prefix() {
    typeset -A opt_args
    local curcontext="\$curcontext" state line context

    _arguments -s \\
        '1: :->subcmd' \\
        '*: :->args' \\
    && ret=0

    case \$state in

    subcmd)
        compadd help $command_list
    ;;

    args)
        curcontext="\${curcontext%:*:*}:$prefix-cmd-\$words[1]:"

        case \$line[1] in
$subcmd
        help)
            _${prefix}_help
        esac

    esac
}

$subcmd_functions
_${prefix}_help() {
    compadd $command_list
}

EOT


    return MooseX::App::Message::Envelope->new(
        MooseX::App::Message::Block->new({ body => $syntax })
    );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

MooseX::App::Plugin::ZshCompletion::Command - generates the zsh completion for MooseX::App::Plugin::ZshCompletion

=head1 METHODS

=over 4

=item zsh_completion

This method is doing the generation.

=back

=cut
