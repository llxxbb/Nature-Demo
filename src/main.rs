#[macro_use]
extern crate lazy_static;
extern crate serde;
extern crate serde_json;

use reqwest::Client;

pub use nature_demo_common::{Commodity, Order, SelectedCommodity};

lazy_static! {
    static ref CLIENT : Client = Client::new();
}

fn main() {
    println!("Nature demo");
}

#[cfg(test)]
mod demo {
    use nature_common::Instance;

    use super::*;

    static URL_INPUT: &str = "http://localhost:8080/input";
    static URL_GET_BY_ID: &str = "http://localhost:8080/get_by_id";

    #[test]
    fn create_new_order() {
        // create an order
        let order = create_order();
        // ---- create a instance with meta: "/B/order:1"
        let mut instance = Instance::new("/sale/order").unwrap();
        instance.content = serde_json::to_string(&order).unwrap();

        // send
        let response = CLIENT.post(URL_INPUT).json(&instance).send();
        let id: String = response.unwrap().text().unwrap();
        dbg!(&id);
//        if id.contains(r#""Err":{"#) {
//            return;
//        }
        // send again
        let response = CLIENT.post(URL_INPUT).json(&instance).send();
        dbg!(response.unwrap().text().unwrap());


        // check created instance
        let response = CLIENT.post(URL_GET_BY_ID).body("36859397350548005752481459694972779262").send();
        match response {
            Err(e) => { dbg!(e); }
            Ok(mut res) => { let _ = dbg!(res.text()); }
        };
    }

    fn create_order() -> Order {
        Order {
            user_id: 123,
            price: 100,
            items: vec![
                SelectedCommodity {
                    item: Commodity { id: 1, name: "phone".to_string() },
                    num: 1,
                },
                SelectedCommodity {
                    item: Commodity { id: 2, name: "battery".to_string() },
                    num: 2,
                }
            ],
            address: "a.b.c".to_string(),
        }
    }
}