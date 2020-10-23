#[macro_use]
extern crate version;

git_version!(VERSION);

#[test]
fn should_have_version() {
    println!("VERSION: {}", VERSION);
    assert_ne!("", VERSION)
}
