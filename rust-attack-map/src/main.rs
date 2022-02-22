use http::Method;
use lambda_http::{service_fn, Body, Context, Error, IntoResponse, Request, RequestExt, Response};
use reqwest;
use log::{debug, error, info};
use serde::{Deserialize, Serialize};
use tracing_subscriber::EnvFilter;

use std::env::var;
use std::time::Instant;

const API: &str = "http://ip-api.com/json/";
//const REDIS_URL: String = env::var("REDIS_URL").expect("REDIS_URL must be set");

#[derive(Debug, Deserialize, Default)]
struct Args {
    #[serde(default)]
    message: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct Location {
    lat: f64,
    lon: f64,
}

impl Default for Location {
    fn default() -> Location {
        Location {
            lat: 73.907,
            lon: 40.7128,
        }
    }
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    //let mut con: redis::Connection = Client::open(REDIS_URL).unwrap().get_connection().unwrap();
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        // Setup from the environment (RUST_LOG)
        .with_env_filter(EnvFilter::from_default_env())
        // this needs to be set to false, otherwise ANSI color codes will
        // show up in a confusing manner in CloudWatch logs.
        .with_ansi(false)
        // disabling time is handy because CloudWatch will add the ingestion time.
        .without_time()
        .init();
    lambda_http::run(service_fn(entry)).await?;
    Ok(())
}

async fn entry(request: Request) -> Result<Response<Body>, Error> {
    info!("Request: {:?}", request);
    let method = request.method();
    match *method {
        Method::GET => {
            let body = format!("Method: {}", method);
            Ok(Response::builder()
                .status(200)
                .body(body.into())
                .expect("failed to render response"))
        }
        Method::POST => {
            let args: Args = request
                .payload()
                .unwrap_or_else(|_parse_err| None)
                .unwrap_or_default();
            let data_arr: Vec<&str> = args.message.split_whitespace().collect();
            
            let user: &str;
            let ip: &str;

            if data_arr[3] == "root" || data_arr[3] == "ubuntu"{
                user = data_arr[3];
                ip = data_arr[5];
            } else {
                user = data_arr[5];
                ip = data_arr[7];
            }

            let url = format!("{}{}", API, ip);
            let data: Location = reqwest::get(&url).await?.json().await?;

            Ok(Response::builder()
                .status(200)
                .body(format!("Body: {}, Lat:{}, Lon:{}, User:{}", args.message, data.lat, data.lon, user).into())
                .expect("failed to render response"))
        }
        _ => Ok(Response::builder()
            .status(400)
            .body("Empty first name".into())
            .expect("failed to render response")),
    }
}