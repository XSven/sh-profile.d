#!/usr/bin/env sh

oas_yaml_to_json() {
  perl -e '
    use strict; use warnings;

    use JSON::PP 4.12 qw();                # is dual-life module and as such core module since perl 5.13.9
    use POSIX         qw( EXIT_FAILURE );
    use YAML::XS 0.67 qw( LoadFile );

    # this is needed to convert boolean values properly
    $YAML::XS::Boolean = q(JSON::PP);

    unless ( @ARGV ) {
      print STDERR "usage: openapi_yml_to_json <YAML OpenAPI document> > <JSON OpenAPI document>\n";
      exit EXIT_FAILURE;
    }

    my $yml = LoadFile( $ARGV[ 0 ] );

    # do not enable prettification ( JSON::PP->new->pretty->space_before( 0 )->indent_length( 2 ) )
    # pipe through jq ( ... | jq '.' ) if needed
    print JSON::PP->new->encode( $yml );
  ' "$@"
}
