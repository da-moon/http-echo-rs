use failure::Error;
use git2::DescribeOptions;
use git2::Repository;
use std::convert::AsRef;
use std::path::Path;
fn main() {
    // let output = std::process::Command::new("git").args(&["describe", "--tags"]).output().unwrap();
    // let git_version = String::from_utf8(output.stdout).unwrap();
    let git_version = tag(".").expect("fetch git version");
    println!("cargo:rustc-env=GIT_VERSION={}", git_version);
}
fn tag<P: AsRef<Path>>(topdir: P) -> Result<String, Error> {
    let mut options = DescribeOptions::new();
    options.describe_tags().show_commit_oid_as_fallback(true);
    let repo = Repository::discover(topdir)?;
    let descr = repo.describe(&options)?;
    Ok(descr.format(None)?)
}