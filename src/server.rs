use actix_web::{middleware, web, App, HttpResponse, HttpServer};
use std::cell::Cell;
use std::sync::atomic::{AtomicUsize, Ordering::SeqCst};

static WORKER_COUNTER: AtomicUsize = AtomicUsize::new(0);
static HTTP_HEADER_APP_NAME: &'static str = "X-App-Name";
static HTTP_HEADER_APP_VERSION: &'static str = "X-App-Version";
#[derive(Debug)]
pub struct Server {
    listener: String,
    version: String,
    name: String,
    text: String,
}
struct State {
    worker_number: usize,
    request_counter: Cell<usize>,
    version: String,
    name: String,
    text: String,
}
impl Server {
    pub fn new(listener: &str, name: &str, version: &str, text: &str) -> Self {
        return Server {
            listener: listener.to_owned(),
            version: version.to_owned(),
            name: name.to_owned(),
            text: text.to_owned(),
        };
    }
    pub async fn run(&self) -> std::io::Result<()> {
        let version = format!("{}", self.version);
        let name = format!("{}", self.name);
        let text = format!("{}", self.text);
        let listener: Vec<&str> = self.listener.split(':').collect();
        if listener.len() > 2 {
            return Err(std::io::Error::new(
                std::io::ErrorKind::Other,
                "wrong listener format.",
            ));
        }
        let ip: &str = if listener[0].len() == 0 {
            "0.0.0.0"
        } else {
            listener[0]
        };
        let port: &str = listener[1];
        let result = HttpServer::new(move || {
            App::new()
                .data(State {
                    worker_number: WORKER_COUNTER.fetch_add(1, SeqCst),
                    request_counter: std::cell::Cell::new(0),
                    version: version.to_owned(),
                    name: name.to_owned(),
                    text: text.to_owned(),
                })
                .wrap(middleware::Logger::default())
                .service(web::resource("/health").route(web::get().to(health_check)))
                .service(web::resource("/").route(web::get().to(index)))
                .default_service(web::to(|| HttpResponse::NotFound()))
        })
        .bind(format!("{}:{}", ip, port));
        if result.is_err() {
            return Err(result.err().unwrap());
        }
        println!("started http server at '{}:{}'", ip, port);
        result.unwrap().run().await
    }
}
#[derive(serde::Serialize)]
struct HealthCheckResponse {
    status: String,
}
async fn health_check(state: web::Data<State>) -> HttpResponse {
    debug!("/health -> worker {}", state.worker_number);
    HttpResponse::Ok()
        .content_type("application/json")
        .header(HTTP_HEADER_APP_NAME, state.name.as_str())
        .header(HTTP_HEADER_APP_VERSION, state.version.as_str())
        .json(HealthCheckResponse {
            status: "ok".to_owned(),
        })
}
async fn index(state: web::Data<State>) -> HttpResponse {
    debug!("/ -> worker {}", state.worker_number);
    let updated_request_counter = state.request_counter.get() + 1;
    state.request_counter.set(updated_request_counter);
    HttpResponse::Ok()
        .content_type("text/plain")
        .header(HTTP_HEADER_APP_NAME, state.name.as_str())
        .header(HTTP_HEADER_APP_VERSION, state.version.as_str())
        .body(&state.text)
}
