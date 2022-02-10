use lambda_http::{
    handler,
    lambda_runtime::{self, Context, Error},
    IntoResponse,
    Response,
    Request,
};

use serde::{Deserialize};

#[derive(Deserialize)]
struct ApiGatewayV2RequestContext {
    http: Http,
    #[serde(default)]
    body: String,
}

#[derive(Deserialize)]
struct Http {
    method: String,
}




#[tokio::main]
async fn main() -> Result<(), Error> {

    // add redis connection her to be available on concurrent executions
    lambda_runtime::run(handler(func)).await?;
    Ok(())
}

async fn entry(req: ApiGatewayV2RequestContext, _: Context) -> Result<impl IntoResponse, lambda_runtime::Error> {
    let ctx = req.context()?;
    
    let http_verb = req.http.method.as_str();

    Ok(match http_verb {
        "POST" => {
            let body = req.body()?;
            format!("Method: {}, Body: {}", http_verb, body).into_response()
        },
        _ => Response::builder()
            .status(400)
            .body("Empty first name".into())
            .expect("failed to render response"),
    })
}