use failure::Error;
use git2::DescribeOptions;
use git2::Repository;
use std::convert::AsRef;
use std::path::Path;
pub fn tag<P: AsRef<Path>>(topdir: P) -> Result<String, Error> {
    let mut options = DescribeOptions::new();
    options.describe_tags().show_commit_oid_as_fallback(true);
    let repo = Repository::discover(topdir)?;
    let descr = repo.describe(&options)?;
    Ok(descr.format(None)?)
}
mod tests {
    #[allow(unused_imports)]
    use super::tag;
    #[test]
    fn should_have_tag() {
        let latest_tag = tag(".").expect("fetch git version");
        println!("tag: {}", latest_tag);
        assert_ne!("", latest_tag)
    }
}
