use Test::Most;
use Catalyst::Test 'Test::CatalystTemplatePureApp';

use Devel::Dwarn;

Dwarn request '/ttt';

ok 1;

done_testing;
