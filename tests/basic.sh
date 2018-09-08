
function setup() {
	mount_dir=$(mktemp -d)
	$SPARSEBUNDLEFS -s -f -D $TEST_BUNDLE $mount_dir &
	for i in {0..50}; do
		# FIXME: Find actual mount callback in fuse?
		grep -q "bundle has" $test_output_file && break || sleep 0.1
	done
	pid=$!
	dmg_file=$mount_dir/sparsebundle.dmg
}

function test_dmg_exists_after_mounting() {
	ls -l $dmg_file
	test -f $dmg_file
}

function teardown()
{
	umount $mount_dir
	rm -Rf $mount_dir
}