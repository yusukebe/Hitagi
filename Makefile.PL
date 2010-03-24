use inc::Module::Install;
name 'Hitagi';
all_from 'lib/Hitagi.pm';

requires 'Data::Section::Simple';
requires 'Plack::Request';
requires 'Plack::Response';
requires 'Router::Simple';
requires 'Text::MicroTemplate';
requires 'DBIx::Skinny';
requires 'File::Slurp';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
