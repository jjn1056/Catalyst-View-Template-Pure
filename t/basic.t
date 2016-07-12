use Test::Most;
use Catalyst::Test 'Test::CatalystTemplatePureApp';

use Devel::Dwarn;

Dwarn request '/';

ok 1;

done_testing;
