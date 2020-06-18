use std::collections::HashMap;

use serde::Serialize;

use nature_common::{Instance, NatureError, Result};

use crate::CLIENT;
use crate::URL_INPUT;

#[test]
fn multi_warehouse() {
    #[derive(Serialize)]
    struct Order(String);

    let mut map: HashMap<String, String> = HashMap::new();

    map.insert("self".to_string(), "self".to_string());
    let _id = send("order", &Order("A".to_string()), &map).unwrap();

    map.clear();
    map.insert("third".to_string(), "third".to_string());
    let _id = send("order", &Order("B".to_string()), &map).unwrap();

    map.clear();
    map.insert("self".to_string(), "self".to_string());
    map.insert("third".to_string(), "third".to_string());
    let _id = send("order", &Order("C".to_string()), &map).unwrap();

    map.clear();
    let _id = send("order", &Order("D".to_string()), &map).unwrap();
}

pub fn send<T>(meta_key: &str, bo: &T, context: &HashMap<String, String>) -> Result<u128> where T: Serialize {
    let mut instance = Instance::new(meta_key).unwrap();
    instance.content = serde_json::to_string(bo).unwrap();
    instance.context = context.clone();

    let response = CLIENT.post(URL_INPUT).json(&instance).send();
    let id_s: String = response.unwrap().text().unwrap();
    if id_s.contains("Err") {
        return Err(NatureError::VerifyError(id_s));
    }
    serde_json::from_str(&id_s)?
}