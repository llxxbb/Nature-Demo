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
    use std::str::FromStr;

    use nature_common::{Instance, NatureError, ParaForQueryByID};

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
        let id_s: String = response.unwrap().text().unwrap();
        dbg!(&id_s);
        let id: Result<u128, NatureError> = serde_json::from_str(&id_s).unwrap();
        let id = id.unwrap();
        dbg!(&id);

        // send again
        let response = CLIENT.post(URL_INPUT).json(&instance).send();
        let msg = response.unwrap().text().unwrap();
        dbg!(&msg);
        assert_eq!(msg.contains("DaoDuplicated"), true);


        // check created instance for order
        let response = CLIENT.post(URL_GET_BY_ID).json(&ParaForQueryByID { id, meta: "/B/sale/order:1".to_string() }).send();
        let msg = response.unwrap().text().unwrap();
        dbg!(&msg);
        assert_eq!(msg.contains(&id_s), true);

        // check created instance for order state
        let response = CLIENT.post(URL_GET_BY_ID).json(&ParaForQueryByID { id, meta: "/B/sale/order:1".to_string() }).send();
        let msg = response.unwrap().text().unwrap();
        dbg!(&msg);
        assert_eq!(msg.contains(&id_s), true);
    }

    #[test]
    fn temp_test() {
        let response = CLIENT.post(URL_GET_BY_ID).json(&ParaForQueryByID { id: 23161777138351926403917145131788703064, meta: "/B/sale/orderState:1".to_string() }).send();
        let msg = response.unwrap().text().unwrap();
        dbg!(&msg);
        assert_eq!(msg.contains("23161777138351926403917145131788703064"), true);
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

    #[test]
    fn u128_test() {
        let id = "23161777138351926403917145131788703064";
        let result = u128::from_str(id).unwrap();
        assert_eq!(result, 23161777138351926403917145131788703064);
        let id = r#"{"Ok":23161777138351926403917145131788703064}"#;
        let result: Result<u128, NatureError> = serde_json::from_str(&id).unwrap();
        assert_eq!(result.unwrap(), 23161777138351926403917145131788703064);
    }
}