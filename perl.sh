#!/usr/bin/env sh

# Pre-configure perldoc
PERLDOC=-MPod::Perldoc::ToMan
export PERLDOC

# Enable perlbrew, if a perlbrew user exists and the login shell is bash
if id -u perlbrew 1>/dev/null 2>&1; then
  case ${SHELL} in
    *bash ) for PERLBREW_ROOT in /opt/perlbrew /opt/perl5/perlbrew; do
              if [ -d "${PERLBREW_ROOT}" ]; then
                export PERLBREW_ROOT
                break
              fi
              unset PERLBREW_ROOT
            done
            if [ -n "${PERLBREW_ROOT}" ]; then
              # shellcheck source=/dev/null
              . "${PERLBREW_ROOT}/etc/bashrc"
            else
              printf '%s\n' 'perlbrew user exists but PERLBREW_ROOT not found.' 1>&2
            fi;;
  esac
fi

if [ -z "${PERLBREW_ROOT}" ] && [ -d /usr/local/perl/bin ]; then
  PATH=/usr/local/perl/bin:${PATH}
fi

# Install local::lib; the perlll() function (see below) uses PERL_LOCAL_LIBS_DIR
PERL_LOCAL_LIBS_DIR=$(perl -e 'printf qq($ENV{HOME}/perl-\%vd), $^V')
make -f ~/profile.d/Makefile PERL_LOCAL_LIBS_DIR="${PERL_LOCAL_LIBS_DIR}" install-local-lib-dist

# Convenience function to prepare a given ($1) local::lib environment
perlll() {
  if [ $# -eq 0 ]; then
    # shellcheck disable=SC2046
    set -- "$(cd "${PERL_LOCAL_LIBS_DIR}" || exit; select_loop $(ls -1d -- *))"
  fi
  # shellcheck disable=SC2086
  case $1 in
      --* ) OLD_IFS="${IFS}"; IFS=,; set -- $1; IFS="${OLD_IFS}"; unset OLD_IFS
            case $2 in
                 /* ) set -- "$1,$2";;
              local ) set -- "$1,${PWD}/$2";; # cpm's default --local-lib-contained DIR
                  * ) set -- "$1,${PERL_LOCAL_LIBS_DIR}/$2";;
            esac;;
       /* ) true;;
    local ) set -- "--no-create,${PWD}/$1";; # cpm's default --local-lib-contained DIR
       '' ) return;;
        * ) set -- "${PERL_LOCAL_LIBS_DIR}/$1";;
  esac
  eval "$(eval perl -I\""${PERL_LOCAL_LIBS_DIR}/local-lib/lib/perl5"\" -Mlocal::lib=\""$1"\")"
}

installdeps() {
  # defaults:
  #          --no-test
  #   phase: --with-build, --with-runtime, --with-test
  #   types: --with-requires
  # TODO: don't install "develop" phase dependencies
  if test -n "${PERL_MM_OPT}" -a "${PERL_MM_OPT##*/}" = local; then
    cpm install --with-configure --with-develop --local-lib-contained "${PERL_MM_OPT#*=}" --show-build-log-on-failure
  else
    cpm install --with-configure --with-develop --local-lib-contained local --show-build-log-on-failure
  fi
}

alias tidy='perltidy cpanfile Makefile.PL $(find lib t/lib -name "*.pm" 2>/dev/null) $(find t -name "*.t")'

perlrun() (
  func_name=perlrun
  optind_correction=1
  trace=false
  while getopts :I:LUbhlx option; do
    case ${option} in
       # Prepend instead of append elements to the search path
       I) search_path="-I ${OPTARG} ${search_path}";;
       L) search_path="-I ${PWD}/local/lib/perl5 ${search_path}";;
       U) unset_PERL5LIB='unset PERL5LIB';;
       b) search_path="-I ${PWD}/blib/arch -I ${PWD}/blib/lib ${search_path}";;
       h) # Break options parsing and keep "-h" as a usual argument
          optind_correction=2
          break;;
       l) search_path="-I ${PWD}/lib ${search_path}";;
       x) trace=true;;
      \?) shift $(( OPTIND - 2 ))
          printf '%s: %s: Invalid option.\n' "${func_name}" "$1" 1>&2
          return 2;;
    esac
  done
  shift $(( OPTIND - optind_correction ))

  if [ $# -eq 1 ] && [ "$1" = -h ]; then
    cat >&1 << USAGE
Usage: ${func_name} [ -h ]
       ${func_name} [ -x ] [ -LUbl ] [ -I <directory> ] <arg1> <arg2> ... -- <perl interpreter call (check the "perlrun" POD)>

Options:
  -I <directory> prepend directory to @INC
  -L             prepend \${PWD}/local/lib/perl5 to @INC
  -U             unset PERL5LIB
  -b             prepend \${PWD}/blib/arch and \${PWD}/blib/lib to @INC
  -h             print this usage
  -l             prepend \${PWD}/lib to @INC
  -x             turn on xtrace before calling the perl interpreter

<arg1>, <arg2>, ... are reverted and appended to the perl interpreter call
USAGE
    return 0;
  fi

  # Reverse positional parameters until a parameter has the value "--"
  for arg; do
    shift
    case ${arg} in
      --) break;;
       *) set -- "$@" "${arg}";;
    esac
  done

  if ${trace}; then
    set -o xtrace
  fi

  ${unset_PERL5LIB}
  # Use raw perl and no special switches like -E
  # shellcheck disable=SC2086
  #perl ${search_path} -Mstrict -Mwarnings "$@"
  perl ${search_path} "$@"
)

perlcore() (
  perlrun "$@" -- -e '
    BEGIN { require v5.10.0; }
    use strict;
    use warnings;
    use feature          qw( say ); # available as of perl-5.10.0
    use version          qw();
    use Module::CoreList qw();

    if ( $ARGV[ 0 ] eq q(-h) ) {
      (my $help = <<"      HELP") =~ s/^\s+//gm;
        For a given regular expression pattern grep out the core modules that
        the current(!) perl distribution ($^V) offers. Another version could
        be selected setting the environment variable PERL_VERSION.
      HELP
      print $help;
      exit 0;
    }

    my $package = defined( $ARGV[ 0 ] ) ? qr/$ARGV[0]/ : qr/^.*/;
    say foreach ( sort Module::CoreList->find_modules(
        $package, version->parse(exists $ENV{ PERL_VERSION } ? $ENV{ PERL_VERSION } : $^V)->numify()
      )
    );
  ' --
)

# Example call: perldp '$direction ? $x += 1 : $y += 1'
perldp() {
  perlrun "$@" -- -MO=-qq,Deparse,-P,-p,-q,-sC -e
}

perlmodver() {
  perlrun "$@" -- -e '
    BEGIN { require v5.10.0; }
    use strict;
    use warnings;
    use feature        qw( say ); # available as of perl-5.10.0
    use Module::Load   qw( load );
    use Module::Loaded qw();

    if ( $ARGV[ 0 ] eq q(-h) ) {
      ( my $help = <<"      HELP" ) =~ s/^\s+//gm;
        Show the location and the VERSION of a given perl module
        (bare package name!) like for example Net::SFTP::Foreign.
      HELP
      print $help;
      exit 0;
    }

    my ( $package ) = @ARGV;
    # Caveat:
    # A package Foo::Bar is load()ed (required) twice: with the name Foo/Bar.pm
    # and with the name Foo/Bar (without the .pm extension). I do not understand
    # why! Read the seemingly doubled "Cannot locate" error messages carefully.
    load( $package );
    say $INC{ Module::Loaded->_pm_to_file( $package ) }, q( ),  ( $package->VERSION // q(<undef>) );
  ' --
}

# If the require is successful the joined @INC is printed in the first line
# %INC in the following lines and the number of keys in %INC in the last line
perlrequires() {
  perlrun "$@" -- -e '
    # On purpose do not import and use extra module or features like "say".
    if ( $ARGV[ 0 ] eq q(-h) ) {
      ( my $help = <<"      HELP" ) =~ s/^\s+//gm;
        After requiring a given perl module (bare package name!)
        print information about \@INC and \%INC.
      HELP
      print $help;
      exit 0;
    }
    eval qq(require $ARGV[ 0 ]);
    if ( $@ ne q() ) { print STDERR $@; exit 255; }
    print STDOUT join( q(:), @INC ), qq(\n);
    my $count = 0;
    foreach ( sort keys( %INC ) ) {
      ++$count;
      print STDOUT $_, q( => ), $INC{ $_ }, qq(\n);
    }
    print STDOUT $count, qq(\n);
  ' --
}

perlload() {
  perlrun "$@" -- -M'Time::HiRes qw( gettimeofday tv_interval )' -e '
    # On purpose do not import and use extra module or features like "say".
    if ( $ARGV[ 0 ] eq q(-h) ) {
      ( my $help = <<"      HELP" ) =~ s/^\s+//gm;
        Measure the time it take to require a given perl module (bare package name!)
        and print information about \@INC and the elapsed time including microseconds.
      HELP
      print $help;
      exit 0;
    }
    # NOTE2 of https://metacpan.org/pod/Time::HiRes#time-() explains why it is
    # better to use gettimeofday() instead of time().
    my $start_time = [ gettimeofday() ];
    eval qq(require $ARGV[ 0 ]);
    if ( $@ ne q() ) { print STDERR $@; exit 255; }
    $elapsed_time = tv_interval( $start_time );
    print STDOUT join( q(:), @INC ), qq(\n);
    print STDOUT $elapsed_time, qq(\n);
  ' --
}
