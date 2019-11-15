use std::thread::sleep;
use std::time::Duration;

use nature_common::Instance;

use crate::{get_state_instance_by_id, send_instance};

pub fn outbound(order_id: u128) {
    let last = wait_for_packaged(order_id);
    let mut instance = Instance::new("/sale/orderState").unwrap();
    instance.id = last.id;
    instance.state_version = last.state_version + 1;
    instance.states.clear();
    instance.states.insert("outbound".to_string());
    let rtn = send_instance(&instance);
    dbg!(&rtn);
    assert_eq!(rtn.is_ok(), true);
}

fn wait_for_packaged(order_id: u128) -> Instance {
    loop {
        if let Some(ins) = get_state_instance_by_id(order_id, "/B/sale/orderState:1", 3) {
            return ins;
        } else {
            sleep(Duration::from_nanos(200000))
        }
    }
}