
function setup() {
    mount_dir=$(mktemp -d)
    $SPARSEBUNDLEFS -s -f -D $TEST_BUNDLE $mount_dir &
    for i in {0..50}; do
        # FIXME: Find actual mount callback in fuse?
        grep -q "bundle has" $test_output_file && break || sleep 0.1
    done
    dmg_file=$mount_dir/sparsebundle.dmg
}

function test_dmg_exists_after_mounting() {
    ls -al $mount_dir
    test -f $dmg_file
}

function test_dmg_has_expected_size() {
    size=$(ls -dn $dmg_file | awk '{print $5; exit}')
    test $size -eq 1099511627776
}

function test_dmg_has_correct_owner() {
    owner=$(ls -l $dmg_file | awk '{print $3; exit}')
    test $owner = $(whoami)
}

function test_dmg_has_correct_permissions() {
    permissions=$(ls -l $dmg_file | awk '{print $1; exit}')
    test $permissions = "-r--------"
}

function teardown() {
    umount $mount_dir
    rm -Rf $mount_dir
}
