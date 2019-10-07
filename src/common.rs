use reqwest::Client;
use serde::Serialize;

use nature_common::{Instance, NatureError, ParaForQueryByID, Result};

lazy_static! {
    pub static ref CLIENT : Client = Client::new();
}

pub static URL_INPUT: &str = "http://localhost:8080/input";
pub static URL_GET_BY_ID: &str = "http://localhost:8080/get_by_id";

pub fn send_instance<T>(meta_key: &str, bo: &T) -> Result<u128> where T: Serialize {
    let mut instance = Instance::new(meta_key).unwrap();
    instance.content = serde_json::to_string(bo).unwrap();

    let response = CLIENT.post(URL_INPUT).json(&instance).send();
    let id_s: String = response.unwrap().text().unwrap();
    dbg!(&id_s);
    if id_s.contains("Err") {
        return Err(NatureError::VerifyError(id_s));
    }
    serde_json::from_str(&id_s)?
}

pub fn get_instance_by_id(id: u128, meta_full: &str) -> Option<Instance> {
    let response = CLIENT.post(URL_GET_BY_ID).json(&ParaForQueryByID { id, meta: meta_full.to_string() }).send();
    let msg = response.unwrap().text().unwrap();
    dbg!(&msg);
    if msg.eq(r#"{"Ok":null}"#) {
        return None;
    }
    let x: Result<Instance> = serde_json::from_str(&msg).unwrap();
    Some(x.unwrap())
}

#[cfg(test)]
mod test {
    use nature_demo_common::Order;

    use super::*;

//    #[test]
    fn send_instance_ok() {
        let o = Order {
            user_id: 123,
            price: 100,
            items: vec![],
            address: "a.b.c".to_string(),
        };
        let _id = send_instance("/sale/order", &o).unwrap();
        // 296191925563190914478889646683739310356
    }

//    #[test]
    fn send_instance_err() {
        let o = Order {
            user_id: 123,
            price: 100,
            items: vec![],
            address: "a.b.c".to_string(),
        };
        let id = send_instance("/sale/order", &o);
        assert_eq!(id.is_err(), true)
    }

//    #[test]
    fn get_instance_by_id_ok() {
        let ins = get_instance_by_id(296191925563190914478889646683739310356, "/B/sale/order:1");
        assert_eq!(ins.is_some(), true)
    }

//    #[test]
    fn get_instance_by_id_err() {
        let ins = get_instance_by_id(296191925563190914478889646683739310357, "/B/sale/order:1");
        assert_eq!(ins.is_none(), true)
    }
}