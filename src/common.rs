use std::collections::HashMap;
use std::thread::sleep;
use std::time::Duration;

use reqwest::blocking::Client;
use serde::Serialize;

use nature_common::{Instance, NatureError, ParaForQueryByID, Result};

lazy_static! {
    pub static ref CLIENT : Client = Client::new();
}

pub static URL_INPUT: &str = "http://localhost:8080/input";
pub static URL_GET_BY_ID: &str = "http://localhost:8080/get_by_id";

pub fn send_instance(ins: &Instance) -> Result<u128> {
    let response = CLIENT.post(URL_INPUT).json(ins).send();
    let id_s: String = response.unwrap().text().unwrap();
    if id_s.contains("Err") {
        return Err(NatureError::VerifyError(id_s));
    }
    serde_json::from_str(&id_s)?
}

pub fn send_business_object<T>(meta_key: &str, bo: &T) -> Result<u128> where T: Serialize {
    send_business_object_with_sys_context(meta_key, bo, &HashMap::new())
}

pub fn send_business_object_with_sys_context<T>(meta_key: &str, bo: &T, sys_context: &HashMap<String, String>) -> Result<u128> where T: Serialize {
    let mut instance = Instance::new(meta_key).unwrap();
    instance.content = serde_json::to_string(bo).unwrap();
    instance.sys_context = sys_context.clone();

    let response = CLIENT.post(URL_INPUT).json(&instance).send();
    let id_s: String = response.unwrap().text().unwrap();
    if id_s.contains("Err") {
        return Err(NatureError::VerifyError(id_s));
    }
    serde_json::from_str(&id_s)?
}

pub fn get_instance_by_id(id: u128, meta_full: &str) -> Option<Instance> {
    get_state_instance_by_id(id, meta_full, 0)
}

fn get_state_instance_by_id(id: u128, meta_full: &str, sta_ver: i32) -> Option<Instance> {
    info!("get state instance by id {}", &id);
    let response = CLIENT.post(URL_GET_BY_ID).json(&ParaForQueryByID {
        id,
        meta: meta_full.to_string(),
        para: "".to_string(),
        state_version: sta_ver,
        limit: 1,
    }).send();
    let msg = response.unwrap().text().unwrap();
    if msg.eq(r#"{"Ok":null}"#) {
        return None;
    }
    match serde_json::from_str::<Result<Instance>>(&msg).unwrap() {
        Ok(x) => Some(x),
        Err(_) => None
    }
}

pub fn wait_for_order_state(order_id: u128, state_ver: i32) -> Instance {
    loop {
        if let Some(ins) = get_state_instance_by_id(order_id, "B:sale/orderState:1", state_ver) {
            return ins;
        } else {
            warn!("not found state instance, will retry");
            sleep(Duration::from_nanos(3000000))
        }
    }
    // panic!("can't find order and state");
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn temp_test() {
        let rtn = get_instance_by_id(46912184945275581809007620859293488763, "B:sale/order:1");
        dbg!(rtn);
    }
}
