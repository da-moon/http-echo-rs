#[macro_use]
extern crate log;
extern crate actix_web;
mod git;
mod server;
use clap::{App, Arg};
#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    let version = git::tag(".").expect("fetch git version");
    std::env::set_var("RUST_LOG", "actix_web=info,server=info");
    env_logger::init();
    let matches = App::new("http-echo")
        .version(version.as_str())
        .author("da-moon <damoon.azarpazhooh@ryerson.ca>")
        .about(
            "small rust web server that serves the contents it was started with as an HTML page.",
        )
        .arg(
            Arg::with_name("listen")
                .short("l")
                .long("listen")
                .default_value(":5678")
                .value_name("listen")
                .help("address and port to listen."),
        )
        .arg(
            Arg::with_name("text")
                .short("t")
                .long("text")
                .default_value("hello-world!")
                .value_name("text")
                .help("text to put on the webpage"),
        )
        .get_matches();

    let l = matches.value_of("listen");
    let t = matches.value_of("text");
    let app = server::Server::new(l.unwrap(), "http-echo-rs", version.as_str(), t.unwrap());
    app.run().await
}
