#[macro_use]
extern crate lazy_static;

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
    use super::*;

    static URL_INPUT: &str = "http://localhost:8080/input";

    #[test]
    fn create_new_order() {
        // create an order
        let order = create_order();
        // send
        let response = CLIENT.post(URL_INPUT).json(&order).send();
        match response {
            Err(e) => { dbg!(e); }
            Ok(res) => { dbg!(res); }
        };
        // check created instance
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