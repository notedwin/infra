use chrono::{Local, NaiveDateTime};
use http::Method;
use lambda_http::{service_fn, Body, Error, Request, RequestExt, Response};
use log::info;
use redis::{Client, Commands, RedisResult, Value};
use reqwest;
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::env;

const API: &str = "http://ip-api.com/json/";
#[derive(Debug, Deserialize, Default)]
struct Args {
    #[serde(default)]
    message: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct Hacker {
    user: String,
    ip: String,
    lon: f64,
    lat: f64,
    time: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct Location {
    lat: f64,
    lon: f64,
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
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

    let redis_url = env::var("REDIS_URL").expect("REDIS_URL must be set");
    let mut con: redis::Connection = Client::open(redis_url.as_str())?.get_connection()?;
    //flush redis
    //let _: () = redis::cmd("FLUSHALL").query(&mut con).unwrap();


    info!("Request: {:?}", request);
    info!("redis_url: {}", redis_url);
    let method = request.method();
    match *method {
        Method::GET => {
            let hackers: Vec<Hacker> = pull_hackers(&mut con);
            let hackers_json: String = serde_json::to_string(&hackers).unwrap();
            info!("hackers: {}", hackers_json);
            Ok(Response::builder()
                .status(200)
                .body(json!({ "list": hackers_json }).to_string().into())
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

            if data_arr[3] == "root" || data_arr[3] == "ubuntu" {
                user = data_arr[3];
                ip = data_arr[5];
            } else {
                user = data_arr[5];
                ip = data_arr[7];
            }
            info!("entering populate_redis");
            populate_redis(user, ip, &mut con).await?;

            Ok(Response::builder()
                .status(200)
                .body(format!("Redis Populated with Body: {}", args.message).into())
                .expect("failed to render response"))
        }
        _ => Ok(Response::builder()
            .status(400)
            .body("Empty first name".into())
            .expect("failed to render response")),
    }
}

fn pull_hackers(con: &mut redis::Connection) -> Vec<Hacker> {
    let now: i64 = Local::now().timestamp();
    let five_hours_ago: i64 = now - 5 * 60 * 60;

    let result: Vec<Hacker> = redis::cmd("zrangebyscore")
        .arg("hackers")
        .arg(five_hours_ago)
        .arg(now)
        .query::<Vec<String>>(con)
        .unwrap()
        .iter()
        .map(|hacker| {
            info!("hacker: {}", hacker);
            let hacker_json: String = con.get(hacker).unwrap();
            let mut hacker_struct: Hacker = serde_json::from_str(&hacker_json).unwrap();
            let time = NaiveDateTime::from_timestamp(hacker.parse::<i64>().unwrap(), 0);
            hacker_struct.time = time.format("%H:%M:%S").to_string();
            hacker_struct
        })
        .collect();
    result
}

async fn populate_redis(
    user: &str,
    ip: &str,
    con: &mut redis::Connection,
) -> Result<(), reqwest::Error> {
    // let data: Location;

    // if con.exists(ip).unwrap() {
    //     println!("{} already exists", ip);
    //     let loc: String = con.get(ip).unwrap();
    //     data = serde_json::from_str(&loc).unwrap();
    // } else {

    // }

    let url = format!("{}{}", API, ip);
    info!("url: {}", url);
    let data: Location = reqwest::Client::new()
        .get(&url)
        .send()
        .await?
        .json()
        .await?;

    // let res: RedisResult<Value> = con.hset_multiple(ip, &[("lat", data.lat), ("lon", data.lon)]);
    // if let Err(error) = res {
    //     info!("error storing IP {:?}", error);
    // }

    let time: i64 = Local::now().timestamp();

    let hacker = Hacker {
        user: user.to_string(),
        ip: ip.to_string(),
        lon: data.lon,
        lat: data.lat,
        time: time.to_string(),
    };

    let hacker_json: String = serde_json::to_string(&hacker).unwrap();
    info!("{}, json, {}", time.to_string(), hacker_json);

    let res: RedisResult<Value> = con.set(
        time.to_string(),
        hacker_json
    );

    if let Err(error) = res {
        info!("Storing time event {:?}", error);
    }

    let res2: RedisResult<Value> = con.zadd("hackers", time, time);

    if let Err(error) = res2 {
        info!("adding event to time array {:?}", error);
    }
    
    let hackers: Vec<Hacker> = pull_hackers(con);
            let hackers_json: String = serde_json::to_string(&hackers).unwrap();
            info!("hackers: {}", hackers_json);

    Ok(())
}
